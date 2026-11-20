import os
import pyodbc

from flask import Flask, send_from_directory, jsonify, request
from flask_cors import CORS
from repositories.BancoRepository import BancoRepo

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DIST_DIR = os.path.join(BASE_DIR, "dist")   # adjust to where your build lands

app = Flask(__name__, static_folder=None)

# ==========================================
# 1. DATABASE CONNECTION
# ==========================================

SERVER = "marianito-edu.database.windows.net" #os.getenv("DB_SERVER")
DATABASE = "PC-1"#os.getenv("DB_DATABASE")
USERNAME = "mariano"#os.getenv("DB_USER")
PASSWORD = "Password1"#os.getenv("DB_PASSWORD")


def get_connection():
    if not all([SERVER, DATABASE, USERNAME, PASSWORD]):
        raise Exception(
            "Faltan variables de entorno: "
            "DB_SERVER, DB_DATABASE, DB_USER, DB_PASSWORD"
        )

    connection_string = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID={USERNAME};"
        f"PWD={PASSWORD};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=60;"
    )

    return pyodbc.connect(connection_string)


def rows_to_dicts(cursor, rows):
    columns = [column[0] for column in cursor.description]

    return [
        dict(zip(columns, row))
        for row in rows
    ]


# ==========================================
# 2. API ENDPOINTS
# ==========================================

@app.route('/api/login', methods=['POST'])
def loginv2():
    req_data = request.get_json() or {}

    user = req_data.get("user")
    password = req_data.get("password")

    if not user or not password:
        return jsonify({
            "status": "error",
            "message": "Usuario y contraseña son requeridos."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        ip = request.remote_addr

        cursor.execute(
            """
            EXEC dbo.Login
                @inUser = ?,
                @inPass = ?,
                @inIP = ?
            """,
            user,
            password,
            ip
        )

        row = cursor.fetchone()

        if not row:
            return jsonify({
                "status": "error",
                "message": "No se obtuvo respuesta del servidor."
            }), 500

        columns = [column[0] for column in cursor.description]
        result = dict(zip(columns, row))

        connection.commit()

        if result.get("Resultado") != 1:
            return jsonify({
                "status": "error",
                "message": result.get("Mensaje", "Login incorrecto.")
            }), 401

        return jsonify({
            "status": "success",
            "message": result.get("Mensaje"),
            "user": result.get("User"),
            "userId": result.get("Id"),
            "isAdmin": bool(result.get("flagEsAdministrador"))
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR LOGIN:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/getAccounts', methods=['GET'])
def getAccounts():
    user = request.args.get("user")

    if not user:
        return jsonify({
            "status": "error",
            "message": "Falta el parámetro user."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.GetUserAccounts
                @inUser = ?
            """,
            user
        )

        rows = cursor.fetchall()

        if not cursor.description:
            return jsonify({
                "status": "success",
                "accounts": []
            })

        data = rows_to_dicts(cursor, rows)

        return jsonify({
            "status": "success",
            "accounts": data
        })

    except Exception as error:
        print("ERROR GET ACCOUNTS:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/getAccountStatements', methods=['GET'])
def getAccountStatements():
    user = request.args.get("user")
    account = request.args.get("account")

    if not user or not account:
        return jsonify({
            "status": "error",
            "message": "Faltan los parámetros user o account."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.GetAccountStatements
                @inUser = ?,
                @inNumeroCuenta = ?
            """,
            user,
            account
        )

        rows = cursor.fetchall()

        if not cursor.description:
            return jsonify({
                "status": "success",
                "statements": []
            })

        data = rows_to_dicts(cursor, rows)

        # Si el SP devuelve Resultado/Mensaje por algún error lógico
        if len(data) == 1 and "Resultado" in data[0]:
            if data[0]["Resultado"] == 0:
                return jsonify({
                    "status": "error",
                    "message": data[0].get("Mensaje")
                }), 400

        connection.commit()

        return jsonify({
            "status": "success",
            "statements": data
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR GET STATEMENTS:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/getStatementMovements', methods=['GET'])
def getStatementMovements():
    user = request.args.get("user")
    statement_id = request.args.get("statementId")

    if not user or not statement_id:
        return jsonify({
            "status": "error",
            "message": "Faltan los parámetros user o statementId."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.GetMovimientosEstadoCuenta
                @inUser = ?,
                @inIdEstadoCuenta = ?
            """,
            user,
            int(statement_id)
        )

        rows = cursor.fetchall()

        if not cursor.description:
            return jsonify({
                "status": "success",
                "movements": []
            })

        data = rows_to_dicts(cursor, rows)

        # Si el SP devuelve Resultado/Mensaje por algún error lógico
        if len(data) == 1 and "Resultado" in data[0]:
            if data[0]["Resultado"] == 0:
                return jsonify({
                    "status": "error",
                    "message": data[0].get("Mensaje")
                }), 400

        connection.commit()

        return jsonify({
            "status": "success",
            "movements": data
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR GET MOVEMENTS:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/getAccountBeneficiaries/<account>', methods=['GET'])
def getAccountBeneficaries(account):
    return jsonify(BancoRepo.getBeneficiaries(account))

@app.route('/api/getPorcentaje/<cuenta>', methods=['GET'])
def getPorcentaje(cuenta):
    return jsonify(BancoRepo.getPorcentaje(cuenta))
    pass

@app.route('/api/getParentescos', methods=['GET'])
def getParentescos():
    return jsonify(BancoRepo.getParentescos())

@app.route('/api/getTipoDocId', methods=['GET'])
def getTipoDocId():
    return jsonify(BancoRepo.getTipoDocId())

@app.route('/api/updateAccountBeneficiary', methods=['POST'])
def updateAccountBeneficiary():
    req_data = request.get_json() or {}
    print(req_data)
    response = BancoRepo.updateBeneficiary(req_data["Id"], req_data["Porcentaje"], req_data["Nombre"], req_data["IdParentezco"], req_data["User"])
    return jsonify(response)

@app.route('/api/deleteBeneficiario', methods=['POST'])
def deleteBeneficiario():
    req_data = request.get_json() or {}
    response = BancoRepo.deleteBeneficario(req_data["Id"], req_data["User"])
    return jsonify(response)

@app.route('/api/getAccountBeneficiariesv2', methods=['GET'])
def getAccountBeneficiaries():
    account = request.args.get("account")

    if not account:
        return jsonify({
            "status": "error",
            "message": "Falta el parámetro account."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.GetAccountBeneficiaries
                @inCuenta = ?
            """,
            account
        )

        rows = cursor.fetchall()

        data = rows_to_dicts(cursor, rows)

        return jsonify({
            "status": "success",
            "beneficiaries": data
        })

    except Exception as error:
        print("ERROR GET BENEFICIARIES:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/addBeneficiary', methods=['POST'])
def addBeneficiary():
    req_data = request.get_json() or {}
    print(req_data)

    required_fields = [
        "user",
        "account",
        "document",
        "documentType",
        "name",
        "birthDate",
        "email",
        "phone",
        "relationshipId",
        "percentage"
    ]

    for field in required_fields:
        if req_data.get(field) is None:
            return jsonify({
                "status": "error",
                "message": f"Falta el campo {field}."
            }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.AgregarBeneficiario
                @inUser = ?,
                @inNumeroCuenta = ?,
                @inValorDocumentoIdentidad = ?,
                @inTipoDocuIdentidad = ?,
                @inNombre = ?,
                @inFechaNacimiento = ?,
                @inEmail = ?,
                @inTelefono = ?,
                @inTelefono2 = ?,
                @inIdParentezco = ?,
                @inPorcentaje = ?
            """,
            req_data.get("user"),
            req_data.get("account"),
            req_data.get("document"),
            req_data.get("documentType"),
            req_data.get("name"),
            req_data.get("birthDate"),
            req_data.get("email"),
            req_data.get("phone"),
            req_data.get("phone2"),
            req_data.get("relationshipId"),
            req_data.get("percentage")
        )

        row = cursor.fetchone()

        columns = [column[0] for column in cursor.description]
        result = dict(zip(columns, row))

        connection.commit()

        return jsonify({
            "status": "success" if result.get("Resultado") == 1 else "error",
            "data": result
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR ADD BENEFICIARY:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/updateBeneficiaryPercentage', methods=['PUT'])
def updateBeneficiaryPercentage():
    req_data = request.get_json() or {}

    user = req_data.get("user")
    account = req_data.get("account")
    beneficiary_id = req_data.get("beneficiaryId")
    percentage = req_data.get("percentage")

    if (
        user is None
        or account is None
        or beneficiary_id is None
        or percentage is None
    ):
        return jsonify({
            "status": "error",
            "message": "Faltan datos requeridos."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.ActualizarPorcentajeBeneficiario
                @inUser = ?,
                @inNumeroCuenta = ?,
                @inIdBeneficiario = ?,
                @inNuevoPorcentaje = ?
            """,
            user,
            account,
            beneficiary_id,
            percentage
        )

        row = cursor.fetchone()

        columns = [column[0] for column in cursor.description]
        result = dict(zip(columns, row))

        connection.commit()

        return jsonify({
            "status": "success" if result.get("Resultado") == 1 else "error",
            "data": result
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR UPDATE BENEFICIARY:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


@app.route('/api/deleteBeneficiary', methods=['DELETE'])
def deleteBeneficiary():
    req_data = request.get_json() or {}

    user = req_data.get("user")
    account = req_data.get("account")
    beneficiary_id = req_data.get("beneficiaryId")

    if user is None or account is None or beneficiary_id is None:
        return jsonify({
            "status": "error",
            "message": "Faltan datos requeridos."
        }), 400

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC dbo.DeleteBeneficiario
                @inUser = ?,
                @inNumeroCuenta = ?,
                @inIdBeneficiario = ?
            """,
            user,
            account,
            beneficiary_id
        )

        row = cursor.fetchone()

        columns = [column[0] for column in cursor.description]
        result = dict(zip(columns, row))

        connection.commit()

        return jsonify({
            "status": "success" if result.get("Resultado") == 1 else "error",
            "data": result
        })

    except Exception as error:
        if connection:
            connection.rollback()

        print("ERROR DELETE BENEFICIARY:", error)

        return jsonify({
            "status": "error",
            "message": str(error)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ==========================================
# 3. FRONTEND & SPA CATCH-ALL ROUTE
# ==========================================

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def catch_all(path):
    if path.startswith("api/"):
        return jsonify({"error": "API route not found"}), 404

    full_path = os.path.join(DIST_DIR, path)
    if path and os.path.isfile(full_path):       # isfile, not exists
        return send_from_directory(DIST_DIR, path)

    return send_from_directory(DIST_DIR, "index.html")

if __name__ == '__main__':
    CORS(app)
    app.run(port=5000, debug=True)
