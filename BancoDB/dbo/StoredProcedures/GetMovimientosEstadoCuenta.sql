CREATE OR ALTER PROCEDURE [dbo].[GetMovimientosEstadoCuenta]
    @inUser VARCHAR(32),
    @inIdEstadoCuenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        DECLARE @IdUsuario INT;
        DECLARE @EsAdministrador BIT;
        DECLARE @IdCuenta INT;
        DECLARE @FechaInicio DATE;
        DECLARE @FechaFin DATE;

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
        -- 2. OBTENER ESTADO DE CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = EC.IdCuenta,
            @FechaInicio = EC.FechaInicio,
            @FechaFin = EC.FechaFin
        FROM dbo.EstadoCuenta AS EC
        WHERE EC.Id = @inIdEstadoCuenta;


        IF @IdCuenta IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Estado de cuenta no encontrado.' AS Mensaje;

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
        -- TipoOperacion 8 = Consultar movimientos de estado de cuenta
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
            8,
            NULL,
            NULL,
            NULL,
            SYSDATETIME()
        );


        ------------------------------------------------------------
        -- 5. DEVOLVER LOS MOVIMIENTOS DEL PERIODO
        -- En orden cronologico, en la moneda de la cuenta
        ------------------------------------------------------------

        SELECT
            M.Id,
            M.Fecha,
            TMV.Nombre AS TipoMovimiento,
            TMV.flagEsCredito,
            M.Monto,
            TM.Simbolo,
            M.Descripcion,
            M.NuevoSaldo
        FROM dbo.Movimiento AS M

        INNER JOIN dbo.TipoMovimiento AS TMV
            ON TMV.Id = M.IdTipoMovimiento

        INNER JOIN dbo.Cuenta AS C
            ON C.Id = M.IdCuenta

        INNER JOIN dbo.TipoCuentaAhorros AS TC
            ON TC.Id = C.IdTipoCuenta

        INNER JOIN dbo.TipoMoneda AS TM
            ON TM.Id = TC.IdTipoMoneda

        WHERE M.IdCuenta = @IdCuenta
          AND M.Fecha BETWEEN @FechaInicio AND @FechaFin

        ORDER BY
            M.Fecha ASC,
            M.Id ASC;

    END TRY

    BEGIN CATCH

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;
