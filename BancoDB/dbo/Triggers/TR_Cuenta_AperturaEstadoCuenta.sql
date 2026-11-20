-- =============================================
-- Trigger: TR_Cuenta_AperturaEstadoCuenta
-- Descripcion: Crea el primer estado de cuenta
-- de cada cuenta nueva. El periodo va desde la
-- fecha de creacion hasta el mismo dia del mes
-- siguiente, que es cuando se hace el cierre.
-- =============================================
CREATE OR ALTER TRIGGER dbo.TR_Cuenta_AperturaEstadoCuenta
ON dbo.Cuenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Se toma de "inserted" para cubrir el caso en que
    -- se inserten varias cuentas en una misma sentencia
    INSERT INTO dbo.EstadoCuenta
    (
        IdCuenta,
        FechaInicio,
        FechaFin,
        SaldoInicial,
        SaldoFinal,
        SaldoMinimo
    )
    SELECT
        I.Id,
        I.FechaCreacion,
        DATEADD(MONTH, 1, I.FechaCreacion),
        I.Saldo,
        I.Saldo,
        I.Saldo
    FROM inserted AS I;
END;
