from .BaseRepository import BaseRepository

class BancoRepository(BaseRepository):

    def __init__(self):
        super().__init__()

    def login(self, user, password):
        cursor = self.CreateCursor()
        # EXEC dbo.Login @inUser = 'mariano', @inPass = 'hola123';
        cursor.execute("EXEC dbo.Login @inUser = ?, @inPass = ?;", (user, password))
        result = cursor.fetchone()
        self.DBConnection.commit()
        cursor.close()
        print(result)
        
        if (result[0] == 1):
            print("success")
        else:
            print("failure")
        return True if result[0] else False
    
    def updateBeneficiary(self, id, porcentaje, nombre, parentesco):
        cursor = self.CreateCursor()
        #print(id, type(id) , nombre, type(nombre), porcentaje, type(porcentaje), parentesco, type(parentesco))
        
        cursor.execute("EXEC dbo.UpdateBeneficiario @inId=?, @inPorcentaje=?, @inNombre=?, @inParentesco=?", (int(id), int(porcentaje), str(nombre), int(parentesco)))
        result = cursor.fetchone()
        self.DBConnection.commit()
        cursor.close()
        
        return result[0]
    
    def deleteBeneficario(self, id):
        cursor = self.CreateCursor()
        cursor.execute("EXEC dbo.deleteBeneficiario @inId=?", (id))
        result = cursor.fetchone()
        self.DBConnection.commit()
        cursor.close()

        return result[0]
    
    def getAccounts(self, user):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetUserAccounts @inUser=?", (user))
        result = cursor.fetchall()
        self.DBConnection.commit()
        print(result)
        cursor.close()
        
    def getPorcentaje(self, cuenta):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetPorcentajeBeneficiarios @inCuenta=?", (cuenta))

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]

        self.DBConnection.commit()
        cursor.close()
        return results
        
    def getBeneficiaries(self, account):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetAccountBeneficiaries @inCuenta=?", (account))
        
        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        self.DBConnection.commit()
        cursor.close()
        return results

    def getTipoDocId(self):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetTipoDocId")

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]

        self.DBConnection.commit()
        cursor.close()
        return results
        
    def getParentescos(self):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetParentescos")
        
        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        self.DBConnection.commit()
        cursor.close()
        return results

    def addBeneficiary(self, user, cuenta, documento, tipo_doc, nombre,
                       fecha_nac, email, tel1, tel2, parentesco, porcentaje):
        cursor = self.CreateCursor()
        try:
            cursor.execute(
                "EXEC dbo.AgregarBeneficiario "
                "@inUser=?, @inNumeroCuenta=?, @inValorDocumentoIdentidad=?, "
                "@inTipoDocuIdentidad=?, @inNombre=?, @inFechaNacimiento=?, "
                "@inEmail=?, @inTelefono=?, @inTelefono2=?, "
                "@inIdParentezco=?, @inPorcentaje=?",
                (str(user), str(cuenta), str(documento), int(tipo_doc), str(nombre),
                 fecha_nac, str(email), str(tel1), str(tel2),
                 int(parentesco), int(porcentaje))
            )
            row = cursor.fetchone()
            self.DBConnection.commit()
            return {"ok": row.Resultado == 1, "mensaje": row.Mensaje}
        finally:
            cursor.close()

BancoRepo = BancoRepository()