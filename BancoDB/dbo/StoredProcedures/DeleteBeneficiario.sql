CREATE OR ALTER PROCEDURE [dbo].[DeleteBeneficiario]
    @inId INT
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT 1 FROM Beneficiario WHERE Id=@inId)
        THROW 50001, 'Beneficiario invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Beneficiario WHERE Id = @inId AND flagActivo = 1)
        THROW 50002, 'El beneficiario ya esta inactivo.', 1;
        
    UPDATE Beneficiario
    SET flagActivo = 0, FechaDesactivacion = SYSDATETIME()
    WHERE Id = @inId
    
    SELECT 0 AS Codigo
END


select * from Beneficiario where flagActivo=0

update Beneficiario
SET flagActivo=1
where Id = 47