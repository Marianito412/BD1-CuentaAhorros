CREATE OR ALTER PROCEDURE [dbo].[ProcesarPersona]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Personas TABLE (
        TipoDocuIdentidad       INT,
        Nombre                  VARCHAR(64),
        ValorDocumentoIdentidad VARCHAR(64),
        FechaNacimiento         DATE,
        Email                   VARCHAR(64),
        Telefono                VARCHAR(32),
        Telefono2               VARCHAR(32)
    );
    
    insert into @Personas
    SELECT
        F.f.value('@TipoDocuIdentidad', 'INT') AS TipoDocuIdentidad,
        F.f.value('@Nombre', 'varchar(64)') AS Nombre,
        F.f.value('@ValorDocumentoIdentidad', 'varchar(64)') AS ValorDocumentoIdentidad,
        F.f.value('@FechaNacimiento', 'DATE') AS Nacimiento,
        F.f.value('@Email', 'VARCHAR(64)') AS email,
        F.f.value('@telefono1', 'VARCHAR(32)') AS telefono1,
        F.f.value('@telefono2', 'VARCHAR(32)') AS telefono2
        --F.f.query('.') AS XmlDia
    FROM @XmlDia.nodes('/FechaOperacion/Persona') AS F(f)

    INSERT INTO Persona (
        TipoDocuIdentidad, Nombre, ValorDocumentoIdentidad,
        FechaNacimiento, Email, Telefono, Telefono2
    )
    SELECT
        TipoDocuIdentidad, Nombre, ValorDocumentoIdentidad,
        FechaNacimiento, Email, Telefono, Telefono2
    FROM @Personas;
    
    insert into Bitacora (IdUsuario, IdTipoOperacion, IP, DatosAntes, DatosDespues) 
    select 
        1 AS idUsuario,
        1 AS idTipoOperacion,
        '000.000.000' as IP,
        null as DatosAntes,
        (
            SELECT
                p.TipoDocuIdentidad,
                p.Nombre,
                p.ValorDocumentoIdentidad,
                p.FechaNacimiento,
                p.Email,
                p.Telefono,
                p.Telefono2
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as DatosDespues
    from @Personas p
    
    select * from Bitacora
    
    RETURN 0;
END
GO

DECLARE @xml XML;

SELECT @xml = CONVERT(XML, BulkColumn, 2)
FROM OPENROWSET(
             BULK 'E:\TEC\2026 SEMESTRE 2\Bases de Datos 1\Proyectos\Tarea2\OperacionesTarea3.xml',
             SINGLE_BLOB
     ) AS x;

DECLARE @FechaPrueba DATE = '2026-03-01';   -- <- the day to test
DECLARE @HacerRollback BIT = 0;

DECLARE @MiXml XML;

SELECT @MiXml = (
    SELECT F.f.query('.') AS [*]
    FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
    WHERE F.f.value('@Fecha', 'DATE') = @FechaPrueba
    FOR XML PATH(''), TYPE
);

SET @MiXml = COALESCE(@MiXml, CAST('<FechaOperacion/>' AS XML));

--SELECT @FechaPrueba AS Fecha,
--       @MiXml       AS XmlDelDia,
--       @MiXml.value('count(/FechaOperacion)',   'INT') AS NodosFechaOperacion,
--       @MiXml.value('count(/FechaOperacion/*)', 'INT') AS HijosTotales;

BEGIN TRANSACTION;
BEGIN TRY

    EXEC ProcesarPersona @XmlDia=@MiXml, @Fecha = @FechaPrueba
    -- EXEC dbo.ProcesarCuentas     @XmlDia = @MiXml, @Fecha = @FechaPrueba;
    -- EXEC dbo.ProcesarMovimientos @XmlDia = @MiXml, @Fecha = @FechaPrueba;

    /* ---------- 4) Check the results here ---------- */
    SELECT 'Persona' As Tabla, * FROM Persona;
    SELECT 'Bitacora' As Tabla, * FROM Bitacora;

    IF @HacerRollback = 1
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Rolled back: no changes were saved.';
        END
    ELSE
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'Committed.';
        END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS Numero, ERROR_MESSAGE() AS Mensaje, ERROR_LINE() AS Linea;
END CATCH;

--select * from Persona
--select * from TipoDocuIdentidad
--insert into TipoDocuIdentidad (Id, Nombre) Values(0, 'Pasaporte')
--insert into TipoDocuIdentidad (Id, Nombre) Values(1, 'Cédula')