CREATE TABLE dbo.TipoCuentaAhorros
(
    Id                  INT            NOT NULL,
    Nombre              VARCHAR(64)    NOT NULL,
    IdTipoMoneda        INT            NOT NULL,
    SaldoMinimo         MONEY          NOT NULL,
    MultaSaldoMin       MONEY          NOT NULL,
    CargoMensual        MONEY          NOT NULL,
    NumRetiroHumano     INT            NOT NULL,
    NumRetiroAutomatico INT            NOT NULL,
    ComisionHumano      MONEY          NOT NULL,
    ComisionAutomatico  MONEY          NOT NULL,
    MontoMaxSinpeDiario MONEY          NOT NULL,
    ComisionSinpe       MONEY          NOT NULL,
    TasaInteresAnual    DECIMAL(10, 4) NOT NULL,
    CONSTRAINT PK_TipoCuentaAhorros
        PRIMARY KEY (Id),
    CONSTRAINT FK_TipoCuentaAhorros_TipoMoneda
        FOREIGN KEY (IdTipoMoneda) REFERENCES dbo.TipoMoneda
);
