CREATE DATABASE unix_travel;
USE unix_travel;

-- TABLA USUARIO
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    contraseña VARCHAR(255),
    tipo_usuario ENUM('cliente','admin'),
    fecha_registro DATE
);

-- TABLA VIAJE
CREATE TABLE viaje (
    id_viaje INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    precio DECIMAL(10,2),
    fecha_inicio DATE,
    fecha_fin DATE
);

-- TABLA DESTINO
CREATE TABLE destino (
    id_destino INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    descripcion TEXT
);

-- TABLA INTERMEDIA
CREATE TABLE viaje_destino (
    id_viaje INT,
    id_destino INT,
    PRIMARY KEY (id_viaje, id_destino),
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje),
    FOREIGN KEY (id_destino) REFERENCES destino(id_destino)
);

-- TABLA RESERVA
CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_viaje INT,
    fecha_reserva DATE,
    estado VARCHAR(50),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje)
);

-- TABLA PAGO
CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT UNIQUE,
    monto DECIMAL(10,2),
    metodo_pago VARCHAR(50),
    estado VARCHAR(50),
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

-- TABLA IA
CREATE TABLE recomendacion_ia (
    id_recomendacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    destino_recomendado VARCHAR(100),
    fecha DATE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);