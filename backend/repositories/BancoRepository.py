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
        print(result)
        
        if (result[0] == 1):
            print("success")
        else:
            print("failure")
        return True if result[0] else False
    
    def getAccounts(self, user):
        cursor = self.CreateCursor()
        cursor.execute("EXEC GetUserAccounts @inUser=?", (user))
        result = cursor.fetchall()
        self.DBConnection.commit()
        print(result)
        
        

BancoRepo = BancoRepository()