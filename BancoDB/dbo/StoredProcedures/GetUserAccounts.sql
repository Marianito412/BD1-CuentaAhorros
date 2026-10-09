CREATE OR ALTER PROCEDURE [dbo].[GetUserAccounts]
  @inUser VARCHAR(64) = 0
AS
BEGIN
  SET NOCOUNT ON
  SELECT 
      C.NumeroCuenta, 
      C.Saldo, 
      TC.Nombre, 
      TM.Simbolo 
  FROM UsuarioVer AS UV 
    INNER JOIN Cuenta AS C ON C.NumeroCuenta = UV.IdCuenta
    INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
    INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
  WHERE UV.IdUsuario = @inUser
END

SELECT * FROM UsuarioVer AS UV 
  INNER JOIN Cuenta AS C ON C.NumeroCuenta = UV.IdCuenta
  INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
  INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta

WHERE UV.IdUsuario = 'Mariano'

SELECT C.NumeroCuenta, C.Saldo, TC.Nombre, TM.Simbolo FROM UsuarioVer AS UV 
  INNER JOIN Cuenta AS C ON C.NumeroCuenta = UV.IdCuenta
  INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
  INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta

WHERE UV.IdUsuario = 'Mariano'

EXEC GetUserAccounts @inUser='Mariano'