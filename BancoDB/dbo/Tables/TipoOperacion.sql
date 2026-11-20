CREATE TABLE dbo.TipoOperacion
(
    Id     INT         NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT PK_TipoOperacion
        PRIMARY KEY (Id)
);
