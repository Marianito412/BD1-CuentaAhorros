CREATE OR ALTER PROCEDURE [dbo].[ProcesarMovimiento]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Movimientos TABLE (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        IdTipoCuenta INT,
        IdCuenta INT,
        Monto MONEY,
        Descripcion varchar(256)
    )
    
    Insert into @Movimientos (IdTipoCuenta, IdCuenta, Monto, Descripcion) 
    SELECT
        T.Id AS Tipo,
        C.Id AS IdCuenta,
        F.f.value('@Monto', 'Money') AS Monto,
        F.f.value('@Descripcion', 'varchar(256)') as Descripcion
    FROM @XmlDia.nodes('/FechaOperacion/Movimientos') AS F(f)
    inner join Cuenta as C on C.NumeroCuenta = F.f.value('@CodigoCuenta', 'varchar(64)')
    inner join TipoMovimiento as T on T.Nombre = F.f.value('@Tipo', 'varchar(64)')

    DECLARE @Id INT = 0,
        @IdTipo INT,
        @IdCuenta INT,
        @Monto MONEY,
        @Descripcion VARCHAR(256);

    --select 'Test' as Tabla, * from @Movimientos
    
    WHILE 1 = 1
        BEGIN
            -- Next row after the last one processed
            SELECT TOP (1)
                @Id = Id,
                @IdTipo = IdTipoCuenta,
                @IdCuenta = IdCuenta,
                @Monto = Monto,
                @Descripcion = Descripcion
            FROM @Movimientos
            WHERE Id > @Id
            ORDER BY Id;

            IF @@ROWCOUNT = 0 BREAK;   -- no more rows

            EXEC dbo.AplicarMovimiento
                 @inIdCuenta = @IdCuenta, 
                 @inIdTipoMovimiento = @IdTipo, 
                 @inFecha = @Fecha, 
                 @inMonto = @Monto, 
                 @inDescripcion = @Descripcion
        END
    
    --EXEC AplicarMovimiento @inIdCuenta = @IdCuenta, @inIdTipoMovimiento = _, @inFecha = _, @inMonto = _, @inDescripcion = _
    
    RETURN 0;
END
GO