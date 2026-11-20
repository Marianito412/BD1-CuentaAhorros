CREATE OR ALTER PROCEDURE [dbo].[ProcesarUsuarioVer]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UsuarioVer TABLE (
        [User] VARCHAR(32),
        NumeroCuenta VARCHAR(64)
    )
    
    insert into @UsuarioVer
    SELECT
        F.f.value('@User', 'varchar(32)') AS [User],
        F.f.value('@NumeroCuenta', 'varchar(64)') AS Pass
    FROM @XmlDia.nodes('/FechaOperacion/UsuarioPuedeVer') AS F(f)
    
    insert into UsuarioVer (IdUsuario, IdCuenta) 
    select U.Id, C.Id
    from @UsuarioVer as UV
    inner join Usuario as U on U.[User] = UV.[User]
    inner join Cuenta as C on C.NumeroCuenta = UV.NumeroCuenta
    
    
    --insert into Cuenta(IdCliente, IdTipoCuenta, NumeroCuenta, FechaCreacion, Saldo) 
    --select IdCliente, idTipoCuenta, NumeroCuenta, FechaCreacion, Saldo 
    --from @Cuentas

    /*
    insert into Bitacora (IdUsuario, IdTipoOperacion, IP, DatosAntes, DatosDespues)
    select
        1 AS idUsuario,
        3 AS idTipoOperacion,
        '000.000.000' as IP,
        null as DatosAntes,
        (
            SELECT
                B.IdCuenta,
                B.IdBeneficiario,
                B.IdParentezco,
                B.Porcentaje,
                B.flagActivo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as DatosDespues
    from @Beneficiarios B
     */
    
    RETURN 0;
END
GO