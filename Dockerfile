FROM node:18-bookworm

ARG NODE_SNAP=false

# Instalar dependencias necesarias en un solo paso
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential unixodbc unixodbc-dev sqlite3 libsqlite3-dev git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear usuario no root
RUN useradd -m appuser

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Clonar siempre la última versión del repositorio de GitHub
RUN git clone https://github.com/jhonatangm123/fuxascada.git && \
    cd fuxascada/odbc && \
    chmod +x install_odbc_drivers.sh && \
    ./install_odbc_drivers.sh && \
    cp odbcinst.ini /etc/odbcinst.ini

# Instalar dependencias del servidor FUXA SCADA
WORKDIR /usr/src/app/fuxascada/server
RUN npm install --omit=dev

# Instalar opcionalmente node-snap7 si NODE_SNAP=true
RUN if [ "$NODE_SNAP" = "true" ]; then npm install node-snap7; fi

# Workaround para SQLite3
RUN npm install --build-from-source --sqlite=/usr/bin sqlite3

# Cambiar permisos y asignar usuario no root
RUN chown -R appuser:appuser /usr/src/app
USER appuser

# Exponer puerto
EXPOSE 1881

# Iniciar el servidor
CMD ["npm", "start"]
