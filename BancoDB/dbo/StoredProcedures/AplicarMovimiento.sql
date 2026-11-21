-- =============================================
-- Procedimiento: AplicarMovimiento
-- Descripcion: Aplica un movimiento a una cuenta.
-- Actualiza el saldo de la cuenta, registra el
-- movimiento con el saldo resultante y actualiza
-- el estado de cuenta cuyo rango de fechas incluye
-- la fecha del movimiento.
-- No abre una transaccion propia, debe llamarse
-- dentro de la transaccion del procedimiento que
-- lo invoca.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AplicarMovimiento]
    @inIdCuenta INT,
    @inIdTipoMovimiento INT,
    @inFecha DATE,
    @inMonto MONEY,
    @inDescripcion VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EsCredito BIT;
    DECLARE @SaldoActual MONEY;
    DECLARE @NuevoSaldo MONEY;

    ------------------------------------------------------------
    -- 1. VALIDAR TIPO DE MOVIMIENTO Y CUENTA
    ------------------------------------------------------------

    SELECT @EsCredito = TM.flagEsCredito
    FROM dbo.TipoMovimiento AS TM
    WHERE TM.Id = @inIdTipoMovimiento;

    IF @EsCredito IS NULL
        THROW 50001, 'Tipo de movimiento invalido.', 1;

    SELECT @SaldoActual = C.Saldo
    FROM dbo.Cuenta AS C
    WHERE C.Id = @inIdCuenta;

    IF @SaldoActual IS NULL
        THROW 50002, 'Cuenta no encontrada.', 1;


    ------------------------------------------------------------
    -- 2. CALCULAR EL NUEVO SALDO
    -- Los creditos suman al saldo y los debitos restan
    ------------------------------------------------------------

    IF @EsCredito = 1
        SET @NuevoSaldo = @SaldoActual + @inMonto;
    ELSE
        SET @NuevoSaldo = @SaldoActual - @inMonto;


    ------------------------------------------------------------
    -- 3. ACTUALIZAR SALDO Y REGISTRAR EL MOVIMIENTO
    ------------------------------------------------------------

    UPDATE dbo.Cuenta
    SET Saldo = @NuevoSaldo
    WHERE Id = @inIdCuenta;

    INSERT INTO dbo.Movimiento
    (
        IdCuenta,
        IdTipoMovimiento,
        Fecha,
        Monto,
        Descripcion,
        NuevoSaldo
    )
    VALUES
    (
        @inIdCuenta,
        @inIdTipoMovimiento,
        @inFecha,
        @inMonto,
        @inDescripcion,
        @NuevoSaldo
    );

    ------------------------------------------------------------
    -- 4. ACTUALIZAR EL ESTADO DE CUENTA DEL PERIODO
    -- Segun el catalogo de tipos de movimiento:
    --   1 Deposito Ventana y 5 Retiro Ventana  -> cajero humano
    --   2 Deposito ATM y 4 Retiro ATM          -> cajero automatico
    --   8 Deposito Sinpe y 9 Retiro Sinpe      -> Sinpe
    ------------------------------------------------------------

    UPDATE dbo.EstadoCuenta
    SET SaldoFinal = @NuevoSaldo,
        SaldoMinimo =
            CASE
                WHEN @NuevoSaldo < SaldoMinimo THEN @NuevoSaldo
                ELSE SaldoMinimo
            END,
        CantidadOperacionesATM = CantidadOperacionesATM +
            CASE
                WHEN @inIdTipoMovimiento IN (2, 4) THEN 1
                ELSE 0
            END,
        CantidadOperacionesHumano = CantidadOperacionesHumano +
            CASE
                WHEN @inIdTipoMovimiento IN (1, 5) THEN 1
                ELSE 0
            END,
        CantidadOperacionesSinpe = CantidadOperacionesSinpe +
            CASE
                WHEN @inIdTipoMovimiento = 9 THEN 1
                ELSE 0
            END
    WHERE IdCuenta = @inIdCuenta
      AND @inFecha BETWEEN FechaInicio AND FechaFin;

    ------------------------------------------------------------
    -- 5. AGREGAR COBRO DE COMISION POR EXCESO DE SIMPE DIARIO
    ------------------------------------------------------------
    
    IF @inIdTipoMovimiento = 9
        BEGIN
            DECLARE @IdTipoComision     INT = 10;
            DECLARE @LimiteSimpeDiario  INT   = 0;
            DECLARE @MontoComision      MONEY = 0;
            
            Select
                @LimiteSimpeDiario = TC.MontoMaxSinpeDiario,
                @MontoComision = TC.ComisionSinpe
            from Cuenta as C
            Inner join TipoCuentaAhorros as TC on TC.id = C.IdTipoCuenta
            where C.Id = @inIdCuenta 
            
            DECLARE @TotalSimpeHoy MONEY;

            SELECT @TotalSimpeHoy = SUM(M.Monto)
            FROM dbo.Movimiento AS M
            WHERE M.IdCuenta = @inIdCuenta
              AND M.Fecha = @inFecha
              AND M.IdTipoMovimiento = 9;

            -- El movimiento actual ya esta insertado, por eso va ">"
            IF @TotalSimpeHoy > @LimiteSimpeDiario
                BEGIN
                    -- Nuevo saldo despues de la comision
                    SET @NuevoSaldo = @NuevoSaldo - @MontoComision;

                    UPDATE dbo.Cuenta
                    SET Saldo = @NuevoSaldo
                    WHERE Id = @inIdCuenta;

                    INSERT INTO dbo.Movimiento
                    (IdCuenta, IdTipoMovimiento, Fecha, Monto, Descripcion, NuevoSaldo)
                    VALUES
                        (@inIdCuenta, @IdTipoComision, @inFecha, @MontoComision,
                         'Comision por exceso de operaciones SIMPE diarias', @NuevoSaldo);

                    UPDATE dbo.EstadoCuenta
                    SET SaldoFinal  = @NuevoSaldo,
                        SaldoMinimo = CASE WHEN @NuevoSaldo < SaldoMinimo THEN @NuevoSaldo ELSE SaldoMinimo END
                    WHERE IdCuenta = @inIdCuenta
                      AND @inFecha BETWEEN FechaInicio AND FechaFin;
                END
        END
    
    RETURN 0;
END;
