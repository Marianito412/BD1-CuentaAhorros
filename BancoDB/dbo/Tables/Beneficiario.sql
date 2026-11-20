CREATE TABLE dbo.Beneficiario
(
    Id                 INT IDENTITY,
    IdCuenta           INT NOT NULL,
    IdBeneficiario     INT NOT NULL,
    IdParentezco       INT NOT NULL,
    Porcentaje         INT NOT NULL,
    flagActivo         BIT
        CONSTRAINT DF_Beneficiario_flagActivo DEFAULT 1 NOT NULL,
    FechaDesactivacion DATETIME2,
    CONSTRAINT PK_Beneficiario
        PRIMARY KEY (Id),
    CONSTRAINT FK_Beneficiario_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT FK_Beneficiario_Parentezco
        FOREIGN KEY (IdParentezco) REFERENCES dbo.Parentezco,
    CONSTRAINT FK_Beneficiario_Persona
        FOREIGN KEY (IdBeneficiario) REFERENCES dbo.Persona,
    CONSTRAINT CK_Beneficiario_Porcentaje
        CHECK ([Porcentaje] >= 0 AND [Porcentaje] <= 100)
);
