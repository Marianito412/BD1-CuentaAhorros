-- =============================================
-- Procedimiento: AbrirEstadoCuenta
-- Descripcion: Abre el estado de cuenta del
-- siguiente periodo de una cuenta. El periodo
-- empieza el dia despues del cierre y termina
-- el mismo dia del mes en que se creo la cuenta.
-- No abre una transaccion propia, se llama desde
-- CerrarEstadoCuenta dentro de su transaccion.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AbrirEstadoCuenta]
    @inIdCuenta INT,
    @inFechaCierre DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaCreacion DATE;
    DECLARE @Saldo MONEY;
    DECLARE @FechaInicio DATE;
    DECLARE @FechaFin DATE;

    SELECT
        @FechaCreacion = C.FechaCreacion,
        @Saldo = C.Saldo
    FROM dbo.Cuenta AS C
    WHERE C.Id = @inIdCuenta;

    IF @FechaCreacion IS NULL
        THROW 50002, 'Cuenta no encontrada.', 1;

    SET @FechaInicio = DATEADD(DAY, 1, @inFechaCierre);

    -- La fecha de cierre se calcula a partir de la fecha de creacion
    -- y no del cierre anterior. Asi una cuenta creada un 31 cierra el
    -- ultimo dia de los meses cortos y vuelve al 31 cuando el mes lo tiene.
    SET @FechaFin = DATEADD(MONTH, DATEDIFF(MONTH, @FechaCreacion, @inFechaCierre) + 1, @FechaCreacion);

    INSERT INTO dbo.EstadoCuenta
    (
        IdCuenta,
        FechaInicio,
        FechaFin,
        SaldoInicial,
        SaldoFinal,
        SaldoMinimo
    )
    VALUES
    (
        @inIdCuenta,
        @FechaInicio,
        @FechaFin,
        @Saldo,
        @Saldo,
        @Saldo
    );

    RETURN 0;
END;
