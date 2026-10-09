CREATE OR ALTER PROCEDURE [dbo].[GetAccountBeneficiaries] 
    @inCuenta VARCHAR(64) = 0
AS
BEGIN
    SET NOCOUNT ON
    SELECT C.NumeroCuenta,
           P.Email,
           PT.Nombre,
           B.Porcentaje
    FROM Cuenta AS C
             INNER JOIN dbo.Beneficiario B ON C.NumeroCuenta = B.IdCuenta
             INNER JOIN dbo.Persona P on P.ValorDocumentoIdentidad = B.IdBeneficiario
             INNER JOIN dbo.Parentezco PT on PT.Id = B.IdParentezco

             INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
             INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
    WHERE C.NumeroCuenta = @inCuenta AND B.flagActivo=1
END

