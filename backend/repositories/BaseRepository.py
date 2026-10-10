import mssql_python


class BaseRepository:
    def __init__(self):
        server = "marianito-edu.database.windows.net"
        database = "PC-1"
        username = "mariano"
        password = "Password1"

        conn_str = f"SERVER={server};DATABASE={database};UID={username};PWD={password};"

        self.DBConnection = mssql_python.connect(conn_str, timeout=60)
        print("Connection opened!")

    def CreateCursor(self):
        return self.DBConnection.cursor()

    def InsertarEmpleado(self, Nombre: str, Salario: float):
        cursor = self.CreateCursor()

        cursor.execute(
            f"EXEC InsertarEmpleado @Nombre='{Nombre}', @Salario={Salario}"
        )

        row = cursor.fetchone()

        self.DBConnection.commit()

        return row.Codigo

    def GetEmpleados(self):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetEmpleados")
        rows = cursor.fetchall()

        result = [
            {
                "id": row.id,
                "nombre": row.Nombre,
                "salario": row.Salario
            }
            for row in rows
        ]
        return result

    def __del__(self):
        pass
        self.DBConnection.close()
        print("Connection closed!")


#Repo = BaseRepository()