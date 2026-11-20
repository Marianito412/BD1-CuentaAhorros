CREATE TABLE dbo.TipoMovimiento
(
    Id                    INT         NOT NULL,
    Nombre                VARCHAR(64) NOT NULL,
    flagEsCredito         BIT         NOT NULL,
    flagGeneraComprobante BIT         NOT NULL,
    CONSTRAINT PK_TipoMovimiento
        PRIMARY KEY (Id),
    CONSTRAINT UQ_TipoMovimiento_Nombre
        UNIQUE (Nombre)
);
