CREATE OR ALTER PROCEDURE dbo.Login
  @inUser VARCHAR (64),
  @inPass VARCHAR (64)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT CASE 
    WHEN EXISTS (
      SELECT 1 FROM dbo.Usuario 
      WHERE [User] = @inUser 
      AND Pass = @inPass
      ) THEN 1 
    ELSE 0 
  END AS PermitirLogin;
END

select * from dbo.Usuario AS U where U.[User] = 'Mariano'

EXEC dbo.Login @inUser = 'mariano', @inPass = 'hola123';

insert into dbo.Usuario ([User], Pass)
values('Mariano', 'hola123')

insert into dbo.Usuario ([User], Pass)
values('JohnDoe', 'coolpassword')