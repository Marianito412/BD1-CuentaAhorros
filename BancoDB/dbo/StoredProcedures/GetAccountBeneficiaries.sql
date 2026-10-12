CREATE OR ALTER PROCEDURE [dbo].[GetAccountBeneficiaries] 
    @inCuenta VARCHAR(64) = 0
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        B.Id AS Id,
        P.Nombre AS Nombre,
        TD.Nombre AS DocuID,
        P.TipoDocuIdentidad AS TipoDocuIdentidad,
        TD.Nombre AS NombreDocuIdentidad,
        B.IdParentezco AS IdParentezco,
        PT.Nombre AS NombreParentezco,
        B.Porcentaje AS Porcentaje,
        P.Email AS Email,
        P.FechaNacimiento AS FechaNacimiento,
        P.ValorDocumentoIdentidad AS IdBeneficiario,
        P.Telefono AS Telefono,
        P.Telefono2 AS Telefono2
        
    FROM Cuenta AS C
        INNER JOIN dbo.Beneficiario B ON C.Id = B.IdCuenta
        INNER JOIN dbo.Persona P on P.Id = B.IdBeneficiario
        INNER JOIN dbo.TipoDocuIdentidad TD ON TD.Id = P.TipoDocuIdentidad
        INNER JOIN dbo.Parentezco PT on PT.Id = B.IdParentezco

        INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
        INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
    WHERE C.NumeroCuenta = @inCuenta
        AND B.flagActivo = 1
END

exec GetAccountBeneficiaries @inCuenta = '11000010'

SELECT C.NumeroCuenta,
       P.Email,
       PT.Nombre,
       B.Porcentaje
FROM Cuenta AS C
         INNER JOIN dbo.Beneficiario B ON C.Id = B.IdCuenta
         INNER JOIN dbo.Persona P on P.Id = B.IdBeneficiario
         INNER JOIN dbo.Parentezco PT on PT.Id = B.IdParentezco

         INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
         INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
WHERE C.NumeroCuenta = '11000010' AND B.flagActivo=1

select * from Beneficiario as B
    Inner Join Cuenta as C On C.Id = B.IdCuenta
Where C.NumeroCuenta = '11000010'

select * from Cuenta

select * from Beneficiario