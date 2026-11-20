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
    
    /*
    select B.Porcentaje, P.Nombre, C.NumeroCuenta, Pa.Nombre
    from @Beneficiarios AS B
    inner join Persona as P on P.id = B.IdBeneficiario
    inner join Cuenta as C on C.id = B.IdCuenta
    inner join Parentezco as Pa on Pa.id = B.IdParentezco
     */
    
    --insert into Cuenta(IdCliente, IdTipoCuenta, NumeroCuenta, FechaCreacion, Saldo) 
    --select IdCliente, idTipoCuenta, NumeroCuenta, FechaCreacion, Saldo 
    --from @Cuentas


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
    
    RETURN 0;
END
GO



select * from Beneficiario
--select * from Persona
--select * From Usuario
--select * from TipoDocuIdentidad
--insert into TipoDocuIdentidad (Id, Nombre) Values(0, 'Pasaporte')
--insert into TipoDocuIdentidad (Id, Nombre) Values(1, 'Cédula')