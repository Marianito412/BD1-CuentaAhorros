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