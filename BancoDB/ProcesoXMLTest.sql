



--delete from Beneficiario where 1=1
--delete from UsuarioVer where 1=1
--delete from Cuenta where 1=1
--delete from Usuario where Id!=1
--delete from Persona where Id!=36

--select * from Persona

--select * from Persona where ValorDocumentoIdentidad='401230456'
--select * from Persona
--select * from Cuenta
--select * from Usuario

--select * from TipoCuentaAhorros
--insert into TipoCuentaAhorros (Id, Nombre, IdTipoMoneda, SaldoMinimo, MultaSaldoMin, CargoAnual, 
--                               NumRetiroHumano, NumRetiroAutomatico, ComisionHumano, ComisionAutomatico, Interes)
--values(4, 'AhorroDolares', 2, 100, 5, 10, 5, 8, 1, 1, 3)

--select * from Persona

DECLARE @xml XML;
DECLARE @HacerRollback BIT = 1;
DECLARE @ProbarTodo BIT = 1;

SELECT @xml = CONVERT(XML, BulkColumn, 2)
FROM OPENROWSET(
             BULK 'E:\TEC\2026 SEMESTRE 2\Bases de Datos 1\Proyectos\Tarea2\OperacionesTarea3.xml',
             SINGLE_BLOB
     ) AS x;


IF @ProbarTodo=0
BEGIN
    DECLARE @FechaPrueba DATE = '2026-04-20';   -- <- the day to test
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
        EXEC ProcesarMovimiento @XmlDia=@MiXml, @Fecha = @FechaPrueba
        
        select C.NumeroCuenta, T.Nombre, M.Fecha, M.Monto from Movimiento as M
        inner join Cuenta as C on C.id = M.IdCuenta
        inner join TipoMovimiento as T on T.id = M.IdTipoMovimiento
        
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
END
ELSE 
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        exec ProcesarOperaciones @XmlDatos = @xml
    
        /* ---------- 4) Check the results here ---------- */
        select C.NumeroCuenta, T.Nombre, M.Fecha, M.Monto from Movimiento as M
        inner join Cuenta as C on C.id = M.IdCuenta
        inner join TipoMovimiento as T on T.id = M.IdTipoMovimiento
        
        --select * from EstadoCuenta
        
        ROLLBACK TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT ERROR_NUMBER() AS Numero, ERROR_MESSAGE() AS Mensaje, ERROR_LINE() AS Linea;
    END CATCH;
END