CREATE OR ALTER PROCEDURE [dbo].[GetParentescos] 
AS
BEGIN
    SET NOCOUNT ON
    SELECT Id, Nombre FROM Parentezco
END

EXEC GetParentescos