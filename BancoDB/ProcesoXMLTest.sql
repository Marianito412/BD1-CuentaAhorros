
--delete from Persona where Id!=36
--delete from Usuario where Id!=1
--delete from UsuarioVer
--delete from Beneficiario
--select * from Persona
--select * from Cuenta
--select * from Usuario

select * from TipoCuentaAhorros

DECLARE @xml XML;
DECLARE @HacerRollback BIT = 1;

SELECT @xml = CONVERT(XML, BulkColumn, 2)
FROM OPENROWSET(
             BULK 'E:\TEC\2026 SEMESTRE 2\Bases de Datos 1\Proyectos\Tarea2\OperacionesTarea3.xml',
             SINGLE_BLOB
     ) AS x;

BEGIN TRANSACTION;
BEGIN TRY

    exec ProcesarOperaciones @XmlDatos = @xml

    /* ---------- 4) Check the results here ---------- */
    
    select U.[User], C.NumeroCuenta
    from UsuarioVer as UV
    inner join Usuario as U on U.Id = UV.IdUsuario
    inner join Cuenta as C on C.Id = UV.IdCuenta


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

/*
DECLARE @FechaPrueba DATE = '2026-03-01';   -- <- the day to test

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
    EXEC ProcesarBeneficiario @XmlDia=@MiXml, @Fecha = @FechaPrueba
    EXEC ProcesarUsuario @XmlDia=@MiXml, @Fecha = @FechaPrueba
    EXEC ProcesarUsuarioVer @XmlDia=@MiXml, @Fecha = @FechaPrueba
    
    /* ---------- 4) Check the results here ---------- */
    select U.[User], C.NumeroCuenta
    from UsuarioVer as UV
    inner join Usuario as U on U.Id = UV.IdUsuario
    inner join Cuenta as C on C.Id = UV.IdCuenta

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

*/