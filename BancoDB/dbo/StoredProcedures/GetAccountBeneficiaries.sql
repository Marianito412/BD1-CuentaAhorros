CREATE OR ALTER PROCEDURE dbo.GetAccountBeneficiaries
    @inCuenta VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        B.Id,
        C.NumeroCuenta,
        P.Nombre,
        P.ValorDocumentoIdentidad,
        P.FechaNacimiento,
        P.Email,
        P.Telefono,
        P.Telefono2,
        PA.Id AS IdParentezco,
        PA.Nombre AS Parentezco,
        B.Porcentaje
    FROM dbo.Cuenta C
    INNER JOIN dbo.Beneficiario B
        ON B.IdCuenta = C.Id
    INNER JOIN dbo.Persona P
        ON P.Id = B.IdBeneficiario
    INNER JOIN dbo.Parentezco PA
        ON PA.Id = B.IdParentezco
    WHERE C.NumeroCuenta = @inCuenta
      AND B.flagActivo = 1
    ORDER BY B.Id;
END;
GO
