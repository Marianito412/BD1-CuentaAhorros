CREATE TABLE dbo.Usuario
(
    Id                  INT IDENTITY,
    [User]              VARCHAR(32) NOT NULL,
    Pass                VARCHAR(64) NOT NULL,
    IdPersona           INT         NOT NULL,
    flagEsAdministrador BIT
        CONSTRAINT DF_Usuario_flagEsAdministrador DEFAULT 0 NOT NULL,
    CONSTRAINT PK_Usuario
        PRIMARY KEY (Id),
    CONSTRAINT UQ_Usuario_User
        UNIQUE ([User]),
    CONSTRAINT FK_Usuario_Persona
        FOREIGN KEY (IdPersona) REFERENCES dbo.Persona
);
