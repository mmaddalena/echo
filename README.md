# Echo

**Chat Application**


TP FINAL - Taller de Programación - Universidad de Buenos Aires<br>

__Alumnos:__ 
- Lucas Facundo Couttulenc (109726)
- Martín Maddalena (107610)

__Profesores:__ 
- Manuel Camejo
- Matías Onorato

## Compilación, Empaquetación y Ejecución
	Instalar previamente (TODO ESTO DEBERÍA HACERSE DENTRO DE UN DOCKER, PARA NO TENER QUE INSTALAR TODO ESTO, ES UN QUILOMBO SINO):

- **Erlang**
- **Elixir**
- **PostgreSQL**
- **Docker + Docker Desktop**
- **make (MSYS2)**

En **Windows**, además instalar **Visual Studio Build Tools**:
- En la instalación, incluir mínimamente:
	- C++ Build Tools
	- MSVC
	- Windows SDK
	
	<br>

Compilar dependencias (CLAVE para Windows) con `mix deps.compile`

1. Abrir ``Docker Desktop``.
2. (En Windows) `$env:PATH = "C:\msys64\usr\bin;C:\msys64\mingw64\bin;" + $env:PATH` -> para que make, gcc y sh funcionen correctamente.
3. `make up` -> Para levantar el contenedor de Docker.
4. `make deps` -> Para instalar las dependencias necesarias.
5. `make build` -> .
6. `make setup` -> Para preparar la DB.
7. `make seed` -> Para cargar datos a la DB.
8. `make run` -> Correr la app.


Windows ENV local:
`$env:DATABASE_URL="ecto://postgres:postgres@db:5432/echo_dev"` -> 
`$env:DATABASE_URL="ecto://postgres:postgres@localhost:5432/echo_dev"`


`$env:GOOGLE_APPLICATION_CREDENTIALS="/app/priv/gcp/service-account.json"`

<br><br>



## Backend - Arquitectura de Procesos y DB

### Funcionamiento general de la aplicación (a nivel de datos)

La aplicación está modelada como un sistema de mensajería en tiempo real centrado en usuarios, chats y mensajes, con relaciones explícitas para membresía, contactos y estados de lectura.

El núcleo del sistema gira alrededor de los chats, que pueden ser privados o grupales, y de los mensajes enviados dentro de esos chats por los usuarios.

---
#### **Usuarios como entidad central**

El sistema está completamente centrado en la entidad User, que representa tanto la identidad como el perfil social del usuario dentro de la aplicación.

Cada usuario contiene:
- Credenciales (``username``, ``email``, ``password hash``).
- Información de perfil (``name``, ``avatar``).
- Estado de presencia (``last_seen_at``).
- Relaciones con todos los componentes sociales.

Lógicamente se handlean verificaciones en el backend para que los usernames e emails sean únicos.

---
#### **Chats**

Un chat representa una conversación y puede ser de dos tipos:

- **private** → conversación uno a uno (sin nombre).

- **group** → conversación grupal (requiere nombre y avatar).

Cada chat:
- Tiene un creador (``creator_id``).
- Tiene muchos miembros (``chat_members``) (inicialmente, pues al poder abandonar un grupo o ser expulsado de uno, puede terminar habiendo sólo 1 integrante).
- Tiene mensajes.

En el schema, se decidieron reglas de negocio importantes:
- Los chats privados no pueden tener nombre.
- Los chats grupales sí deben tener nombre.

---
#### **Membresía de Chats (ChatMember)**

Esta tabla intermedia define la relación usuario ↔ chat. Esta relación se enriquece con:
- Rol dentro del chat (`member` o `admin`).
- Última vez que se leyó el chat.

---
#### **Mensajes **

Cada mensaje:
- Pertenece a un chat.
- Pertenece a un usuario (el emisor).
- Tiene contenido (``content``) y formato (`text`, `image`, `file`, etc.).
- Maneja estado (`sent`, `delivered`, `read`)

---
#### **Contactos**

Cada contacto:
- Relaciona un usuario con otro usuario.
- Permite un apodo (`nickname`) propio.

Además: 
- No se pueden duplicar contactos.
- Cada usuario maneja su propia lista de contactos.
- No es una relación bidireccional, sino que unilateral (userA puede agregar como contacto a userB y no necesariamente viceversa).

---
#### **Bloqueo de Contactos**

El schema ``BlockedContact`` ya está preparado para:

-Bloqueos entre usuarios.
-Clave compuesta (blocker + blocked).
-Evitar bloquearse a uno mismo.
-Evitar duplicados.

Y aunque no esté implementado aún, está listo para:
- Ocultar mensajes.
- Evitar nuevos chats.
- Restringir interacción.

---



### Árbol OTP (supervisado)

![Árbol de supervisión](/priv/docs/readme/supervision_tree.png)

- **``Application``**: Supervisor padre de la app.

- **`UserSessionSup`**: Supervisor dinámico encargado de iniciar nuevos `UserSession` cuando se requieran.
	- **``UserSession``**: Proceso que vive únicamente para un usuario concreto. Éste resuelve mensajes de WS o deriva su resolución a `ChatSession` si es que la acción requiere la intervención de un chat.

- **``ChatSessionSup``**: Supervisor dinámico encargado de iniciar nuevos `ChatSession` cuando se requieran.
	- **``ChatSession``**: Proceso que vive únicamente para un chat concreto. Éste resuelve todas las acciones que se tengan que realizar sobre ese chat.

- **``ProcessRegistry``**: Proceso que usa el módulo OTP `Registry` para almacenar en su estado a cada `UserSession` y `ChatSession` mediante las _via tuples_.

- **``Repo``**: Administra la pool de conexiones a Postgres. Es el intermediario entre el back y la DB.

- **``Goth``**: Se encarga de la autenticación OAuth con Google Cloud. Administra tokens de acceso, su renovación automática y su disponibilidad para servicios de media, evitando autenticación manual en cada request.

### Componentes no OTP

**``Cowboy Listener``**:
Atiende conexiones HTTP y WebSocket. Rutea:
<br>\- **WebSocket** hacia `UserSocket`
<br>\- **HTTP** hacia *Plug* `Router`

- **``UserSocket``**: Al igual que UserSession, hay uno por conexión Cliente-Servidor. Es el que funciona como intermediario entre los mensajes ``front 🠚 back`` y ``back 🠚 front``. Delega cada mensaje del cliente a una función pública del `UserSession` correspondiente, y envía cada mensaje del `UserSession` al cliente.

- **``Router``**: Pipeline HTTP basado en Plug que procesa requests y delega en los módulos de dominio correspondientes.


### Módulos de dominio interno

- **``Echo.Auth.Accounts``**: Lógica de autenticación y cuentas de usuario.

- **``Echo.Auth.Auth``**: Lógica concreta de autenticación y cuentas de usuario, utilizada por `Accounts`.

- **``Echo.Auth.Jwt``**: Gestiona la creación y validación de tokens para el cliente.

- **``Echo.Users.User``**: Gestión de usuarios. Utiliza `Repo` para accionar sobre la DB. Es utilizada principalemente por  `UserSession` y `ChatSession`.

- **``Echo.Chats.Chat``**: Gestión de chats. Utiliza `Repo` para accionar sobre la DB. Es utilizada principalemente por `ChatSession`.

- **``Echo.Messages.Messages``**: Gestión de mensajes. Utiliza `Repo` para accionar sobre la DB. Es utilizada principalemente por `Chat`.

- **``Echo.Contacts.Contacts``**: Gestión de contactos. Utiliza `Repo` para accionar sobre la DB. Es utilizada principalemente por `User` y `Chat`.


