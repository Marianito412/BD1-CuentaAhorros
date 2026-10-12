CREATE OR ALTER PROCEDURE dbo.ActualizarPorcentajeBeneficiario
    @inUser VARCHAR(32),
    @inNumeroCuenta VARCHAR(64),
    @inIdBeneficiario INT,
    @inNuevoPorcentaje INT
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

        IF @inNuevoPorcentaje <= 0 OR @inNuevoPorcentaje > 100
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
                   'El porcentaje debe estar entre 1 y 100.' AS Mensaje;
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
        SET Porcentaje = @inNuevoPorcentaje
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
            6,
            NULL,
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @inNuevoPorcentaje AS Porcentaje
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
            'Porcentaje actualizado correctamente.' AS Mensaje,
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
