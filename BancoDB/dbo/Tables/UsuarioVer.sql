CREATE TABLE dbo.UsuarioVer
(
    Id        INT IDENTITY,
    IdUsuario INT NOT NULL,
    IdCuenta  INT NOT NULL,
    CONSTRAINT PK_UsuarioVer
        PRIMARY KEY (Id),
    CONSTRAINT UQ_UsuarioVer_UsuarioCuenta
        UNIQUE (IdUsuario, IdCuenta),
    CONSTRAINT FK_UsuarioVer_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT FK_UsuarioVer_Usuario
        FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario
);
