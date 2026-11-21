CREATE OR ALTER PROCEDURE [dbo].[ProcesarBeneficiario]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Beneficiarios TABLE (
        IdCuenta INT,
        IdBeneficiario INT,
        IdParentezco INT,
        Porcentaje INT,
        flagActivo INT DEFAULT 1, 
        FechaDesactivacion DATE DEFAULT NULL
    )
    
    insert into @Beneficiarios
    SELECT
        C.Id,
        P.Id,
        F.f.value('@IdParentezco', 'INT') AS IdParentezco,
        F.f.value('@Porcentaje', 'INT') as Porcentaje,
        1 AS flagActivo,
        NULL AS FechaDesactivacion
    FROM @XmlDia.nodes('/FechaOperacion/Beneficiario') AS F(f)
    inner join Cuenta as C on C.NumeroCuenta = F.f.value('@NumeroCuenta', 'varchar(64)')
    inner join Persona as P on P.ValorDocumentoIdentidad = F.f.value('@ValorDocumentoIdentidadBeneficiario', 'varchar(64)')
    
    RETURN 0;
END
GO