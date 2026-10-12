CREATE OR ALTER PROCEDURE [dbo].[GetTipoDocId] 
AS
BEGIN
    SET NOCOUNT ON
    SELECT Id, Nombre FROM TipoDocuIdentidad
END

-- EXEC GetTipoDocId