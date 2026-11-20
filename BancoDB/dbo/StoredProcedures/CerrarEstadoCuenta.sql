-- =============================================
-- Procedimiento: CerrarEstadoCuenta
-- Descripcion: Cierra un estado de cuenta en su
-- fecha final. Genera los movimientos de cierre
-- (intereses, comisiones por exceso de operaciones,
-- multa por saldo minimo y cargo por servicio) y
-- abre el estado de cuenta del siguiente periodo.
-- Todo se hace en una sola transaccion por cuenta.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[CerrarEstadoCuenta]
    @inIdEstadoCuenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCuenta INT;
    DECLARE @FechaCierre DATE;
    DECLARE @SaldoMinimoMes MONEY;
    DECLARE @CantidadATM INT;
    DECLARE @CantidadHumano INT;

    DECLARE @SaldoMinimoPermitido MONEY;
    DECLARE @MultaSaldoMin MONEY;
    DECLARE @CargoMensual MONEY;
    DECLARE @NumRetiroHumano INT;
    DECLARE @NumRetiroAutomatico INT;
    DECLARE @ComisionHumano MONEY;
    DECLARE @ComisionAutomatico MONEY;
    DECLARE @TasaInteresAnual DECIMAL(10, 4);

    DECLARE @Monto MONEY;

    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. DATOS DEL ESTADO DE CUENTA Y DE SU TIPO DE CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = EC.IdCuenta,
            @FechaCierre = EC.FechaFin,
            @SaldoMinimoMes = EC.SaldoMinimo,
            @CantidadATM = EC.CantidadOperacionesATM,
            @CantidadHumano = EC.CantidadOperacionesHumano,
            @SaldoMinimoPermitido = TC.SaldoMinimo,
            @MultaSaldoMin = TC.MultaSaldoMin,
            @CargoMensual = TC.CargoMensual,
            @NumRetiroHumano = TC.NumRetiroHumano,
            @NumRetiroAutomatico = TC.NumRetiroAutomatico,
            @ComisionHumano = TC.ComisionHumano,
            @ComisionAutomatico = TC.ComisionAutomatico,
            @TasaInteresAnual = TC.TasaInteresAnual
        FROM dbo.EstadoCuenta AS EC
        INNER JOIN dbo.Cuenta AS C
            ON C.Id = EC.IdCuenta
        INNER JOIN dbo.TipoCuentaAhorros AS TC
            ON TC.Id = C.IdTipoCuenta
        WHERE EC.Id = @inIdEstadoCuenta;

        IF @IdCuenta IS NULL
            THROW 50003, 'Estado de cuenta no encontrado.', 1;


        ------------------------------------------------------------
        -- 2. INTERESES SOBRE EL SALDO MINIMO DEL MES
        -- La tasa es anual y en porcentaje, se aplica la de un mes
        ------------------------------------------------------------

        SET @Monto = ROUND(@SaldoMinimoMes * @TasaInteresAnual / 100 / 12, 2);

        IF @Monto > 0
            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 12,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Intereses del mes';


        ------------------------------------------------------------
        -- 3. COMISION POR EXCESO DE OPERACIONES EN CAJERO AUTOMATICO
        ------------------------------------------------------------

        IF @CantidadATM > @NumRetiroAutomatico
        BEGIN
            SET @Monto = (@CantidadATM - @NumRetiroAutomatico) * @ComisionAutomatico;

            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 7,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Comision por exceso de operaciones en cajero automatico';
        END;


        ------------------------------------------------------------
        -- 4. COMISION POR EXCESO DE OPERACIONES EN CAJERO HUMANO
        ------------------------------------------------------------

        IF @CantidadHumano > @NumRetiroHumano
        BEGIN
            SET @Monto = (@CantidadHumano - @NumRetiroHumano) * @ComisionHumano;

            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 6,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Comision por exceso de operaciones en ventana';
        END;


        ------------------------------------------------------------
        -- 5. MULTA POR SALDO MINIMO
        -- Si en algun momento del mes el saldo bajo del minimo
        -- permitido por el tipo de cuenta
        ------------------------------------------------------------

        IF @SaldoMinimoMes < @SaldoMinimoPermitido
            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 16,
                @inFecha = @FechaCierre,
                @inMonto = @MultaSaldoMin,
                @inDescripcion = 'Multa por saldo minimo';


        ------------------------------------------------------------
        -- 6. CARGO POR SERVICIO MENSUAL
        ------------------------------------------------------------

        EXEC dbo.AplicarMovimiento
            @inIdCuenta = @IdCuenta,
            @inIdTipoMovimiento = 11,
            @inFecha = @FechaCierre,
            @inMonto = @CargoMensual,
            @inDescripcion = 'Cargo por servicio mensual';


        ------------------------------------------------------------
        -- 7. ABRIR EL ESTADO DE CUENTA DEL SIGUIENTE PERIODO
        ------------------------------------------------------------

        EXEC dbo.AbrirEstadoCuenta
            @inIdCuenta = @IdCuenta,
            @inFechaCierre = @FechaCierre;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;
