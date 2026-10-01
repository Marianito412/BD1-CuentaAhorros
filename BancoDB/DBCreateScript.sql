DROP TABLE IF EXISTS dbo.Beneficiario
CREATE TABLE dbo.Beneficiario (
    Id             INT          IDENTITY (1, 1) NOT NULL,
    IdCuenta       VARCHAR (64),
    IdBeneficiario VARCHAR (64),
    IdParentezco   INT         ,
    Porcentaje     FLOAT (53)  ,
    flagActivo     BIT          DEFAULT 1,

    CONSTRAINT PK_Beneficiario PRIMARY KEY (Id),
    CONSTRAINT FK_Beneficiario_Parentezco FOREIGN KEY (IdParentezco) REFERENCES dbo.Parentezco (Id),
    CONSTRAINT FK_Beneficiario_Persona FOREIGN KEY (IdBeneficiario) REFERENCES dbo.Persona (ValorDocumentoIdentidad),
    CONSTRAINT FK_Beneficiario_Cuenta FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta (NumeroCuenta)
);

DROP TABLE IF EXISTS dbo.TipoCuentaAhorros
CREATE TABLE dbo.TipoCuentaAhorros (
    Id                  INT   IDENTITY (1, 1) NOT NULL,
    Nombre              INT  ,
    IdTipoMoneda        INT  ,
    SaldoMinimo         MONEY,
    MultaSaldoMin       MONEY,
    CargoAnual          MONEY,
    NumRetiroHumano     INT  ,
    NumRetiroAutomatico INT  ,
    ComisionHumano      MONEY,
    ComisionAutomatico  MONEY,
    
    CONSTRAINT PK_TipoCuentaAhorros PRIMARY KEY (Id),
    CONSTRAINT FK_TipoCuentaAhorros_TipoMoneda FOREIGN KEY (IdTipoMoneda) REFERENCES dbo.TipoMoneda(Id)
);

DROP TABLE IF EXISTS dbo.TipoDocuIdentidad;
CREATE TABLE dbo.TipoDocuIdentidad (
    Id     INT          IDENTITY (1, 1) NOT NULL,
    Nombre VARCHAR (64),
    CONSTRAINT PK_TipoDocuIdentidad PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS dbo.TipoMoneda
CREATE TABLE dbo.TipoMoneda (
    Id      INT          IDENTITY (1, 1) NOT NULL,
    Nombre  VARCHAR (32),
    Simbolo VARCHAR (4) ,
    CONSTRAINT PK_TipoMoneda PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS dbo.Parentezco
CREATE TABLE dbo.Parentezco (
    Id     INT          IDENTITY (1, 1) NOT NULL,
    Nombre VARCHAR (32),
    CONSTRAINT PK_Parentezco PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS dbo.TipoOperacion
CREATE TABLE dbo.TipoOperacion (
    Id     INT          IDENTITY (1, 1) NOT NULL,
    Nombre VARCHAR (64),
    CONSTRAINT PK_TipoOperación PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS dbo.Cuenta
CREATE TABLE dbo.Cuenta (
    Id            INT          IDENTITY (1, 1) NOT NULL,
    IdPersona     VARCHAR (64),
    NumeroCuenta  VARCHAR (64) NOT NULL,
    FechaCreacion DATE        ,
    Saldo         MONEY       ,
    IdTipoCuenta  INT         ,

    CONSTRAINT PK_Cuenta PRIMARY KEY (Id, NumeroCuenta),
    CONSTRAINT UQ_Cuenta_NumeroCuenta UNIQUE (NumeroCuenta),

    CONSTRAINT FK_Cuenta_Persona FOREIGN KEY (IdPersona) REFERENCES dbo.Persona(ValorDocumentoIdentidad),
    CONSTRAINT FK_Cuenta_TipoCuenta FOREIGN KEY (IdTipoCuenta) REFERENCES dbo.TipoCuentaAhorros(Id)
);

DROP TABLE IF EXISTS dbo.TipoTransaccion
CREATE TABLE dbo.TipoTransaccion (
    Id            INT          IDENTITY (1, 1) NOT NULL,
    Nombre        VARCHAR (32) NOT NULL,
    flagEsCredito BIT          NOT NULL CONSTRAINT PK_TipoTransaccion PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS dbo.Transaccion
CREATE TABLE dbo.Transacccion (
    Id                INT          IDENTITY (1, 1) NOT NULL,
    IdCuenta          VARCHAR (64) NOT NULL,
    IdTipoTransaccion INT         ,
    Cantidad          MONEY       ,
    Hora              DATETIME2    DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Transaccion PRIMARY KEY (Id),
    CONSTRAINT FK_Transaccion_Cuenta FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta (NumeroCuenta),
    CONSTRAINT FK_Transaccion_TipoTransaccion FOREIGN KEY (IdTipoTransaccion) REFERENCES dbo.TipoTransaccion (Id)
);

DROP TABLE IF EXISTS dbo.EstadoCuenta
CREATE TABLE dbo.EstadoCuenta (
    Id           INT          IDENTITY (1, 1) NOT NULL,
    IdCuenta     VARCHAR (64),
    FechaInicio  DATE        ,
    FechaFin     DATE        ,
    SaldoInicial MONEY       ,
    SaldoFinal   MONEY       ,
    CONSTRAINT PK_EstadoCuenta PRIMARY KEY (Id),

    CONSTRAINT FK_EstadoCuenta_Cuenta FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta(NumeroCuenta)
);

DROP TABLE IF EXISTS dbo.Persona;
CREATE TABLE dbo.Persona (
    Id                      INT          IDENTITY (1, 1) NOT NULL,
    IdTipoDocuIdentidad     INT         ,
    ValorDocumentoIdentidad VARCHAR (64) NOT NULL,
    FechaNacimiento         DATE        ,
    Email                   VARCHAR (64),
    Telefono                VARCHAR (32),
    Telefono2               VARCHAR (32),
    CONSTRAINT PK_Person PRIMARY KEY (Id, ValorDocumentoIdentidad),
    CONSTRAINT UQ_Persona_ValodDocumentoIdentidad UNIQUE (ValorDocumentoIdentidad),
    CONSTRAINT FK_Persona_TipoDocuIdentidad FOREIGN KEY (IdTipoDocuIdentidad) REFERENCES dbo.TipoDocuIdentidad (Id)
);

DROP TABLE IF EXISTS dbo.Usuario
CREATE TABLE dbo.Usuario (
    Id                  INT          IDENTITY (1, 1) NOT NULL,
    [User]              VARCHAR (32),
    Pass                VARCHAR (64),
    flagEsAdministrador BIT          DEFAULT ((0)),
    CONSTRAINT PK_Usuario PRIMARY KEY (Id)
);

--TESTING---------------------------------------------------------------------------------

-- Encontrar todos los beneficiarios de una cuenta
SELECT *
FROM   Beneficiario AS B
    INNER JOIN Persona AS P ON B.IdBeneficiario = P.ValorDocumentoIdentidad
    INNER JOIN Parentezco AS Pa ON B.IdParentezco = PA.Id
WHERE  IdCuenta = '';


-- Encontrar todos los estados de cuenta de una cuenta
SELECT *
FROM   EstadoCuenta AS E
    INNER JOIN Cuenta AS C ON E.IdCuenta = C.Id
    INNER JOIN Persona AS P ON C.IdPersona = P.ValorDocumentoIdentidad
WHERE  E.IdCuenta = '';