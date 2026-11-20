CREATE TABLE dbo.Persona
(
    Id                      INT IDENTITY,
    TipoDocuIdentidad       INT         NOT NULL,
    Nombre                  VARCHAR(64) NOT NULL,
    ValorDocumentoIdentidad VARCHAR(64) NOT NULL,
    FechaNacimiento         DATE        NOT NULL,
    Email                   VARCHAR(64) NOT NULL,
    Telefono                VARCHAR(32) NOT NULL,
    Telefono2               VARCHAR(32) NOT NULL,
    CONSTRAINT PK_Persona
        PRIMARY KEY (Id),
    CONSTRAINT UQ_Persona_ValorDocumentoIdentidad
        UNIQUE (ValorDocumentoIdentidad),
    CONSTRAINT FK_Persona_TipoDocuIdentidad
        FOREIGN KEY (TipoDocuIdentidad) REFERENCES dbo.TipoDocuIdentidad
);
