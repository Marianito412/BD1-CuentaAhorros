CREATE OR ALTER PROCEDURE dbo.GetPorcentajeBeneficiarios
    @inCuenta VARCHAR(64)
AS
BEGIN
    SELECT SUM(Porcentaje) AS Total 
    FROM Beneficiario as B
    INNER JOIN Cuenta AS C ON C.Id = B.IdCuenta 
    WHERE C.NumeroCuenta = @inCuenta AND B.flagActivo = 1
END


SELECT Porcentaje FROM Beneficiario as B
WHERE IdCuenta = 3

-- EXEC GetPorcentajeBeneficiarios @inCuenta = '11000010'
    