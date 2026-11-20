CREATE TABLE dbo.Bitacora
(
    Id              INT IDENTITY,
    IdUsuario       INT NOT NULL,
    IdTipoOperacion INT NOT NULL,
    IP              VARCHAR(64),
    DatosAntes      NVARCHAR(MAX),
    DatosDespues    NVARCHAR(MAX),
    FechaHora       DATETIME2
        CONSTRAINT DF_Bitacora_FechaHora DEFAULT SYSDATETIME() NOT NULL,
    CONSTRAINT PK_Bitacora
        PRIMARY KEY (Id),
    CONSTRAINT FK_Bitacora_TipoOperacion
        FOREIGN KEY (IdTipoOperacion) REFERENCES dbo.TipoOperacion,
    CONSTRAINT FK_Bitacora_Usuario
        FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario
);
