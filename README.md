# Echo

**Chat Application**


TP FINAL - Taller de Programación - Universidad de Buenos Aires<br>
__Profesor:__ Manuel Camejo. <br>
__Alumnos:__ 
- Lucas Facundo Couttulenc (109726)
- Martín Maddalena (107610)
- Rocío Mariana Gallo (97490)

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
5. `make setup` -> Para preparar la DB.
6. `make seed` -> Para cargar datos a la DB.
7. `make run` -> Correr la app.




