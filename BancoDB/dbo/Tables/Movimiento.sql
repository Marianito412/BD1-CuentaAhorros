CREATE TABLE dbo.Movimiento
(
    Id               INT IDENTITY,
    IdCuenta         INT          NOT NULL,
    IdTipoMovimiento INT          NOT NULL,
    Fecha            DATE         NOT NULL,
    Monto            MONEY        NOT NULL,
    Descripcion      VARCHAR(256) NOT NULL,
    NuevoSaldo       MONEY        NOT NULL,
    CONSTRAINT PK_Movimiento
        PRIMARY KEY (Id),
    CONSTRAINT FK_Movimiento_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT FK_Movimiento_TipoMovimiento
        FOREIGN KEY (IdTipoMovimiento) REFERENCES dbo.TipoMovimiento
);
