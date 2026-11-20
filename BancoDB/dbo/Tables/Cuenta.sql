CREATE TABLE dbo.Cuenta
(
    Id            INT IDENTITY,
    IdCliente     INT         NOT NULL,
    IdTipoCuenta  INT         NOT NULL,
    NumeroCuenta  VARCHAR(64) NOT NULL,
    FechaCreacion DATE        NOT NULL,
    Saldo         MONEY       NOT NULL,
    CONSTRAINT PK_Cuenta
        PRIMARY KEY (Id),
    CONSTRAINT UQ_Cuenta_NumeroCuenta
        UNIQUE (NumeroCuenta),
    CONSTRAINT FK_Cuenta_Persona
        FOREIGN KEY (IdCliente) REFERENCES dbo.Persona,
    CONSTRAINT FK_Cuenta_TipoCuentaAhorros
        FOREIGN KEY (IdTipoCuenta) REFERENCES dbo.TipoCuentaAhorros
);
