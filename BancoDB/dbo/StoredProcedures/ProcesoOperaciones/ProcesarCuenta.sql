CREATE OR ALTER PROCEDURE [dbo].[ProcesarCuenta]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Cuentas TABLE (
        IdCliente INT,
        idTipoCuenta INT,
        NumeroCuenta varchar(64),
        FechaCreacion DATE,
        Saldo MONEY
    )
    
    Insert into @Cuentas
    SELECT
        P.Id,
        F.f.value('@TipoCuentaId', 'INT') AS IdTipoCuenta,
        F.f.value('@NumeroCuenta', 'varchar(64)') AS NumeroCuenta,
        F.f.value('@FechaCreacion', 'Date') AS FechaCreacion,
        F.f.value('@Saldo', 'Money') as Saldo
        
    FROM @XmlDia.nodes('/FechaOperacion/Cuenta') AS F(f)
    inner join Persona as P on P.ValorDocumentoIdentidad = F.f.value('@ValorDocumentoIdentidadDelCliente', 'varchar(64)')
    
    insert into Cuenta(IdCliente, IdTipoCuenta, NumeroCuenta, FechaCreacion, Saldo) 
    select IdCliente, idTipoCuenta, NumeroCuenta, FechaCreacion, Saldo 
    from @Cuentas

    /*
    insert into Bitacora (IdUsuario, IdTipoOperacion, IP, DatosAntes, DatosDespues)
    select
        1 AS idUsuario,
        1 AS idTipoOperacion,
        '000.000.000' as IP,
        null as DatosAntes,
        (
            SELECT
                c.IdCliente,
                c.idTipoCuenta,
                c.NumeroCuenta,
                c.FechaCreacion,
                c.Saldo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as DatosDespues
    from @Cuentas C
    */
    
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
DECLARE @HacerRollback BIT = 1;

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
    EXEC ProcesarCuenta @XmlDia=@MiXml, @Fecha = @FechaPrueba

    /* ---------- 4) Check the results here ---------- */
    --SELECT 'Persona' As Tabla, * FROM Persona;
    --SELECT 'Bitacora' As Tabla, * FROM Bitacora;

    select C.NumeroCuenta, P.Nombre from Cuenta as C
    inner join Persona as P on P.Id = C.IdCliente
    --select * from Bitacora
    
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

--select * From Usuario
--select * from TipoDocuIdentidad
--insert into TipoDocuIdentidad (Id, Nombre) Values(0, 'Pasaporte')
--insert into TipoDocuIdentidad (Id, Nombre) Values(1, 'Cédula')