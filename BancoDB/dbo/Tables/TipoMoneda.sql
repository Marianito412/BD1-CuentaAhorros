CREATE TABLE dbo.TipoMoneda
(
    Id      INT         NOT NULL,
    Nombre  VARCHAR(32) NOT NULL,
    Simbolo NVARCHAR(4) NOT NULL,
    CONSTRAINT PK_TipoMoneda
        PRIMARY KEY (Id)
);
