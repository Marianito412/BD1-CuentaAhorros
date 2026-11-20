CREATE TABLE dbo.EstadoCuenta
(
    Id                        INT IDENTITY,
    IdCuenta                  INT   NOT NULL,
    FechaInicio               DATE  NOT NULL,
    FechaFin                  DATE  NOT NULL,
    SaldoInicial              MONEY NOT NULL,
    SaldoFinal                MONEY NOT NULL,
    SaldoMinimo               MONEY NOT NULL,
    CantidadOperacionesATM    INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesATM DEFAULT 0    NOT NULL,
    CantidadOperacionesHumano INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesHumano DEFAULT 0 NOT NULL,
    CantidadOperacionesSinpe  INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesSinpe DEFAULT 0  NOT NULL,
    CONSTRAINT PK_EstadoCuenta
        PRIMARY KEY (Id),
    CONSTRAINT FK_EstadoCuenta_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesATM
        CHECK ([CantidadOperacionesATM] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesHumano
        CHECK ([CantidadOperacionesHumano] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesSinpe
        CHECK ([CantidadOperacionesSinpe] >= 0),
    CONSTRAINT CK_EstadoCuenta_Fechas
        CHECK ([FechaFin] >= [FechaInicio])
);
