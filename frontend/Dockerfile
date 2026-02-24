# Dockerfile
FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose the port (default Vite port)
EXPOSE 5173

# Default command
CMD ["npm", "run", "dev"]