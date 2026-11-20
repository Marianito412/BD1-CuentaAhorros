-- =============================================
-- Procedimiento: ProcesarCierresEstadoCuenta
-- Descripcion: Cierra todos los estados de cuenta
-- cuya fecha final es la fecha que se esta
-- procesando. Cada cierre se hace por separado
-- en su propia transaccion (CerrarEstadoCuenta).
-- Un estado que ya fue cerrado (ya tiene el estado
-- del siguiente periodo) no se vuelve a cerrar, asi
-- el proceso puede correrse de nuevo sin duplicar.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[ProcesarCierresEstadoCuenta]
    @inFecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Cierres TABLE
    (
        Secuencia      INT IDENTITY(1, 1),
        IdEstadoCuenta INT
    );

    DECLARE @Actual INT;
    DECLARE @Total INT;
    DECLARE @IdEstadoCuenta INT;

    INSERT INTO @Cierres (IdEstadoCuenta)
    SELECT EC.Id
    FROM dbo.EstadoCuenta AS EC
    WHERE EC.FechaFin = @inFecha
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.EstadoCuenta AS SIG
          WHERE SIG.IdCuenta = EC.IdCuenta
            AND SIG.FechaInicio = DATEADD(DAY, 1, @inFecha)
      )
    ORDER BY EC.Id;

    SELECT @Total = COUNT(*)
    FROM @Cierres;

    SET @Actual = 1;

    WHILE @Actual <= @Total
    BEGIN
        SELECT @IdEstadoCuenta = C.IdEstadoCuenta
        FROM @Cierres AS C
        WHERE C.Secuencia = @Actual;

        EXEC dbo.CerrarEstadoCuenta
            @inIdEstadoCuenta = @IdEstadoCuenta;

        SET @Actual = @Actual + 1;
    END;

    RETURN 0;
END;
