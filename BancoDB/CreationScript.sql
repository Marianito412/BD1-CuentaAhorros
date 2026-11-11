CREATE TABLE dbo.Empleado
(
    id      INT IDENTITY,
    Nombre  VARCHAR(128) NOT NULL,
    Salario MONEY        NOT NULL,
    PRIMARY KEY (id)
);

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
    CargoAnual          MONEY          NOT NULL,
    NumRetiroHumano     INT            NOT NULL,
    NumRetiroAutomatico INT            NOT NULL,
    ComisionHumano      MONEY          NOT NULL,
    ComisionAutomatico  MONEY          NOT NULL,
    Interes             DECIMAL(10, 4) NOT NULL,
    CONSTRAINT PK_TipoCuentaAhorros
        PRIMARY KEY (Id),
    CONSTRAINT FK_TipoCuentaAhorros_TipoMoneda
        FOREIGN KEY (IdTipoMoneda) REFERENCES dbo.TipoMoneda
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
    IdCuenta           INT                              NOT NULL,
    IdBeneficiario     INT                              NOT NULL,
    IdParentezco       INT                              NOT NULL,
    Porcentaje         INT                              NOT NULL,
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
        CHECK ([Porcentaje] >= 0 AND [Porcentaje] <= 100),
);

CREATE TABLE dbo.EstadoCuenta
(
    Id                     INT IDENTITY,
    IdCuenta               INT                                      NOT NULL,
    FechaInicio            DATE                                     NOT NULL,
    FechaFin               DATE                                     NOT NULL,
    SaldoInicial           MONEY                                    NOT NULL,
    SaldoFinal             MONEY                                    NOT NULL,
    SaldoMinimo            MONEY                                    NOT NULL,
    InteresesAcumulados    MONEY
        CONSTRAINT DF_EstadoCuenta_InteresesAcumulados DEFAULT 0    NOT NULL,
    CantidadRetiros        INT
        CONSTRAINT DF_EstadoCuenta_CantidadRetiros DEFAULT 0        NOT NULL,
    CantidadDepositos      INT
        CONSTRAINT DF_EstadoCuenta_CantidadDepositos DEFAULT 0      NOT NULL,
    CantidadSinpeEntrantes INT
        CONSTRAINT DF_EstadoCuenta_CantidadSinpeEntrantes DEFAULT 0 NOT NULL,
    CantidadSinpeSalientes INT
        CONSTRAINT DF_EstadoCuenta_CantidadSinpeSalientes DEFAULT 0 NOT NULL,
    CONSTRAINT PK_EstadoCuenta
        PRIMARY KEY (Id),
    CONSTRAINT FK_EstadoCuenta_Cuenta
        FOREIGN KEY (IdCuenta) REFERENCES dbo.Cuenta,
    CONSTRAINT CK_EstadoCuenta_CantidadDepositos
        CHECK ([CantidadDepositos] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadRetiros
        CHECK ([CantidadRetiros] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadSinpeEntrantes
        CHECK ([CantidadSinpeEntrantes] >= 0),
    CONSTRAINT CK_EstadoCuenta_CantidadSinpeSalientes
        CHECK ([CantidadSinpeSalientes] >= 0),
    CONSTRAINT CK_EstadoCuenta_Fechas
        CHECK ([FechaFin] >= [FechaInicio])
);

CREATE TABLE dbo.TipoOperacion
(
    Id     INT         NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT PK_TipoOperacion
        PRIMARY KEY (Id)
);

CREATE TABLE dbo.TipoTransaccion
(
    Id            INT IDENTITY,
    Nombre        VARCHAR(32) NOT NULL,
    flagEsCredito BIT         NOT NULL,
    CONSTRAINT PK_TipoTransaccion
        PRIMARY KEY (Id)
);

CREATE TABLE dbo.Transacccion
(
    Id                INT IDENTITY,
    IdCuenta          VARCHAR(64)                 NOT NULL,
    IdTipoTransaccion INT,
    Cantidad          MONEY,
    Hora              DATETIME2 DEFAULT GETDATE() NOT NULL,
    CONSTRAINT PK_Transaccion
        PRIMARY KEY (Id),
    CONSTRAINT FK_Transaccion_TipoTransaccion
        FOREIGN KEY (IdTipoTransaccion) REFERENCES dbo.TipoTransaccion,
);

CREATE TABLE dbo.Usuario
(
    Id                  INT IDENTITY,
    [User]              VARCHAR(32)                         NOT NULL,
    Pass                VARCHAR(64)                         NOT NULL,
    IdPersona           INT                                 NOT NULL,
    flagEsAdministrador BIT
        CONSTRAINT DF_Usuario_flagEsAdministrador DEFAULT 0 NOT NULL,
    CONSTRAINT PK_Usuario
        PRIMARY KEY (Id),
    CONSTRAINT UQ_Usuario_User
        UNIQUE ([User]),
    CONSTRAINT FK_Usuario_Persona
        FOREIGN KEY (IdPersona) REFERENCES dbo.Persona,
);

CREATE TABLE dbo.Bitacora
(
    Id              INT IDENTITY,
    IdUsuario       INT                                        NOT NULL,
    IdTipoOperacion INT                                        NOT NULL,
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
        FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario,
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

CREATE PROCEDURE dbo.ActualizarPorcentajeBeneficiario @inUser VARCHAR(32),
                                                      @inNumeroCuenta VARCHAR(64),
                                                      @inIdBeneficiario INT,
                                                      @inNuevoPorcentaje INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdUsuario INT;
        DECLARE @IdCuenta INT;
        DECLARE @EsAdministrador BIT;
        DECLARE @PorcentajeAnterior INT;
        DECLARE @SumaPorcentajes INT;

        SELECT @IdUsuario = Id,
               @EsAdministrador = flagEsAdministrador
        FROM dbo.Usuario
        WHERE [User] = @inUser;

        IF @IdUsuario IS NULL
            BEGIN
                ROLLBACK;
                SELECT 0 AS Resultado, 'Usuario no encontrado.' AS Mensaje;
                RETURN;
            END;

        SELECT @IdCuenta = Id
        FROM dbo.Cuenta
        WHERE NumeroCuenta = @inNumeroCuenta;

        IF @IdCuenta IS NULL
            BEGIN
                ROLLBACK;
                SELECT 0 AS Resultado, 'Cuenta no encontrada.' AS Mensaje;
                RETURN;
            END;

        IF @EsAdministrador = 0
            AND NOT EXISTS
               (SELECT 1
                FROM dbo.UsuarioVer
                WHERE IdUsuario = @IdUsuario
                  AND IdCuenta = @IdCuenta)
            BEGIN
                ROLLBACK;
                SELECT 0 AS Resultado, 'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
                RETURN;
            END;

        IF @inNuevoPorcentaje <= 0 OR @inNuevoPorcentaje > 100
            BEGIN
                ROLLBACK;
                SELECT 0 AS Resultado, 'El porcentaje debe estar entre 1 y 100.' AS Mensaje;
                RETURN;
            END;

        SELECT @PorcentajeAnterior = Porcentaje
        FROM dbo.Beneficiario
        WHERE Id = @inIdBeneficiario
          AND IdCuenta = @IdCuenta
          AND flagActivo = 1;

        IF @PorcentajeAnterior IS NULL
            BEGIN
                ROLLBACK;
                SELECT 0 AS Resultado, 'Beneficiario activo no encontrado.' AS Mensaje;
                RETURN;
            END;

        UPDATE dbo.Beneficiario
        SET Porcentaje = @inNuevoPorcentaje
        WHERE Id = @inIdBeneficiario;

        INSERT INTO dbo.Bitacora
        (IdUsuario,
         IdTipoOperacion,
         IP,
         DatosAntes,
         DatosDespues,
         FechaHora)
        VALUES (@IdUsuario,
                6,
                NULL,
                (SELECT @inIdBeneficiario   AS IdBeneficiario,
                        @PorcentajeAnterior AS Porcentaje
                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                (SELECT @inIdBeneficiario  AS IdBeneficiario,
                        @inNuevoPorcentaje AS Porcentaje
                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                SYSDATETIME());

        SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
        FROM dbo.Beneficiario
        WHERE IdCuenta = @IdCuenta
          AND flagActivo = 1;
        COMMIT;

        SELECT 1                                       AS Resultado,
               'Porcentaje actualizado correctamente.' AS Mensaje,
               @SumaPorcentajes                        AS SumaPorcentajes,
               CASE
                   WHEN @SumaPorcentajes = 100 THEN 1
                   ELSE 0
                   END                                 AS PorcentajesCompletos;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT 0               AS Resultado,
               ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;

    CREATE PROCEDURE dbo.AgregarBeneficiario @inUser VARCHAR(32),
                                             @inNumeroCuenta VARCHAR(64),
                                             @inValorDocumentoIdentidad VARCHAR(64),
                                             @inTipoDocuIdentidad INT,
                                             @inNombre VARCHAR(64),
                                             @inFechaNacimiento DATE,
                                             @inEmail VARCHAR(64),
                                             @inTelefono VARCHAR(32),
                                             @inTelefono2 VARCHAR(32),
                                             @inIdParentezco INT,
                                             @inPorcentaje INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @IdUsuario INT;
            DECLARE @IdCuenta INT;
            DECLARE @IdPersona INT;
            DECLARE @IdBeneficiario INT;
            DECLARE @EsAdministrador BIT;
            DECLARE @CantidadActivos INT;
            DECLARE @SumaPorcentajes INT;

            SELECT @IdUsuario = Id,
                   @EsAdministrador = flagEsAdministrador
            FROM dbo.Usuario
            WHERE [User] = @inUser;

            IF @IdUsuario IS NULL
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'Usuario no encontrado.' AS Mensaje;
                    RETURN;
                END;

            SELECT @IdCuenta = Id
            FROM dbo.Cuenta
            WHERE NumeroCuenta = @inNumeroCuenta;

            IF @IdCuenta IS NULL
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'Cuenta no encontrada.' AS Mensaje;
                    RETURN;
                END;

            IF @EsAdministrador = 0
                AND NOT EXISTS
                   (SELECT 1
                    FROM dbo.UsuarioVer
                    WHERE IdUsuario = @IdUsuario
                      AND IdCuenta = @IdCuenta)
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
                    RETURN;
                END;

            IF @inPorcentaje <= 0 OR @inPorcentaje > 100
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'El porcentaje debe estar entre 1 y 100.' AS Mensaje;
                    RETURN;
                END;

            SELECT @CantidadActivos = COUNT(*)
            FROM dbo.Beneficiario
            WHERE IdCuenta = @IdCuenta
              AND flagActivo = 1;

            IF @CantidadActivos >= 3
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'La cuenta ya tiene 3 beneficiarios activos.' AS Mensaje;
                    RETURN;
                END;

            SELECT @IdPersona = Id
            FROM dbo.Persona
            WHERE ValorDocumentoIdentidad = @inValorDocumentoIdentidad;

            IF @IdPersona IS NULL
                BEGIN
                    INSERT INTO dbo.Persona
                    (TipoDocuIdentidad,
                     Nombre,
                     ValorDocumentoIdentidad,
                     FechaNacimiento,
                     Email,
                     Telefono,
                     Telefono2)
                    VALUES (@inTipoDocuIdentidad,
                            @inNombre,
                            @inValorDocumentoIdentidad,
                            @inFechaNacimiento,
                            @inEmail,
                            @inTelefono,
                            @inTelefono2);

                    SET @IdPersona = SCOPE_IDENTITY();
                END;

            IF EXISTS
                (SELECT 1
                 FROM dbo.Beneficiario
                 WHERE IdCuenta = @IdCuenta
                   AND IdBeneficiario = @IdPersona
                   AND flagActivo = 1)
                BEGIN
                    ROLLBACK;
                    SELECT 0 AS Resultado, 'La persona ya es beneficiaria activa de esta cuenta.' AS Mensaje;
                    RETURN;
                END;

            INSERT INTO dbo.Beneficiario
            (IdCuenta,
             IdBeneficiario,
             IdParentezco,
             Porcentaje,
             flagActivo,
             FechaDesactivacion)
            VALUES (@IdCuenta,
                    @IdPersona,
                    @inIdParentezco,
                    @inPorcentaje,
                    1,
                    NULL);

            SET @IdBeneficiario = SCOPE_IDENTITY();

            INSERT INTO dbo.Bitacora
            (IdUsuario,
             IdTipoOperacion,
             IP,
             DatosAntes,
             DatosDespues,
             FechaHora)
            VALUES (@IdUsuario,
                    3,
                    NULL,
                    NULL,
                    (SELECT @IdBeneficiario            AS IdBeneficiario,
                            @inNumeroCuenta            AS NumeroCuenta,
                            @inValorDocumentoIdentidad AS Documento,
                            @inIdParentezco            AS IdParentezco,
                            @inPorcentaje              AS Porcentaje
                     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                    SYSDATETIME());

            SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
            FROM dbo.Beneficiario
            WHERE IdCuenta = @IdCuenta
              AND flagActivo = 1;
            COMMIT;

            SELECT 1                                      AS Resultado,
                   'Beneficiario agregado correctamente.' AS Mensaje,
                   @SumaPorcentajes                       AS SumaPorcentajes,
                   CASE
                       WHEN @SumaPorcentajes = 100 THEN 1
                       ELSE 0
                       END                                AS PorcentajesCompletos;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK;

            SELECT 0               AS Resultado,
                   ERROR_MESSAGE() AS Mensaje;
        END CATCH
    END;

        CREATE PROCEDURE [dbo].[CargarCatalogosXML] @XmlDatos XML
        AS
        BEGIN
            SET NOCOUNT ON;
            SET XACT_ABORT ON;

            BEGIN TRY
                BEGIN TRANSACTION;

                ------------------------------------------------------------
                -- 1. TIPO DE DOCUMENTO DE IDENTIDAD
                ------------------------------------------------------------

                UPDATE TD
                SET TD.Nombre = X.Nombre
                FROM dbo.TipoDocuIdentidad AS TD
                         INNER JOIN
                     (SELECT N.value('@Id', 'INT')             AS Id,
                             N.value('@Nombre', 'VARCHAR(64)') AS Nombre
                      FROM @XmlDatos.nodes('/Catalogos/Tipo_Doc/TipoDocuIdentidad') AS T(N)) AS X
                     ON TD.Id = X.Id;

                INSERT INTO dbo.TipoDocuIdentidad
                (Id,
                 Nombre)
                SELECT N.value('@Id', 'INT'),
                       N.value('@Nombre', 'VARCHAR(64)')
                FROM @XmlDatos.nodes('/Catalogos/Tipo_Doc/TipoDocuIdentidad') AS T(N)
                WHERE NOT EXISTS
                          (SELECT 1
                           FROM dbo.TipoDocuIdentidad AS TD
                           WHERE TD.Id = N.value('@Id', 'INT'));


                ------------------------------------------------------------
                -- 2. TIPO DE MONEDA
                ------------------------------------------------------------

                UPDATE TM
                SET TM.Nombre  = X.Nombre,
                    TM.Simbolo = X.Simbolo
                FROM dbo.TipoMoneda AS TM
                         INNER JOIN
                     (SELECT N.value('@Id', 'INT')              AS Id,
                             N.value('@Nombre', 'VARCHAR(32)')  AS Nombre,
                             N.value('@Simbolo', 'NVARCHAR(4)') AS Simbolo
                      FROM @XmlDatos.nodes('/Catalogos/Tipo_Moneda/TipoMoneda') AS T(N)) AS X
                     ON TM.Id = X.Id;

                INSERT INTO dbo.TipoMoneda
                (Id,
                 Nombre,
                 Simbolo)
                SELECT N.value('@Id', 'INT'),
                       N.value('@Nombre', 'VARCHAR(32)'),
                       N.value('@Simbolo', 'NVARCHAR(4)')
                FROM @XmlDatos.nodes('/Catalogos/Tipo_Moneda/TipoMoneda') AS T(N)
                WHERE NOT EXISTS
                          (SELECT 1
                           FROM dbo.TipoMoneda AS TM
                           WHERE TM.Id = N.value('@Id', 'INT'));


                ------------------------------------------------------------
                -- 3. PARENTEZCOS
                ------------------------------------------------------------

                UPDATE P
                SET P.Nombre = X.Nombre
                FROM dbo.Parentezco AS P
                         INNER JOIN
                     (SELECT N.value('@Id', 'INT')             AS Id,
                             N.value('@Nombre', 'VARCHAR(32)') AS Nombre
                      FROM @XmlDatos.nodes('/Catalogos/Parentezcos/Parentezco') AS T(N)) AS X
                     ON P.Id = X.Id;

                INSERT INTO dbo.Parentezco
                (Id,
                 Nombre)
                SELECT N.value('@Id', 'INT'),
                       N.value('@Nombre', 'VARCHAR(32)')
                FROM @XmlDatos.nodes('/Catalogos/Parentezcos/Parentezco') AS T(N)
                WHERE NOT EXISTS
                          (SELECT 1
                           FROM dbo.Parentezco AS P
                           WHERE P.Id = N.value('@Id', 'INT'));


                ------------------------------------------------------------
                -- 4. TIPOS DE CUENTA DE AHORROS
                ------------------------------------------------------------

                UPDATE TCA
                SET TCA.Nombre              = X.Nombre,
                    TCA.IdTipoMoneda        = X.IdTipoMoneda,
                    TCA.SaldoMinimo         = X.SaldoMinimo,
                    TCA.MultaSaldoMin       = X.MultaSaldoMin,
                    TCA.CargoAnual          = X.CargoAnual,
                    TCA.NumRetiroHumano     = X.NumRetiroHumano,
                    TCA.NumRetiroAutomatico = X.NumRetiroAutomatico,
                    TCA.ComisionHumano      = X.ComisionHumano,
                    TCA.ComisionAutomatico  = X.ComisionAutomatico,
                    TCA.Interes             = X.Interes
                FROM dbo.TipoCuentaAhorros AS TCA
                         INNER JOIN
                     (SELECT N.value('@Id', 'INT')                   AS Id,
                             N.value('@Nombre', 'VARCHAR(64)')       AS Nombre,
                             N.value('@IdTipoMoneda', 'INT')         AS IdTipoMoneda,
                             N.value('@SaldoMinimo', 'MONEY')        AS SaldoMinimo,
                             N.value('@MultaSaldoMin', 'MONEY')      AS MultaSaldoMin,
                             N.value('@CargoAnual', 'MONEY')         AS CargoAnual,
                             N.value('@NumRetirosHumano', 'INT')     AS NumRetiroHumano,
                             N.value('@NumRetirosAutomatico', 'INT') AS NumRetiroAutomatico,
                             N.value('@comisionHumano', 'MONEY')     AS ComisionHumano,
                             N.value('@comisionAutomatico', 'MONEY') AS ComisionAutomatico,
                             N.value('@interes', 'DECIMAL(10,4)')    AS Interes
                      FROM @XmlDatos.nodes(
                                   '/Catalogos/Tipo_Cuenta_Ahorros/TipoCuentaAhorro'
                           ) AS T(N)) AS X
                     ON TCA.Id = X.Id;

                INSERT INTO dbo.TipoCuentaAhorros
                (Id,
                 Nombre,
                 IdTipoMoneda,
                 SaldoMinimo,
                 MultaSaldoMin,
                 CargoAnual,
                 NumRetiroHumano,
                 NumRetiroAutomatico,
                 ComisionHumano,
                 ComisionAutomatico,
                 Interes)
                SELECT N.value('@Id', 'INT'),
                       N.value('@Nombre', 'VARCHAR(64)'),
                       N.value('@IdTipoMoneda', 'INT'),
                       N.value('@SaldoMinimo', 'MONEY'),
                       N.value('@MultaSaldoMin', 'MONEY'),
                       N.value('@CargoAnual', 'MONEY'),
                       N.value('@NumRetirosHumano', 'INT'),
                       N.value('@NumRetirosAutomatico', 'INT'),
                       N.value('@comisionHumano', 'MONEY'),
                       N.value('@comisionAutomatico', 'MONEY'),
                       N.value('@interes', 'DECIMAL(10,4)')
                FROM @XmlDatos.nodes(
                             '/Catalogos/Tipo_Cuenta_Ahorros/TipoCuentaAhorro'
                     ) AS T(N)
                WHERE NOT EXISTS
                          (SELECT 1
                           FROM dbo.TipoCuentaAhorros AS TCA
                           WHERE TCA.Id = N.value('@Id', 'INT'));


                ------------------------------------------------------------
                -- 5. TIPOS DE OPERACION DE BITACORA
                ------------------------------------------------------------

                UPDATE TOB
                SET TOB.Nombre = X.Nombre
                FROM dbo.TipoOperacion AS TOB
                         INNER JOIN
                     (SELECT N.value('@id', 'INT')             AS Id,
                             N.value('@nombre', 'VARCHAR(64)') AS Nombre
                      FROM @XmlDatos.nodes(
                                   '/Catalogos/TipoOperacionesBitacora/TipoOperacion'
                           ) AS T(N)) AS X
                     ON TOB.Id = X.Id;

                INSERT INTO dbo.TipoOperacion
                (Id,
                 Nombre)
                SELECT N.value('@id', 'INT'),
                       N.value('@nombre', 'VARCHAR(64)')
                FROM @XmlDatos.nodes(
                             '/Catalogos/TipoOperacionesBitacora/TipoOperacion'
                     ) AS T(N)
                WHERE NOT EXISTS
                          (SELECT 1
                           FROM dbo.TipoOperacion AS TOB
                           WHERE TOB.Id = N.value('@id', 'INT'));


                ------------------------------------------------------------
                -- FIN
                ------------------------------------------------------------

                COMMIT TRANSACTION;

                SELECT 1                                   AS Resultado,
                       'Catalogos cargados correctamente.' AS Mensaje;

            END TRY
            BEGIN CATCH

                IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION;

                SELECT 0               AS Resultado,
                       ERROR_MESSAGE() AS Mensaje;

            END CATCH
        END;

            CREATE PROCEDURE [dbo].[CargarNoCatalogosXML] @XmlDatos XML
            AS
            BEGIN
                SET NOCOUNT ON;
                SET XACT_ABORT ON;

                BEGIN TRY
                    BEGIN TRANSACTION;

                    ------------------------------------------------------------
                    -- 1. PERSONAS
                    ------------------------------------------------------------
                    INSERT INTO dbo.Persona
                    (TipoDocuIdentidad,
                     Nombre,
                     ValorDocumentoIdentidad,
                     FechaNacimiento,
                     Email,
                     Telefono,
                     Telefono2)
                    SELECT X.N.value('@TipoDocuIdentidad', 'INT'),
                           X.N.value('@Nombre', 'VARCHAR(64)'),
                           X.N.value('@ValorDocumentoIdentidad', 'VARCHAR(64)'),
                           X.N.value('@FechaNacimiento', 'DATE'),
                           X.N.value('@Email', 'VARCHAR(64)'),
                           X.N.value('@telefono1', 'VARCHAR(32)'),
                           X.N.value('@telefono2', 'VARCHAR(32)')
                    FROM @XmlDatos.nodes('/NoCatalogos/Personas/Persona') AS X(N)
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.Persona P
                               WHERE P.ValorDocumentoIdentidad =
                                     X.N.value('@ValorDocumentoIdentidad', 'VARCHAR(64)'));

                    ------------------------------------------------------------
                    -- 2. CUENTAS
                    ------------------------------------------------------------
                    INSERT INTO dbo.Cuenta
                    (IdCliente,
                     IdTipoCuenta,
                     NumeroCuenta,
                     FechaCreacion,
                     Saldo)
                    SELECT P.Id,
                           X.N.value('@TipoCuentaId', 'INT'),
                           X.N.value('@NumeroCuenta', 'VARCHAR(64)'),
                           X.N.value('@FechaCreacion', 'DATE'),
                           X.N.value('@Saldo', 'MONEY')
                    FROM @XmlDatos.nodes('/NoCatalogos/Cuentas/Cuenta') AS X(N)
                             INNER JOIN dbo.Persona P
                                        ON P.ValorDocumentoIdentidad =
                                           X.N.value('@ValorDocumentoIdentidadDelCliente', 'VARCHAR(64)')
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.Cuenta C
                               WHERE C.NumeroCuenta =
                                     X.N.value('@NumeroCuenta', 'VARCHAR(64)'));

                    ------------------------------------------------------------
                    -- 3. BENEFICIARIOS
                    ------------------------------------------------------------
                    INSERT INTO dbo.Beneficiario
                    (IdCuenta,
                     IdBeneficiario,
                     IdParentezco,
                     Porcentaje,
                     flagActivo,
                     FechaDesactivacion)
                    SELECT C.Id,
                           P.Id,
                           X.N.value('@IdParentezco', 'INT'),
                           X.N.value('@Porcentaje', 'INT'),
                           1,
                           NULL
                    FROM @XmlDatos.nodes('/NoCatalogos/Beneficiarios/Beneficiario') AS X(N)
                             INNER JOIN dbo.Cuenta C
                                        ON C.NumeroCuenta =
                                           X.N.value('@NumeroCuenta', 'VARCHAR(64)')
                             INNER JOIN dbo.Persona P
                                        ON P.ValorDocumentoIdentidad =
                                           X.N.value('@ValorDocumentoIdentidadBeneficiario', 'VARCHAR(64)')
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.Beneficiario B
                               WHERE B.IdCuenta = C.Id
                                 AND B.IdBeneficiario = P.Id
                                 AND B.flagActivo = 1);

                    ------------------------------------------------------------
                    -- 4. ESTADOS DE CUENTA
                    ------------------------------------------------------------
                    INSERT INTO dbo.EstadoCuenta
                    (IdCuenta,
                     FechaInicio,
                     FechaFin,
                     SaldoInicial,
                     SaldoFinal,
                     SaldoMinimo,
                     InteresesAcumulados,
                     CantidadRetiros,
                     CantidadDepositos,
                     CantidadSinpeEntrantes,
                     CantidadSinpeSalientes)
                    SELECT C.Id,
                           X.N.value('@fechaInicio', 'DATE'),
                           X.N.value('@fechafin', 'DATE'),
                           X.N.value('@saldoinicial', 'MONEY'),
                           X.N.value('@saldo_final', 'MONEY'),
                           X.N.value('@saldoMinimo', 'MONEY'),
                           X.N.value('@interesesAcumulados', 'MONEY'),
                           X.N.value('@cantRetiros', 'INT'),
                           X.N.value('@cantDepositos', 'INT'),
                           X.N.value('@cantSinpeEntrantes', 'INT'),
                           X.N.value('@cantSinpeSalientes', 'INT')
                    FROM @XmlDatos.nodes('/NoCatalogos/Estados_de_Cuenta/Estado_de_Cuenta') AS X(N)
                             INNER JOIN dbo.Cuenta C
                                        ON C.NumeroCuenta =
                                           X.N.value('@NumeroCuenta', 'VARCHAR(64)')
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.EstadoCuenta EC
                               WHERE EC.IdCuenta = C.Id
                                 AND EC.FechaInicio = X.N.value('@fechaInicio', 'DATE')
                                 AND EC.FechaFin = X.N.value('@fechafin', 'DATE'));

                    ------------------------------------------------------------
                    -- 5. USUARIOS
                    ------------------------------------------------------------
                    INSERT INTO dbo.Usuario
                    ([User],
                     Pass,
                     IdPersona,
                     flagEsAdministrador)
                    SELECT X.N.value('@User', 'VARCHAR(32)'),
                           X.N.value('@Pass', 'VARCHAR(64)'),
                           P.Id,
                           X.N.value('@EsAdministrador', 'BIT')
                    FROM @XmlDatos.nodes('/NoCatalogos/Usuarios/Usuario') AS X(N)
                             INNER JOIN dbo.Persona P
                                        ON P.ValorDocumentoIdentidad =
                                           X.N.value('@ValorDocId', 'VARCHAR(64)')
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.Usuario U
                               WHERE U.[User] =
                                     X.N.value('@User', 'VARCHAR(32)'));

                    ------------------------------------------------------------
                    -- 6. USUARIO VER CUENTAS
                    ------------------------------------------------------------
                    INSERT INTO dbo.UsuarioVer
                    (IdUsuario,
                     IdCuenta)
                    SELECT U.Id,
                           C.Id
                    FROM @XmlDatos.nodes('/NoCatalogos/Usuarios_Ver/UsuarioPuedeVer') AS X(N)
                             INNER JOIN dbo.Usuario U
                                        ON U.[User] =
                                           X.N.value('@User', 'VARCHAR(32)')
                             INNER JOIN dbo.Cuenta C
                                        ON C.NumeroCuenta =
                                           X.N.value('@NumeroCuenta', 'VARCHAR(64)')
                    WHERE NOT EXISTS
                              (SELECT 1
                               FROM dbo.UsuarioVer UV
                               WHERE UV.IdUsuario = U.Id
                                 AND UV.IdCuenta = C.Id);

                    COMMIT TRANSACTION;

                    SELECT 1                                           AS Resultado,
                           'Datos no catalogo cargados correctamente.' AS Mensaje,
                           (SELECT COUNT(*) FROM dbo.Persona)          AS Personas,
                           (SELECT COUNT(*) FROM dbo.Cuenta)           AS Cuentas,
                           (SELECT COUNT(*) FROM dbo.Beneficiario)     AS Beneficiarios,
                           (SELECT COUNT(*) FROM dbo.EstadoCuenta)     AS EstadosCuenta,
                           (SELECT COUNT(*) FROM dbo.Usuario)          AS Usuarios,
                           (SELECT COUNT(*) FROM dbo.UsuarioVer)       AS UsuarioVer;

                END TRY
                BEGIN CATCH

                    IF @@TRANCOUNT > 0
                        ROLLBACK TRANSACTION;

                    SELECT 0               AS Resultado,
                           ERROR_MESSAGE() AS Mensaje;

                END CATCH
            END;

                CREATE PROCEDURE dbo.DeleteBeneficiario @inUser VARCHAR(32),
                                                        @inNumeroCuenta VARCHAR(64),
                                                        @inIdBeneficiario INT
                AS
                BEGIN
                    SET NOCOUNT ON;
                    SET XACT_ABORT ON;

                    BEGIN TRY
                        BEGIN TRANSACTION;

                        DECLARE @IdUsuario INT;
                        DECLARE @IdCuenta INT;
                        DECLARE @EsAdministrador BIT;
                        DECLARE @PorcentajeAnterior INT;
                        DECLARE @SumaPorcentajes INT;

                        SELECT @IdUsuario = Id,
                               @EsAdministrador = flagEsAdministrador
                        FROM dbo.Usuario
                        WHERE [User] = @inUser;

                        IF @IdUsuario IS NULL
                            BEGIN
                                ROLLBACK;
                                SELECT 0 AS Resultado, 'Usuario no encontrado.' AS Mensaje;
                                RETURN;
                            END;

                        SELECT @IdCuenta = Id
                        FROM dbo.Cuenta
                        WHERE NumeroCuenta = @inNumeroCuenta;

                        IF @IdCuenta IS NULL
                            BEGIN
                                ROLLBACK;
                                SELECT 0 AS Resultado, 'Cuenta no encontrada.' AS Mensaje;
                                RETURN;
                            END;

                        IF @EsAdministrador = 0
                            AND NOT EXISTS
                               (SELECT 1
                                FROM dbo.UsuarioVer
                                WHERE IdUsuario = @IdUsuario
                                  AND IdCuenta = @IdCuenta)
                            BEGIN
                                ROLLBACK;
                                SELECT 0                                           AS Resultado,
                                       'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
                                RETURN;
                            END;

                        SELECT @PorcentajeAnterior = Porcentaje
                        FROM dbo.Beneficiario
                        WHERE Id = @inIdBeneficiario
                          AND IdCuenta = @IdCuenta
                          AND flagActivo = 1;

                        IF @PorcentajeAnterior IS NULL
                            BEGIN
                                ROLLBACK;
                                SELECT 0                                    AS Resultado,
                                       'Beneficiario activo no encontrado.' AS Mensaje;
                                RETURN;
                            END;

                        UPDATE dbo.Beneficiario
                        SET flagActivo         = 0,
                            FechaDesactivacion = SYSDATETIME()
                        WHERE Id = @inIdBeneficiario;

                        INSERT INTO dbo.Bitacora
                        (IdUsuario,
                         IdTipoOperacion,
                         IP,
                         DatosAntes,
                         DatosDespues,
                         FechaHora)
                        VALUES (@IdUsuario,
                                5,
                                NULL,
                                (SELECT @inIdBeneficiario   AS IdBeneficiario,
                                        @PorcentajeAnterior AS Porcentaje,
                                        1                   AS flagActivo
                                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                                (SELECT @inIdBeneficiario   AS IdBeneficiario,
                                        @PorcentajeAnterior AS Porcentaje,
                                        0                   AS flagActivo
                                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                                SYSDATETIME());

                        SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
                        FROM dbo.Beneficiario
                        WHERE IdCuenta = @IdCuenta
                          AND flagActivo = 1;
                        COMMIT;

                        SELECT 1                                       AS Resultado,
                               'Beneficiario eliminado correctamente.' AS Mensaje,
                               @SumaPorcentajes                        AS SumaPorcentajes,
                               CASE
                                   WHEN @SumaPorcentajes = 100 THEN 1
                                   ELSE 0
                                   END                                 AS PorcentajesCompletos;

                    END TRY
                    BEGIN CATCH
                        IF @@TRANCOUNT > 0
                            ROLLBACK;

                        SELECT 0               AS Resultado,
                               ERROR_MESSAGE() AS Mensaje;
                    END CATCH
                END;

                    CREATE PROCEDURE [dbo].[GetAccountBeneficiaries] @inCuenta VARCHAR(64) = 0
                    AS
                    BEGIN
                        SET NOCOUNT ON
                        SELECT B.Id                      AS Id,
                               P.Nombre                  AS Nombre,
                               TD.Nombre                 AS DocuID,
                               P.TipoDocuIdentidad       AS TipoDocuIdentidad,
                               TD.Nombre                 AS NombreDocuIdentidad,
                               B.IdParentezco            AS IdParentezco,
                               PT.Nombre                 AS NombreParentezco,
                               B.Porcentaje              AS Porcentaje,
                               P.Email                   AS Email,
                               P.FechaNacimiento         AS FechaNacimiento,
                               P.ValorDocumentoIdentidad AS IdBeneficiario,
                               P.Telefono                AS Telefono,
                               P.Telefono2               AS Telefono2

                        FROM Cuenta AS C
                                 INNER JOIN dbo.Beneficiario B ON C.Id = B.IdCuenta
                                 INNER JOIN dbo.Persona P ON P.Id = B.IdBeneficiario
                                 INNER JOIN dbo.TipoDocuIdentidad TD ON TD.Id = P.TipoDocuIdentidad
                                 INNER JOIN dbo.Parentezco PT ON PT.Id = B.IdParentezco

                                 INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
                                 INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
                        WHERE C.NumeroCuenta = @inCuenta
                          AND B.flagActivo = 1
                    END;

                        CREATE PROCEDURE dbo.GetAccountStatements @inUser VARCHAR(32),
                                                                  @inNumeroCuenta VARCHAR(64)
                        AS
                        BEGIN
                            SET NOCOUNT ON;
                            SET XACT_ABORT ON;

                            BEGIN TRY
                                DECLARE @IdUsuario INT;
                                DECLARE @IdCuenta INT;
                                DECLARE @EsAdministrador BIT;

                                SELECT @IdUsuario = Id,
                                       @EsAdministrador = flagEsAdministrador
                                FROM dbo.Usuario
                                WHERE [User] = @inUser;

                                IF @IdUsuario IS NULL
                                    BEGIN
                                        SELECT 0                        AS Resultado,
                                               'Usuario no encontrado.' AS Mensaje;
                                        RETURN;
                                    END;

                                SELECT @IdCuenta = Id
                                FROM dbo.Cuenta
                                WHERE NumeroCuenta = @inNumeroCuenta;

                                IF @IdCuenta IS NULL
                                    BEGIN
                                        SELECT 0                       AS Resultado,
                                               'Cuenta no encontrada.' AS Mensaje;
                                        RETURN;
                                    END;

                                IF @EsAdministrador = 0
                                    AND NOT EXISTS
                                       (SELECT 1
                                        FROM dbo.UsuarioVer
                                        WHERE IdUsuario = @IdUsuario
                                          AND IdCuenta = @IdCuenta)
                                    BEGIN
                                        SELECT 0                                           AS Resultado,
                                               'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
                                        RETURN;
                                    END;

                                INSERT INTO dbo.Bitacora
                                (IdUsuario,
                                 IdTipoOperacion,
                                 IP,
                                 DatosAntes,
                                 DatosDespues,
                                 FechaHora)
                                VALUES (@IdUsuario,
                                        7,
                                        NULL,
                                        NULL,
                                        NULL,
                                        SYSDATETIME());

                                SELECT TOP (8) EC.Id,
                                               C.NumeroCuenta,
                                               EC.FechaInicio,
                                               EC.FechaFin,
                                               EC.SaldoInicial,
                                               EC.SaldoFinal,
                                               EC.SaldoMinimo,
                                               EC.InteresesAcumulados,
                                               EC.CantidadRetiros,
                                               EC.CantidadDepositos,
                                               EC.CantidadSinpeEntrantes,
                                               EC.CantidadSinpeSalientes
                                FROM dbo.EstadoCuenta EC
                                         INNER JOIN dbo.Cuenta C
                                                    ON C.Id = EC.IdCuenta
                                WHERE EC.IdCuenta = @IdCuenta
                                ORDER BY EC.FechaFin DESC,
                                         EC.Id DESC;

                            END TRY
                            BEGIN CATCH
                                SELECT 0               AS Resultado,
                                       ERROR_MESSAGE() AS Mensaje;
                            END CATCH
                        END;


                            CREATE PROCEDURE GetEmpleados
                            AS
                            BEGIN
                                SELECT *
                                FROM Empleado
                                ORDER BY Empleado.Nombre
                            END;

-- EXEC GetEmpleados;

                                CREATE PROCEDURE [dbo].[GetParentescos]
                                AS
                                BEGIN
                                    SET NOCOUNT ON
                                    SELECT Id, Nombre FROM Parentezco
                                END;

                                    CREATE PROCEDURE dbo.GetPorcentajeBeneficiarios @inCuenta VARCHAR(64)
                                    AS
                                    BEGIN
                                        SELECT SUM(Porcentaje) AS Total
                                        FROM Beneficiario AS B
                                                 INNER JOIN Cuenta AS C ON C.Id = B.IdCuenta
                                        WHERE C.NumeroCuenta = @inCuenta
                                          AND B.flagActivo = 1
                                    END;

                                        CREATE PROCEDURE [dbo].[GetTipoDocId]
                                        AS
                                        BEGIN
                                            SET NOCOUNT ON
                                            SELECT Id, Nombre FROM TipoDocuIdentidad
                                        END;

                                            CREATE PROCEDURE dbo.GetUserAccounts @inUser VARCHAR(32)
                                            AS
                                            BEGIN
                                                SET NOCOUNT ON;

                                                DECLARE @IdUsuario INT;
                                                DECLARE @EsAdministrador BIT;

                                                SELECT @IdUsuario = Id,
                                                       @EsAdministrador = flagEsAdministrador
                                                FROM dbo.Usuario
                                                WHERE [User] = @inUser;

                                                IF @IdUsuario IS NULL
                                                    BEGIN
                                                        SELECT 0                        AS Resultado,
                                                               'Usuario no encontrado.' AS Mensaje;
                                                        RETURN;
                                                    END;

                                                SELECT C.Id,
                                                       C.NumeroCuenta,
                                                       C.Saldo,
                                                       TC.Nombre AS TipoCuenta,
                                                       TM.Nombre AS Moneda,
                                                       TM.Simbolo
                                                FROM dbo.Cuenta C
                                                         INNER JOIN dbo.TipoCuentaAhorros TC
                                                                    ON TC.Id = C.IdTipoCuenta
                                                         INNER JOIN dbo.TipoMoneda TM
                                                                    ON TM.Id = TC.IdTipoMoneda
                                                WHERE @EsAdministrador = 1
                                                   OR EXISTS
                                                    (SELECT 1
                                                     FROM dbo.UsuarioVer UV
                                                     WHERE UV.IdUsuario = @IdUsuario
                                                       AND UV.IdCuenta = C.Id)
                                                ORDER BY C.NumeroCuenta;
                                            END;

                                                CREATE PROCEDURE InsertarEmpleado @Nombre VARCHAR(128),
                                                                                  @Salario MONEY
                                                AS

                                                BEGIN

                                                    SET NOCOUNT ON;

                                                    IF EXISTS (SELECT 1
                                                               FROM Empleado
                                                               WHERE Nombre = @Nombre)
                                                        BEGIN
                                                            SELECT 1 AS Codigo;
                                                            RETURN;
                                                        END

                                                    INSERT INTO Empleado (Nombre, Salario)
                                                    VALUES (@Nombre, @Salario);

                                                    SELECT 0 AS Codigo;

                                                END;

                                                    -- 0 = Inserción exitosa
-- 1 = Nombre de empleado ya existe;

                                                    CREATE PROCEDURE dbo.Login @inUser VARCHAR(32),
                                                                               @inPass VARCHAR(64),
                                                                               @inIP VARCHAR(64) = NULL
                                                    AS
                                                    BEGIN
                                                        SET NOCOUNT ON;

                                                        DECLARE @IdUsuario INT;

                                                        SELECT @IdUsuario = Id
                                                        FROM dbo.Usuario
                                                        WHERE [User] = @inUser
                                                          AND Pass = @inPass;

                                                        IF @IdUsuario IS NULL
                                                            BEGIN
                                                                SELECT 0                                   AS Resultado,
                                                                       'Usuario o contraseña incorrectos.' AS Mensaje;
                                                                RETURN;
                                                            END;

                                                        INSERT INTO dbo.Bitacora
                                                        (IdUsuario,
                                                         IdTipoOperacion,
                                                         IP,
                                                         DatosAntes,
                                                         DatosDespues,
                                                         FechaHora)
                                                        VALUES (@IdUsuario,
                                                                1,
                                                                @inIP,
                                                                NULL,
                                                                NULL,
                                                                SYSDATETIME());

                                                        SELECT 1                 AS Resultado,
                                                               'Login correcto.' AS Mensaje,
                                                               U.Id,
                                                               U.[User],
                                                               U.flagEsAdministrador
                                                        FROM dbo.Usuario U
                                                        WHERE U.Id = @IdUsuario;
                                                    END;

                                                        CREATE PROCEDURE [dbo].[UpdateBeneficiario] @inId INT,
                                                                                                    @inPorcentaje INT,
                                                                                                    @inNombre VARCHAR(64),
                                                                                                    @inParentesco INT,
                                                                                                    @inUsuario VARCHAR(32),
                                                                                                    @inIP VARCHAR(64) = NULL
                                                        AS
                                                        BEGIN
                                                            SET NOCOUNT ON

                                                            IF NOT EXISTS (SELECT 1 FROM Beneficiario WHERE Id = @inId)
                                                                THROW 50001, 'Beneficiario invalido.', 1;

                                                            IF NOT EXISTS (SELECT 1 FROM Parentezco WHERE Id = @inParentesco)
                                                                THROW 50002, 'Parentesco invalido.', 1;

                                                            BEGIN TRY
                                                                BEGIN TRAN;

                                                                DECLARE @IdUsuario INT;

                                                                SELECT @IdUsuario = Id
                                                                FROM dbo.Usuario
                                                                WHERE [User] = @inUsuario;

                                                                INSERT INTO dbo.Bitacora
                                                                (IdUsuario, IdTipoOperacion, IP,
                                                                 DatosAntes, DatosDespues, FechaHora)
                                                                VALUES (@IdUsuario, 4, @inIP,
                                                                        NULL, NULL, SYSDATETIME());

                                                                -- Actualizar Parentezco
                                                                UPDATE Beneficiario
                                                                SET IdParentezco = @inParentesco
                                                                WHERE Id = @inId

                                                                -- Actualizar porcentaje
                                                                UPDATE Beneficiario
                                                                SET Porcentaje = @inPorcentaje
                                                                WHERE Id = @inId

                                                                -- Actualizar Nombre de persona
                                                                UPDATE P
                                                                SET Nombre = @inNombre
                                                                FROM Persona AS P
                                                                         INNER JOIN Beneficiario AS B ON B.IdBeneficiario = P.Id
                                                                WHERE B.Id = @inId
                                                                COMMIT
                                                                SELECT 0 AS Codigo
                                                            END TRY
                                                            BEGIN CATCH
                                                                IF @@TRANCOUNT > 0 ROLLBACK;
                                                                THROW; -- re-raise the original error to the caller
                                                            END CATCH
                                                        END;


