"""
Carga los catalogos de la tercera tarea (CatalogosTarea3.xml)
en la base de datos mediante el procedimiento CargarCatalogosXML.

Uso (desde la carpeta backend):
    python load_catalogos.py

La contrasena de la base se pide al ejecutar el script para no
dejarla escrita en el codigo.
"""

import getpass
import pyodbc

XML_PATH = "../CatalogosTarea3.xml"

SERVER = "marianito-edu.database.windows.net"
DATABASE = "PC-1"
USERNAME = "mariano"


def get_connection(password):
    connection_string = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID={USERNAME};"
        f"PWD={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=60;"
    )

    return pyodbc.connect(connection_string)


def leer_xml(ruta):
    with open(ruta, "r", encoding="utf-8-sig") as archivo:
        xml_data = archivo.read()

    # SQL Server no acepta la declaracion <?xml ... encoding="UTF-8"?>
    # cuando el texto se envia como unicode, por eso se quita
    if xml_data.lstrip().startswith("<?xml"):
        inicio = xml_data.find("<?xml")
        fin = xml_data.find("?>", inicio)

        if fin != -1:
            xml_data = xml_data[fin + 2:].lstrip()

    return xml_data


def main():
    xml_data = leer_xml(XML_PATH)

    password = getpass.getpass(f"Contrasena de {USERNAME} en {SERVER}: ")

    conexion = get_connection(password)
    cursor = conexion.cursor()

    try:
        print("Cargando catalogos...")

        cursor.execute(
            "EXEC dbo.CargarCatalogosXML @XmlDatos = ?",
            xml_data
        )

        fila = cursor.fetchone()

        if fila and fila[0] == 1:
            conexion.commit()
            print("Resultado:", fila[1])
        else:
            conexion.rollback()
            print("ERROR:", fila[1] if fila else "Sin respuesta del procedimiento")

    except Exception as error:
        conexion.rollback()
        print("ERROR DURANTE LA CARGA:")
        print(error)

    finally:
        cursor.close()
        conexion.close()


if __name__ == "__main__":
    main()