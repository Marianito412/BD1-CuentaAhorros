import os
import pyodbc

XML_PATH = "../OperacionesTarea3.xml"

#SERVER = os.getenv("DB_SERVER")
#DATABASE = os.getenv("DB_DATABASE")
#USERNAME = os.getenv("DB_USER")
#PASSWORD = os.getenv("DB_PASSWORD")

SERVER = "MARIANOPC\SQLEXPRESS" #os.getenv("DB_SERVER")
DATABASE = "BancoDBLocal"#os.getenv("DB_DATABASE")
USERNAME = "Marianito"#os.getenv("DB_USER")
PASSWORD = "Password1"#os.getenv("DB_PASSWORD")

if not all([SERVER, DATABASE, USERNAME, PASSWORD]):
    raise Exception(
        "Faltan variables de entorno: "
        "DB_SERVER, DB_DATABASE, DB_USER, DB_PASSWORD"
    )

with open(XML_PATH, "r", encoding="utf-8-sig") as archivo:
    xml_data = archivo.read()

# Quitar cualquier declaración XML del inicio
if xml_data.lstrip().startswith("<?xml"):
    inicio = xml_data.find("<?xml")
    fin = xml_data.find("?>", inicio)

    if fin != -1:
        xml_data = xml_data[fin + 2:].lstrip()

print("Primeros caracteres enviados a SQL:")
print(repr(xml_data[:80]))

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    #f"UID={USERNAME};"
    #f"PWD={PASSWORD};"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
    "Trusted_Connection=yes;"
    "Connection Timeout=60;"
)

print("Conectando a Azure SQL...")

conexion = pyodbc.connect(connection_string)
cursor = conexion.cursor()

try:
    print("Cargando no_catalogos.xml...")

    cursor.execute(
       "EXEC dbo.ProcesarOperaciones @XmlDatos = ?",
        xml_data
    )

    filas = cursor.fetchall()

    for fila in filas:
        if fila:
            print("Resultado:", fila)
            #print("Mensaje:", fila[1])

    conexion.commit()

    print("Carga finalizada correctamente.")

except Exception as error:
    conexion.rollback()
    print("ERROR DURANTE LA CARGA:")
    print(error)

finally:
    cursor.close()
    conexion.close()