-- =============================================
-- Script: ReiniciarBase
-- Descripcion: Borra todas las tablas y las crea
-- de nuevo con la estructura de la tercera tarea.
-- Se borran primero las tablas que tienen llaves
-- foraneas hacia otras.
-- =============================================

DROP TABLE IF EXISTS dbo.Bitacora;
DROP TABLE IF EXISTS dbo.UsuarioVer;
DROP TABLE IF EXISTS dbo.Usuario;
DROP TABLE IF EXISTS dbo.Movimiento;
DROP TABLE IF EXISTS dbo.Beneficiario;
DROP TABLE IF EXISTS dbo.EstadoCuenta;
DROP TABLE IF EXISTS dbo.Transacccion;
DROP TABLE IF EXISTS dbo.TipoTransaccion;
DROP TABLE IF EXISTS dbo.Cuenta;
DROP TABLE IF EXISTS dbo.Persona;
DROP TABLE IF EXISTS dbo.TipoCuentaAhorros;
DROP TABLE IF EXISTS dbo.TipoMovimiento;
DROP TABLE IF EXISTS dbo.TipoMoneda;
DROP TABLE IF EXISTS dbo.TipoDocuIdentidad;
DROP TABLE IF EXISTS dbo.Parentezco;
DROP TABLE IF EXISTS dbo.TipoOperacion;
GO

-- Catalogos

CREATE TABLE dbo.Parentezco
(
    Id     INT         NOT NULL,
    Nombre VARCHAR(32) NOT NULL,
    CONSTRAINT PK_Parentezco
        PRIMARY KEY (Id)
);

CREATE TABLE dbo.TipoDocuIdentidad
(
    Id     INT         NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT PK_TipoDocuIdentidad
        PRIMARY KEY (Id)
);

CREATE TABLE dbo.TipoOperacion
(
    Id     INT         NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT PK_TipoOperacion
        PRIMARY KEY (Id)
);

CREATE TABLE dbo.TipoMoneda
(
    Id      INT         NOT NULL,
    Nombre  VARCHAR(32) NOT NULL,
    Simbolo NVARCHAR(4) NOT NULL,
    CONSTRAINT PK_TipoMoneda
        PRIMARY KEY (Id)
);

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

-- Datos de clientes y cuentas

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

CREATE TABLE dbo.Cuenta
(
    Id            INT IDENTITY,
    IdCliente     INT         NOT NULL,
    IdTipoCuenta  INT         NOT NULL,
    NumeroCuenta  VARCHAR(64) NOT NULL,
    FechaCreacion DATE        NOT NULL,
    Saldo         MONEY       NOT NULL,
    CONSTRAINT PK_Cuenta
        PRIMARY KEY (Id),
    CONSTRAINT UQ_Cuenta_NumeroCuenta
        UNIQUE (NumeroCuenta),
    CONSTRAINT FK_Cuenta_Persona
        FOREIGN KEY (IdCliente) REFERENCES dbo.Persona,
    CONSTRAINT FK_Cuenta_TipoCuentaAhorros
        FOREIGN KEY (IdTipoCuenta) REFERENCES dbo.TipoCuentaAhorros
);

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

CREATE TABLE dbo.EstadoCuenta
(
    Id                        INT IDENTITY,
    IdCuenta                  INT   NOT NULL,
    FechaInicio               DATE  NOT NULL,
    FechaFin                  DATE  NOT NULL,
    SaldoInicial              MONEY NOT NULL,
    SaldoFinal                MONEY NOT NULL,
    SaldoMinimo               MONEY NOT NULL,
    CantidadOperacionesATM    INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesATM DEFAULT 0    NOT NULL,
    CantidadOperacionesHumano INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesHumano DEFAULT 0 NOT NULL,
    CantidadOperacionesSinpe  INT
        CONSTRAINT DF_EstadoCuenta_CantidadOperacionesSinpe DEFAULT 0  NOT NULL,
    CONSTRAINT PK_EstadoCuenta
        PRIMARY KEY (Id),
    CONSTRAINT FK_EstadoCuenta_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesATM
        CHECK ([CantidadOperacionesATM] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesHumano
        CHECK ([CantidadOperacionesHumano] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadOperacionesSinpe
        CHECK ([CantidadOperacionesSinpe] >= 0),
    CONSTRAINT CK_EstadoCuenta_Fechas
        CHECK ([FechaFin] >= [FechaInicio])
);

CREATE TABLE dbo.Movimiento
(
    Id               INT IDENTITY,
    IdCuenta         INT          NOT NULL,
    IdTipoMovimiento INT          NOT NULL,
    Fecha            DATE         NOT NULL,
    Monto            MONEY        NOT NULL,
    Descripcion      VARCHAR(256) NOT NULL,
    NuevoSaldo       MONEY        NOT NULL,
    CONSTRAINT PK_Movimiento
        PRIMARY KEY (Id),
    CONSTRAINT FK_Movimiento_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT FK_Movimiento_TipoMovimiento
        FOREIGN KEY (IdTipoMovimiento) REFERENCES dbo.TipoMovimiento
);

-- Usuarios del portal

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
