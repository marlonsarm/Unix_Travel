from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)

# 🔥 CORS
CORS(app, resources={r"/*": {"origins": "*"}})

# 🔥 CONEXIÓN MYSQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="1234",
    database="unix_travel"
)

# =========================
# 🔥 CREAR TABLAS
# =========================

def crear_tablas():
    cursor = db.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS carrito (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_cedula VARCHAR(50),
            nombre_producto VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS favoritos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_cedula VARCHAR(50),
            nombre_producto VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT
        )
    """)

    db.commit()
    cursor.close()

crear_tablas()


@app.route('/')
def home():
    return "Servidor funcionando 🔥"

# =========================
# 🛒 CARRITO
# =========================

@app.route('/agregar_carrito', methods=['POST'])
def agregar_carrito():
    try:
        data = request.json

        cursor = db.cursor()

        sql = """
        INSERT INTO carrito (usuario_cedula, nombre_producto, precio, imagen)
        VALUES (%s, %s, %s, %s)
        """

        valores = (
            data.get('usuario_cedula'),
            data.get('nombre'),
            data.get('precio'),
            data.get('imagen')
        )

        cursor.execute(sql, valores)
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Producto agregado al carrito"})

    except Exception as e:
        print("❌ ERROR CARRITO:", e)
        return jsonify({"mensaje": str(e)}), 500


@app.route('/obtener_carrito/<cedula>', methods=['GET'])
def obtener_carrito(cedula):
    try:
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM carrito WHERE usuario_cedula = %s",
            (cedula,)
        )

        datos = cursor.fetchall()
        cursor.close()

        return jsonify({"carrito": datos})

    except Exception as e:
        print("❌ ERROR OBTENER:", e)
        return jsonify({"mensaje": str(e)}), 500


@app.route('/eliminar_carrito/<int:id>', methods=['DELETE'])
def eliminar_carrito(id):
    try:
        cursor = db.cursor()
        cursor.execute("DELETE FROM carrito WHERE id = %s", (id,))
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Producto eliminado"})

    except Exception as e:
        print("❌ ERROR ELIMINAR:", e)
        return jsonify({"mensaje": str(e)}), 500


@app.route('/pagar/<cedula>', methods=['DELETE'])
def pagar(cedula):
    try:
        cursor = db.cursor()
        cursor.execute(
            "DELETE FROM carrito WHERE usuario_cedula = %s",
            (cedula,)
        )
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Pago realizado"})

    except Exception as e:
        print("❌ ERROR PAGO:", e)
        return jsonify({"mensaje": str(e)}), 500


# =========================
# ❤️ FAVORITOS (PRO)
# =========================

# 🔄 TOGGLE FAVORITO (AGREGA / ELIMINA)
@app.route('/toggle_favorito', methods=['POST'])
def toggle_favorito():
    try:
        data = request.json
        cursor = db.cursor(dictionary=True)

        cursor.execute("""
            SELECT * FROM favoritos 
            WHERE usuario_cedula=%s AND nombre_producto=%s
        """, (data.get('usuario_cedula'), data.get('nombre')))

        existe = cursor.fetchone()

        if existe:
            cursor.execute("DELETE FROM favoritos WHERE id=%s", (existe["id"],))
            db.commit()
            cursor.close()
            return jsonify({"estado": "eliminado"})
        else:
            cursor.execute("""
                INSERT INTO favoritos (usuario_cedula, nombre_producto, precio, imagen)
                VALUES (%s, %s, %s, %s)
            """, (
                data.get('usuario_cedula'),
                data.get('nombre'),
                data.get('precio'),
                data.get('imagen')
            ))
            db.commit()
            cursor.close()
            return jsonify({"estado": "agregado"})

    except Exception as e:
        print("❌ ERROR FAVORITOS:", e)
        return jsonify({"mensaje": str(e)}), 500


# 🔍 VERIFICAR SI ES FAVORITO
@app.route('/es_favorito', methods=['POST'])
def es_favorito():
    try:
        data = request.json
        cursor = db.cursor(dictionary=True)

        cursor.execute("""
            SELECT * FROM favoritos 
            WHERE usuario_cedula=%s AND nombre_producto=%s
        """, (data.get('usuario_cedula'), data.get('nombre')))

        existe = cursor.fetchone()
        cursor.close()

        return jsonify({"es_favorito": True if existe else False})

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


# 📥 OBTENER FAVORITOS
@app.route('/obtener_favoritos/<cedula>', methods=['GET'])
def obtener_favoritos(cedula):
    try:
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM favoritos WHERE usuario_cedula = %s",
            (cedula,)
        )

        datos = cursor.fetchall()
        cursor.close()

        return jsonify({"favoritos": datos})

    except Exception as e:
        print("❌ ERROR OBTENER FAVORITOS:", e)
        return jsonify({"mensaje": str(e)}), 500


# ❌ ELIMINAR FAVORITO
@app.route('/eliminar_favorito/<int:id>', methods=['DELETE'])
def eliminar_favorito(id):
    try:
        cursor = db.cursor()
        cursor.execute("DELETE FROM favoritos WHERE id = %s", (id,))
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Favorito eliminado"})

    except Exception as e:
        print("❌ ERROR ELIMINAR FAVORITO:", e)
        return jsonify({"mensaje": str(e)}), 500


# =========================
# 👤 USUARIOS
# =========================

@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.json
        cursor = db.cursor()

        cursor.execute("SELECT * FROM usuario WHERE cedula = %s", (data.get('cedula'),))
        if cursor.fetchone():
            cursor.close()
            return jsonify({"mensaje": "La cédula ya existe"}), 400

        sql = """
        INSERT INTO usuario 
        (cedula, nombre, apellidos, email, `contraseña`, telefono, tipo_usuario)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        valores = (
            data.get('cedula'),
            data.get('nombre'),
            data.get('apellidos'),
            data.get('email'),
            data.get('password'),
            data.get('telefono'),
            "cliente"
        )

        cursor.execute(sql, valores)
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Usuario registrado correctamente"})

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        cursor = db.cursor(dictionary=True)

        cursor.execute("""
            SELECT * FROM usuario 
            WHERE cedula=%s AND email=%s AND `contraseña`=%s
        """, (data.get('cedula'), data.get('email'), data.get('password')))

        usuario = cursor.fetchone()
        cursor.close()

        if usuario:
            return jsonify({"usuario": usuario}), 200
        else:
            return jsonify({"mensaje": "Datos incorrectos"}), 401

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


@app.route('/user/<cedula>', methods=['GET'])
def get_user(cedula):
    try:
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE cedula=%s", (cedula,))
        usuario = cursor.fetchone()
        cursor.close()

        if usuario:
            return jsonify({"usuario": usuario}), 200
        else:
            return jsonify({"mensaje": "Usuario no encontrado"}), 404

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


@app.route('/update_user', methods=['POST'])
def update_user():
    try:
        data = request.json
        cursor = db.cursor()

        cursor.execute("""
            UPDATE usuario
            SET nombre=%s, apellidos=%s, email=%s, telefono=%s
            WHERE cedula=%s
        """, (
            data.get('nombre'),
            data.get('apellidos'),
            data.get('email'),
            data.get('telefono'),
            data.get('cedula')
        ))

        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Usuario actualizado"})

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


@app.route('/delete_user', methods=['POST'])
def delete_user():
    try:
        data = request.json
        cursor = db.cursor()

        cursor.execute("DELETE FROM usuario WHERE cedula=%s", (data.get('cedula'),))
        db.commit()
        cursor.close()

        return jsonify({"mensaje": "Usuario eliminado"})

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)