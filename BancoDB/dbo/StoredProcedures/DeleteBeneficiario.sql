
CREATE OR ALTER PROCEDURE [dbo].[DeleteBeneficiario]
    @inId INT,
    @inUsuario VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT 1 FROM Beneficiario WHERE Id=@inId)
        THROW 50001, 'Beneficiario invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Beneficiario WHERE Id = @inId AND flagActivo = 1)
        THROW 50002, 'El beneficiario ya esta inactivo.', 1;
        
    UPDATE Beneficiario
    SET flagActivo = 0, FechaDesactivacion = SYSDATETIME()
    WHERE Id = @inId
    
    SELECT 0 AS Codigo
END


select * from Beneficiario where flagActivo=0

update Beneficiario
SET flagActivo=1
where Id = 47

CREATE OR ALTER PROCEDURE dbo.DeleteBeneficiario
    @inUser VARCHAR(32),
    @inNumeroCuenta VARCHAR(64),
    @inIdBeneficiario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdUsuario INT;
        DECLARE @IdCuenta INT;
        DECLARE @EsAdministrador BIT;
        DECLARE @PorcentajeAnterior INT;
        DECLARE @SumaPorcentajes INT;

        SELECT
            @IdUsuario = Id,
            @EsAdministrador = flagEsAdministrador
        FROM dbo.Usuario
        WHERE [User] = @inUser;

        IF @IdUsuario IS NULL
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado, 'Usuario no encontrado.' AS Mensaje;
            RETURN;
        END;

        SELECT @IdCuenta = Id
        FROM dbo.Cuenta
        WHERE NumeroCuenta = @inNumeroCuenta;

        IF @IdCuenta IS NULL
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado, 'Cuenta no encontrada.' AS Mensaje;
            RETURN;
        END;

        IF @EsAdministrador = 0
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.UsuarioVer
               WHERE IdUsuario = @IdUsuario
                 AND IdCuenta = @IdCuenta
           )
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
                   'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
            RETURN;
        END;

        SELECT @PorcentajeAnterior = Porcentaje
        FROM dbo.Beneficiario
        WHERE Id = @inIdBeneficiario
          AND IdCuenta = @IdCuenta
          AND flagActivo = 1;

        IF @PorcentajeAnterior IS NULL
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
                   'Beneficiario activo no encontrado.' AS Mensaje;
            RETURN;
        END;

        UPDATE dbo.Beneficiario
        SET
            flagActivo = 0,
            FechaDesactivacion = SYSDATETIME()
        WHERE Id = @inIdBeneficiario;

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            5,
            NULL,
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje,
                    1 AS flagActivo
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje,
                    0 AS flagActivo
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            SYSDATETIME()
        );

        SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
        FROM dbo.Beneficiario
        WHERE IdCuenta = @IdCuenta
          AND flagActivo = 1;

        COMMIT;

        SELECT
            1 AS Resultado,
            'Beneficiario eliminado correctamente.' AS Mensaje,
            @SumaPorcentajes AS SumaPorcentajes,
            CASE
                WHEN @SumaPorcentajes = 100 THEN 1
                ELSE 0
            END AS PorcentajesCompletos;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO
