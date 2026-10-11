CREATE PROCEDURE [dbo].[GetAccountStatements]
    @inUser VARCHAR(32),
    @inNumeroCuenta VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        DECLARE @IdUsuario INT;
        DECLARE @IdCuenta INT;
        DECLARE @EsAdministrador BIT;

        ------------------------------------------------------------
        -- 1. OBTENER USUARIO
        ------------------------------------------------------------

        SELECT
            @IdUsuario = U.Id,
            @EsAdministrador = U.flagEsAdministrador
        FROM dbo.Usuario AS U
        WHERE U.[User] = @inUser;


        IF @IdUsuario IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Usuario no encontrado.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 2. OBTENER CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = C.Id
        FROM dbo.Cuenta AS C
        WHERE C.NumeroCuenta = @inNumeroCuenta;


        IF @IdCuenta IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Cuenta no encontrada.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 3. VALIDAR PERMISO
        ------------------------------------------------------------

        IF ISNULL(@EsAdministrador, 0) = 0
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UsuarioVer AS UV
                WHERE UV.IdUsuario = @IdUsuario
                  AND UV.IdCuenta = @IdCuenta
            )
            BEGIN
                SELECT
                    0 AS Resultado,
                    'El usuario no tiene acceso a esta cuenta.' AS Mensaje;

                RETURN;
            END;
        END;


        ------------------------------------------------------------
        -- 4. REGISTRAR CONSULTA EN BITACORA
        -- TipoOperacion 7 = Consultar estado de cuenta
        ------------------------------------------------------------

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
            7,
            NULL,
            NULL,
            NULL,
            SYSDATETIME()
        );


        ------------------------------------------------------------
        -- 5. DEVOLVER LOS ULTIMOS 8 ESTADOS
        ------------------------------------------------------------

        SELECT TOP (8)
            EC.Id,
            C.NumeroCuenta,
            EC.FechaInicio,
            EC.FechaFin,
            EC.SaldoInicial,
            EC.SaldoFinal,
            EC.SaldoMinimo,
            EC.InteresesAcumulados,
            EC.CantidadRetiros,
            EC.CantidadDepositos,
            EC.CantidadSinpeEntrantes,
            EC.CantidadSinpeSalientes
        FROM dbo.EstadoCuenta AS EC

        INNER JOIN dbo.Cuenta AS C
            ON C.Id = EC.IdCuenta

        WHERE EC.IdCuenta = @IdCuenta

        ORDER BY
            EC.FechaFin DESC,
            EC.Id DESC;

    END TRY

    BEGIN CATCH

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO