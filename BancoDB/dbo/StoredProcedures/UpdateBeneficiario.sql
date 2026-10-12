CREATE OR ALTER PROCEDURE [dbo].[UpdateBeneficiario]
    @inId INT,
    @inPorcentaje INT,
    @inNombre VARCHAR(64),
    @inParentesco INT 
AS
BEGIN
    SET NOCOUNT ON
        
    IF NOT EXISTS (SELECT 1 FROM Beneficiario WHERE Id = @inId)
        THROW 50001, 'Beneficiario invalido.', 1;
    
    IF NOT EXISTS (SELECT 1 FROM Parentezco WHERE Id = @inParentesco)
        THROW 50002, 'Parentesco invalido.', 1;
    
    BEGIN TRY
        BEGIN TRAN;
        
        -- Actualizar Parentezco
        update Beneficiario
        SET IdParentezco = @inParentesco
        where Id = @inId

        -- Actualizar porcentaje
        update Beneficiario
        SET Porcentaje = @inPorcentaje
        where Id = @inId

        -- Actualizar Nombre de persona
        update P
        SET Nombre = @inNombre
        FROM Persona as P
        INNER JOIN Beneficiario AS B ON B.IdBeneficiario = P.Id
        where B.Id = @inId
            
        COMMIT
        SELECT 0 AS Codigo
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;  -- re-raise the original error to the caller
    END CATCH 
END

select * from Beneficiario where Id=25

select NumeroCuenta from Beneficiario as B
    inner join Cuenta as C On C.Id = B.IdCuenta 
    
EXEC dbo.UpdateBeneficiario @inId = 25, @inPorcentaje = 34, @inNombre = 'Lucia Soto Calderon', @inParentesco = 8