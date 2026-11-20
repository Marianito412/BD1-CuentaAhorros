CREATE OR ALTER PROCEDURE [dbo].[ProcesarUsuario]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Usuarios TABLE (
        [User] VARCHAR(32),
        Pass VARCHAR(64),
        IdPersona INT,
        flagEsAdministrador INT DEFAULT 0
    )
    
    insert into @Usuarios
    SELECT
        F.f.value('@User', 'varchar(32)') AS [User],
        F.f.value('@Pass', 'varchar(64)') AS Pass,
        P.Id,
        F.f.value('@EsAdministrador', 'BIT') AS flagEsAdministrador
    FROM @XmlDia.nodes('/FechaOperacion/Usuario') AS F(f)
    inner join Persona as P on P.ValorDocumentoIdentidad = F.f.value('@ValorDocId', 'varchar(64)')
    
    
    insert into Usuario ([User], Pass, IdPersona, flagEsAdministrador)
    select
        [User],
        Pass,
        IdPersona,
        flagEsAdministrador
    from @Usuarios
    
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