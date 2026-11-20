-- =============================================
-- Script: CreationScript
-- Descripcion: Crea todas las tablas, el trigger
-- y los procedimientos de la base de cuentas de
-- ahorro (tercera tarea).
-- =============================================

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

GO

-- =============================================
-- Trigger: TR_Cuenta_AperturaEstadoCuenta
-- Descripcion: Crea el primer estado de cuenta
-- de cada cuenta nueva. El periodo va desde la
-- fecha de creacion hasta el mismo dia del mes
-- siguiente, que es cuando se hace el cierre.
-- =============================================
CREATE OR ALTER TRIGGER dbo.TR_Cuenta_AperturaEstadoCuenta
ON dbo.Cuenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Se toma de "inserted" para cubrir el caso en que
    -- se inserten varias cuentas en una misma sentencia
    INSERT INTO dbo.EstadoCuenta
    (
        IdCuenta,
        FechaInicio,
        FechaFin,
        SaldoInicial,
        SaldoFinal,
        SaldoMinimo
    )
    SELECT
        I.Id,
        I.FechaCreacion,
        DATEADD(MONTH, 1, I.FechaCreacion),
        I.Saldo,
        I.Saldo,
        I.Saldo
    FROM inserted AS I;
END;

GO

-- =============================================
-- Procedimiento: AbrirEstadoCuenta
-- Descripcion: Abre el estado de cuenta del
-- siguiente periodo de una cuenta. El periodo
-- empieza el dia despues del cierre y termina
-- el mismo dia del mes en que se creo la cuenta.
-- No abre una transaccion propia, se llama desde
-- CerrarEstadoCuenta dentro de su transaccion.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AbrirEstadoCuenta]
    @inIdCuenta INT,
    @inFechaCierre DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaCreacion DATE;
    DECLARE @Saldo MONEY;
    DECLARE @FechaInicio DATE;
    DECLARE @FechaFin DATE;

    SELECT
        @FechaCreacion = C.FechaCreacion,
        @Saldo = C.Saldo
    FROM dbo.Cuenta AS C
    WHERE C.Id = @inIdCuenta;

    IF @FechaCreacion IS NULL
        THROW 50002, 'Cuenta no encontrada.', 1;

    SET @FechaInicio = DATEADD(DAY, 1, @inFechaCierre);

    -- La fecha de cierre se calcula a partir de la fecha de creacion
    -- y no del cierre anterior. Asi una cuenta creada un 31 cierra el
    -- ultimo dia de los meses cortos y vuelve al 31 cuando el mes lo tiene.
    SET @FechaFin = DATEADD(MONTH, DATEDIFF(MONTH, @FechaCreacion, @inFechaCierre) + 1, @FechaCreacion);

    INSERT INTO dbo.EstadoCuenta
    (
        IdCuenta,
        FechaInicio,
        FechaFin,
        SaldoInicial,
        SaldoFinal,
        SaldoMinimo
    )
    VALUES
    (
        @inIdCuenta,
        @FechaInicio,
        @FechaFin,
        @Saldo,
        @Saldo,
        @Saldo
    );

    RETURN 0;
END;

GO

CREATE OR ALTER PROCEDURE dbo.ActualizarPorcentajeBeneficiario
    @inUser VARCHAR(32),
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

        SELECT
            @IdUsuario = Id,
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
           (
               SELECT 1
               FROM dbo.UsuarioVer
               WHERE IdUsuario = @IdUsuario
                 AND IdCuenta = @IdCuenta
           )
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
                   'El usuario no tiene acceso a esta cuenta.' AS Mensaje;
            RETURN;
        END;

        IF @inNuevoPorcentaje <= 0 OR @inNuevoPorcentaje > 100
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
                   'El porcentaje debe estar entre 1 y 100.' AS Mensaje;
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
            SELECT 0 AS Resultado,
                   'Beneficiario activo no encontrado.' AS Mensaje;
            RETURN;
        END;

        UPDATE dbo.Beneficiario
        SET Porcentaje = @inNuevoPorcentaje
        WHERE Id = @inIdBeneficiario;

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            6,
            NULL,
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @inNuevoPorcentaje AS Porcentaje
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            SYSDATETIME()
        );

        SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
        FROM dbo.Beneficiario
        WHERE IdCuenta = @IdCuenta
          AND flagActivo = 1;

        COMMIT;

        SELECT
            1 AS Resultado,
            'Porcentaje actualizado correctamente.' AS Mensaje,
            @SumaPorcentajes AS SumaPorcentajes,
            CASE
                WHEN @SumaPorcentajes = 100 THEN 1
                ELSE 0
            END AS PorcentajesCompletos;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;

GO

CREATE PROCEDURE [dbo].[AgregarBeneficiario]
    @inUser VARCHAR(32),
    @inNumeroCuenta VARCHAR(64),

    @inTipoDocuIdentidad INT,
    @inNombre VARCHAR(64),
    @inValorDocumentoIdentidad VARCHAR(64),
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
        DECLARE @IdNuevoBeneficiario INT;
        DECLARE @EsAdministrador BIT;
        DECLARE @DatosDespues NVARCHAR(MAX);
        DECLARE @SumaPorcentajes INT;


        ------------------------------------------------------------
        -- 1. VALIDAR PORCENTAJE
        ------------------------------------------------------------

        IF @inPorcentaje < 0 OR @inPorcentaje > 100
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                0 AS Resultado,
                'El porcentaje debe estar entre 0 y 100.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 2. OBTENER USUARIO
        ------------------------------------------------------------

        SELECT
            @IdUsuario = U.Id,
            @EsAdministrador = U.flagEsAdministrador
        FROM dbo.Usuario AS U
        WHERE U.[User] = @inUser;


        IF @IdUsuario IS NULL
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                0 AS Resultado,
                'Usuario no encontrado.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 3. OBTENER CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = C.Id
        FROM dbo.Cuenta AS C
        WHERE C.NumeroCuenta = @inNumeroCuenta;


        IF @IdCuenta IS NULL
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                0 AS Resultado,
                'Cuenta no encontrada.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 4. VALIDAR PERMISO DEL USUARIO
        ------------------------------------------------------------

        IF ISNULL(@EsAdministrador, 0) = 0
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UsuarioVer AS UV
                WHERE UV.IdUsuario = @IdUsuario
                  AND UV.IdCuenta = @IdCuenta
            )
            BEGIN
                ROLLBACK TRANSACTION;

                SELECT
                    0 AS Resultado,
                    'El usuario no tiene acceso a esta cuenta.' AS Mensaje;

                RETURN;
            END;
        END;


        ------------------------------------------------------------
        -- 5. MAXIMO 3 BENEFICIARIOS ACTIVOS
        ------------------------------------------------------------

        IF
        (
            SELECT COUNT(*)
            FROM dbo.Beneficiario
            WHERE IdCuenta = @IdCuenta
              AND flagActivo = 1
        ) >= 3
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                0 AS Resultado,
                'La cuenta ya tiene 3 beneficiarios activos.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 6. BUSCAR PERSONA POR DOCUMENTO
        ------------------------------------------------------------

        SELECT
            @IdPersona = P.Id
        FROM dbo.Persona AS P
        WHERE P.ValorDocumentoIdentidad =
              @inValorDocumentoIdentidad;


        ------------------------------------------------------------
        -- 7. VERIFICAR QUE NO SEA BENEFICIARIO ACTIVO YA
        ------------------------------------------------------------

        IF @IdPersona IS NOT NULL
           AND EXISTS
        (
            SELECT 1
            FROM dbo.Beneficiario AS B
            WHERE B.IdCuenta = @IdCuenta
              AND B.IdBeneficiario = @IdPersona
              AND B.flagActivo = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                0 AS Resultado,
                'La persona ya es beneficiaria activa de esta cuenta.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 8. SI LA PERSONA NO EXISTE, CREARLA
        ------------------------------------------------------------

        IF @IdPersona IS NULL
        BEGIN
            INSERT INTO dbo.Persona
            (
                TipoDocuIdentidad,
                Nombre,
                ValorDocumentoIdentidad,
                FechaNacimiento,
                Email,
                Telefono,
                Telefono2
            )
            VALUES
            (
                @inTipoDocuIdentidad,
                @inNombre,
                @inValorDocumentoIdentidad,
                @inFechaNacimiento,
                @inEmail,
                @inTelefono,
                @inTelefono2
            );

            SET @IdPersona = SCOPE_IDENTITY();
        END;


        ------------------------------------------------------------
        -- 9. AGREGAR BENEFICIARIO
        ------------------------------------------------------------

        INSERT INTO dbo.Beneficiario
        (
            IdCuenta,
            IdBeneficiario,
            IdParentezco,
            Porcentaje,
            flagActivo,
            FechaDesactivacion
        )
        VALUES
        (
            @IdCuenta,
            @IdPersona,
            @inIdParentezco,
            @inPorcentaje,
            1,
            NULL
        );

        SET @IdNuevoBeneficiario = SCOPE_IDENTITY();


        ------------------------------------------------------------
        -- 10. CREAR JSON PARA BITACORA
        ------------------------------------------------------------

        SET @DatosDespues =
        (
            SELECT
                B.Id AS IdBeneficiario,
                C.NumeroCuenta,
                P.ValorDocumentoIdentidad,
                P.Nombre,
                B.IdParentezco,
                B.Porcentaje,
                B.flagActivo
            FROM dbo.Beneficiario AS B

            INNER JOIN dbo.Cuenta AS C
                ON C.Id = B.IdCuenta

            INNER JOIN dbo.Persona AS P
                ON P.Id = B.IdBeneficiario

            WHERE B.Id = @IdNuevoBeneficiario

            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );


        ------------------------------------------------------------
        -- 11. BITACORA
        -- TipoOperacion 3 = Agregar beneficiario
        ------------------------------------------------------------

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            3,
            NULL,
            NULL,
            @DatosDespues,
            SYSDATETIME()
        );


        ------------------------------------------------------------
        -- 12. CALCULAR SUMA ACTUAL DE PORCENTAJES
        ------------------------------------------------------------

        SELECT
            @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
        FROM dbo.Beneficiario
        WHERE IdCuenta = @IdCuenta
          AND flagActivo = 1;


        COMMIT TRANSACTION;


        ------------------------------------------------------------
        -- RESULTADO
        ------------------------------------------------------------

        SELECT
            1 AS Resultado,
            'Beneficiario agregado correctamente.' AS Mensaje,
            @IdNuevoBeneficiario AS IdBeneficiario,
            @SumaPorcentajes AS SumaPorcentajes,
            CASE
                WHEN @SumaPorcentajes = 100 THEN 1
                ELSE 0
            END AS PorcentajesCompletos;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO

-- =============================================
-- Procedimiento: AplicarMovimiento
-- Descripcion: Aplica un movimiento a una cuenta.
-- Actualiza el saldo de la cuenta, registra el
-- movimiento con el saldo resultante y actualiza
-- el estado de cuenta cuyo rango de fechas incluye
-- la fecha del movimiento.
-- No abre una transaccion propia, debe llamarse
-- dentro de la transaccion del procedimiento que
-- lo invoca.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AplicarMovimiento]
    @inIdCuenta INT,
    @inIdTipoMovimiento INT,
    @inFecha DATE,
    @inMonto MONEY,
    @inDescripcion VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EsCredito BIT;
    DECLARE @SaldoActual MONEY;
    DECLARE @NuevoSaldo MONEY;

    ------------------------------------------------------------
    -- 1. VALIDAR TIPO DE MOVIMIENTO Y CUENTA
    ------------------------------------------------------------

    SELECT @EsCredito = TM.flagEsCredito
    FROM dbo.TipoMovimiento AS TM
    WHERE TM.Id = @inIdTipoMovimiento;

    IF @EsCredito IS NULL
        THROW 50001, 'Tipo de movimiento invalido.', 1;

    SELECT @SaldoActual = C.Saldo
    FROM dbo.Cuenta AS C
    WHERE C.Id = @inIdCuenta;

    IF @SaldoActual IS NULL
        THROW 50002, 'Cuenta no encontrada.', 1;


    ------------------------------------------------------------
    -- 2. CALCULAR EL NUEVO SALDO
    -- Los creditos suman al saldo y los debitos restan
    ------------------------------------------------------------

    IF @EsCredito = 1
        SET @NuevoSaldo = @SaldoActual + @inMonto;
    ELSE
        SET @NuevoSaldo = @SaldoActual - @inMonto;


    ------------------------------------------------------------
    -- 3. ACTUALIZAR SALDO Y REGISTRAR EL MOVIMIENTO
    ------------------------------------------------------------

    UPDATE dbo.Cuenta
    SET Saldo = @NuevoSaldo
    WHERE Id = @inIdCuenta;

    INSERT INTO dbo.Movimiento
    (
        IdCuenta,
        IdTipoMovimiento,
        Fecha,
        Monto,
        Descripcion,
        NuevoSaldo
    )
    VALUES
    (
        @inIdCuenta,
        @inIdTipoMovimiento,
        @inFecha,
        @inMonto,
        @inDescripcion,
        @NuevoSaldo
    );


    ------------------------------------------------------------
    -- 4. ACTUALIZAR EL ESTADO DE CUENTA DEL PERIODO
    -- Segun el catalogo de tipos de movimiento:
    --   1 Deposito Ventana y 5 Retiro Ventana  -> cajero humano
    --   2 Deposito ATM y 4 Retiro ATM          -> cajero automatico
    --   8 Deposito Sinpe y 9 Retiro Sinpe      -> Sinpe
    ------------------------------------------------------------

    UPDATE dbo.EstadoCuenta
    SET SaldoFinal = @NuevoSaldo,
        SaldoMinimo =
            CASE
                WHEN @NuevoSaldo < SaldoMinimo THEN @NuevoSaldo
                ELSE SaldoMinimo
            END,
        CantidadOperacionesATM = CantidadOperacionesATM +
            CASE
                WHEN @inIdTipoMovimiento IN (2, 4) THEN 1
                ELSE 0
            END,
        CantidadOperacionesHumano = CantidadOperacionesHumano +
            CASE
                WHEN @inIdTipoMovimiento IN (1, 5) THEN 1
                ELSE 0
            END,
        CantidadOperacionesSinpe = CantidadOperacionesSinpe +
            CASE
                WHEN @inIdTipoMovimiento IN (8, 9) THEN 1
                ELSE 0
            END
    WHERE IdCuenta = @inIdCuenta
      AND @inFecha BETWEEN FechaInicio AND FechaFin;

    RETURN 0;
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[CargarCatalogosXML]
    @XmlDatos XML
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
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(64)') AS Nombre
            FROM @XmlDatos.nodes('/Catalogos/Tipo_Doc/TipoDocuIdentidad') AS T(N)
        ) AS X
            ON TD.Id = X.Id;

        INSERT INTO dbo.TipoDocuIdentidad
        (
            Id,
            Nombre
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(64)')
        FROM @XmlDatos.nodes('/Catalogos/Tipo_Doc/TipoDocuIdentidad') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoDocuIdentidad AS TD
            WHERE TD.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 2. TIPO DE MONEDA
        ------------------------------------------------------------

        UPDATE TM
        SET TM.Nombre  = X.Nombre,
            TM.Simbolo = X.Simbolo
        FROM dbo.TipoMoneda AS TM
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(32)') AS Nombre,
                N.value('@Simbolo', 'NVARCHAR(4)') AS Simbolo
            FROM @XmlDatos.nodes('/Catalogos/Tipo_Moneda/TipoMoneda') AS T(N)
        ) AS X
            ON TM.Id = X.Id;

        INSERT INTO dbo.TipoMoneda
        (
            Id,
            Nombre,
            Simbolo
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(32)'),
            N.value('@Simbolo', 'NVARCHAR(4)')
        FROM @XmlDatos.nodes('/Catalogos/Tipo_Moneda/TipoMoneda') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoMoneda AS TM
            WHERE TM.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 3. PARENTEZCOS
        ------------------------------------------------------------

        UPDATE P
        SET P.Nombre = X.Nombre
        FROM dbo.Parentezco AS P
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(32)') AS Nombre
            FROM @XmlDatos.nodes('/Catalogos/Parentezcos/Parentezco') AS T(N)
        ) AS X
            ON P.Id = X.Id;

        INSERT INTO dbo.Parentezco
        (
            Id,
            Nombre
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(32)')
        FROM @XmlDatos.nodes('/Catalogos/Parentezcos/Parentezco') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Parentezco AS P
            WHERE P.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 4. TIPOS DE CUENTA DE AHORROS
        ------------------------------------------------------------

        UPDATE TCA
        SET TCA.Nombre              = X.Nombre,
            TCA.IdTipoMoneda        = X.IdTipoMoneda,
            TCA.SaldoMinimo         = X.SaldoMinimo,
            TCA.MultaSaldoMin       = X.MultaSaldoMin,
            TCA.CargoMensual        = X.CargoMensual,
            TCA.NumRetiroHumano     = X.NumRetiroHumano,
            TCA.NumRetiroAutomatico = X.NumRetiroAutomatico,
            TCA.ComisionHumano      = X.ComisionHumano,
            TCA.ComisionAutomatico  = X.ComisionAutomatico,
            TCA.MontoMaxSinpeDiario = X.MontoMaxSinpeDiario,
            TCA.ComisionSinpe       = X.ComisionSinpe,
            TCA.TasaInteresAnual    = X.TasaInteresAnual
        FROM dbo.TipoCuentaAhorros AS TCA
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(64)') AS Nombre,
                N.value('@IdTipoMoneda', 'INT') AS IdTipoMoneda,
                N.value('@SaldoMinimo', 'MONEY') AS SaldoMinimo,
                N.value('@MultaSaldoMin', 'MONEY') AS MultaSaldoMin,
                N.value('@CargoMensual', 'MONEY') AS CargoMensual,
                N.value('@NumRetirosHumano', 'INT') AS NumRetiroHumano,
                N.value('@NumRetirosAutomatico', 'INT') AS NumRetiroAutomatico,
                N.value('@ComisionHumano', 'MONEY') AS ComisionHumano,
                N.value('@ComisionAutomatico', 'MONEY') AS ComisionAutomatico,
                N.value('@MontoMaxSinpeDiario', 'MONEY') AS MontoMaxSinpeDiario,
                N.value('@ComisionSinpe', 'MONEY') AS ComisionSinpe,
                N.value('@TasaInteresAnual', 'DECIMAL(10,4)') AS TasaInteresAnual
            FROM @XmlDatos.nodes('/Catalogos/Tipo_Cuenta_Ahorros/TipoCuentaAhorro') AS T(N)
        ) AS X
            ON TCA.Id = X.Id;

        INSERT INTO dbo.TipoCuentaAhorros
        (
            Id,
            Nombre,
            IdTipoMoneda,
            SaldoMinimo,
            MultaSaldoMin,
            CargoMensual,
            NumRetiroHumano,
            NumRetiroAutomatico,
            ComisionHumano,
            ComisionAutomatico,
            MontoMaxSinpeDiario,
            ComisionSinpe,
            TasaInteresAnual
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(64)'),
            N.value('@IdTipoMoneda', 'INT'),
            N.value('@SaldoMinimo', 'MONEY'),
            N.value('@MultaSaldoMin', 'MONEY'),
            N.value('@CargoMensual', 'MONEY'),
            N.value('@NumRetirosHumano', 'INT'),
            N.value('@NumRetirosAutomatico', 'INT'),
            N.value('@ComisionHumano', 'MONEY'),
            N.value('@ComisionAutomatico', 'MONEY'),
            N.value('@MontoMaxSinpeDiario', 'MONEY'),
            N.value('@ComisionSinpe', 'MONEY'),
            N.value('@TasaInteresAnual', 'DECIMAL(10,4)')
        FROM @XmlDatos.nodes('/Catalogos/Tipo_Cuenta_Ahorros/TipoCuentaAhorro') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoCuentaAhorros AS TCA
            WHERE TCA.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 5. TIPOS DE MOVIMIENTO
        ------------------------------------------------------------

        UPDATE TMV
        SET TMV.Nombre                = X.Nombre,
            TMV.flagEsCredito         = X.flagEsCredito,
            TMV.flagGeneraComprobante = X.flagGeneraComprobante
        FROM dbo.TipoMovimiento AS TMV
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(64)') AS Nombre,
                CASE
                    WHEN N.value('@Accion', 'VARCHAR(16)') = 'Credito' THEN 1
                    ELSE 0
                END AS flagEsCredito,
                N.value('@flagGeneraComprobante', 'BIT') AS flagGeneraComprobante
            FROM @XmlDatos.nodes('/Catalogos/Tipos_Movimiento/TipoMovimiento') AS T(N)
        ) AS X
            ON TMV.Id = X.Id;

        INSERT INTO dbo.TipoMovimiento
        (
            Id,
            Nombre,
            flagEsCredito,
            flagGeneraComprobante
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(64)'),
            CASE
                WHEN N.value('@Accion', 'VARCHAR(16)') = 'Credito' THEN 1
                ELSE 0
            END,
            N.value('@flagGeneraComprobante', 'BIT')
        FROM @XmlDatos.nodes('/Catalogos/Tipos_Movimiento/TipoMovimiento') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoMovimiento AS TMV
            WHERE TMV.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 6. TIPOS DE OPERACION DE BITACORA
        ------------------------------------------------------------

        UPDATE TOB
        SET TOB.Nombre = X.Nombre
        FROM dbo.TipoOperacion AS TOB
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(64)') AS Nombre
            FROM @XmlDatos.nodes('/Catalogos/TipoOperacionesBitacora/TipoOperacion') AS T(N)
        ) AS X
            ON TOB.Id = X.Id;

        INSERT INTO dbo.TipoOperacion
        (
            Id,
            Nombre
        )
        SELECT
            N.value('@Id', 'INT'),
            N.value('@Nombre', 'VARCHAR(64)')
        FROM @XmlDatos.nodes('/Catalogos/TipoOperacionesBitacora/TipoOperacion') AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoOperacion AS TOB
            WHERE TOB.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- FIN
        ------------------------------------------------------------

        COMMIT TRANSACTION;

        SELECT
            1 AS Resultado,
            'Catalogos cargados correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[CargarNoCatalogosXML]
    @XmlDatos XML
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
        (
            TipoDocuIdentidad,
            Nombre,
            ValorDocumentoIdentidad,
            FechaNacimiento,
            Email,
            Telefono,
            Telefono2
        )
        SELECT
            X.N.value('@TipoDocuIdentidad', 'INT'),
            X.N.value('@Nombre', 'VARCHAR(64)'),
            X.N.value('@ValorDocumentoIdentidad', 'VARCHAR(64)'),
            X.N.value('@FechaNacimiento', 'DATE'),
            X.N.value('@Email', 'VARCHAR(64)'),
            X.N.value('@telefono1', 'VARCHAR(32)'),
            X.N.value('@telefono2', 'VARCHAR(32)')
        FROM @XmlDatos.nodes('/NoCatalogos/Personas/Persona') AS X(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Persona P
            WHERE P.ValorDocumentoIdentidad =
                  X.N.value('@ValorDocumentoIdentidad', 'VARCHAR(64)')
        );

        ------------------------------------------------------------
        -- 2. CUENTAS
        ------------------------------------------------------------
        INSERT INTO dbo.Cuenta
        (
            IdCliente,
            IdTipoCuenta,
            NumeroCuenta,
            FechaCreacion,
            Saldo
        )
        SELECT
            P.Id,
            X.N.value('@TipoCuentaId', 'INT'),
            X.N.value('@NumeroCuenta', 'VARCHAR(64)'),
            X.N.value('@FechaCreacion', 'DATE'),
            X.N.value('@Saldo', 'MONEY')
        FROM @XmlDatos.nodes('/NoCatalogos/Cuentas/Cuenta') AS X(N)
        INNER JOIN dbo.Persona P
            ON P.ValorDocumentoIdentidad =
               X.N.value('@ValorDocumentoIdentidadDelCliente', 'VARCHAR(64)')
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Cuenta C
            WHERE C.NumeroCuenta =
                  X.N.value('@NumeroCuenta', 'VARCHAR(64)')
        );

        ------------------------------------------------------------
        -- 3. BENEFICIARIOS
        ------------------------------------------------------------
        INSERT INTO dbo.Beneficiario
        (
            IdCuenta,
            IdBeneficiario,
            IdParentezco,
            Porcentaje,
            flagActivo,
            FechaDesactivacion
        )
        SELECT
            C.Id,
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
        (
            SELECT 1
            FROM dbo.Beneficiario B
            WHERE B.IdCuenta = C.Id
              AND B.IdBeneficiario = P.Id
              AND B.flagActivo = 1
        );

        ------------------------------------------------------------
        -- 4. USUARIOS
        ------------------------------------------------------------
        INSERT INTO dbo.Usuario
        (
            [User],
            Pass,
            IdPersona,
            flagEsAdministrador
        )
        SELECT
            X.N.value('@User', 'VARCHAR(32)'),
            X.N.value('@Pass', 'VARCHAR(64)'),
            P.Id,
            X.N.value('@EsAdministrador', 'BIT')
        FROM @XmlDatos.nodes('/NoCatalogos/Usuarios/Usuario') AS X(N)
        INNER JOIN dbo.Persona P
            ON P.ValorDocumentoIdentidad =
               X.N.value('@ValorDocId', 'VARCHAR(64)')
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuario U
            WHERE U.[User] =
                  X.N.value('@User', 'VARCHAR(32)')
        );

        ------------------------------------------------------------
        -- 5. USUARIO VER CUENTAS
        ------------------------------------------------------------
        INSERT INTO dbo.UsuarioVer
        (
            IdUsuario,
            IdCuenta
        )
        SELECT
            U.Id,
            C.Id
        FROM @XmlDatos.nodes('/NoCatalogos/Usuarios_Ver/UsuarioPuedeVer') AS X(N)
        INNER JOIN dbo.Usuario U
            ON U.[User] =
               X.N.value('@User', 'VARCHAR(32)')
        INNER JOIN dbo.Cuenta C
            ON C.NumeroCuenta =
               X.N.value('@NumeroCuenta', 'VARCHAR(64)')
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.UsuarioVer UV
            WHERE UV.IdUsuario = U.Id
              AND UV.IdCuenta = C.Id
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Resultado,
            'Datos no catalogo cargados correctamente.' AS Mensaje,
            (SELECT COUNT(*) FROM dbo.Persona) AS Personas,
            (SELECT COUNT(*) FROM dbo.Cuenta) AS Cuentas,
            (SELECT COUNT(*) FROM dbo.Beneficiario) AS Beneficiarios,
            (SELECT COUNT(*) FROM dbo.EstadoCuenta) AS EstadosCuenta,
            (SELECT COUNT(*) FROM dbo.Usuario) AS Usuarios,
            (SELECT COUNT(*) FROM dbo.UsuarioVer) AS UsuarioVer;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO

-- =============================================
-- Procedimiento: CerrarEstadoCuenta
-- Descripcion: Cierra un estado de cuenta en su
-- fecha final. Genera los movimientos de cierre
-- (intereses, comisiones por exceso de operaciones,
-- multa por saldo minimo y cargo por servicio) y
-- abre el estado de cuenta del siguiente periodo.
-- Todo se hace en una sola transaccion por cuenta.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[CerrarEstadoCuenta]
    @inIdEstadoCuenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCuenta INT;
    DECLARE @FechaCierre DATE;
    DECLARE @SaldoMinimoMes MONEY;
    DECLARE @CantidadATM INT;
    DECLARE @CantidadHumano INT;

    DECLARE @SaldoMinimoPermitido MONEY;
    DECLARE @MultaSaldoMin MONEY;
    DECLARE @CargoMensual MONEY;
    DECLARE @NumRetiroHumano INT;
    DECLARE @NumRetiroAutomatico INT;
    DECLARE @ComisionHumano MONEY;
    DECLARE @ComisionAutomatico MONEY;
    DECLARE @TasaInteresAnual DECIMAL(10, 4);

    DECLARE @Monto MONEY;

    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. DATOS DEL ESTADO DE CUENTA Y DE SU TIPO DE CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = EC.IdCuenta,
            @FechaCierre = EC.FechaFin,
            @SaldoMinimoMes = EC.SaldoMinimo,
            @CantidadATM = EC.CantidadOperacionesATM,
            @CantidadHumano = EC.CantidadOperacionesHumano,
            @SaldoMinimoPermitido = TC.SaldoMinimo,
            @MultaSaldoMin = TC.MultaSaldoMin,
            @CargoMensual = TC.CargoMensual,
            @NumRetiroHumano = TC.NumRetiroHumano,
            @NumRetiroAutomatico = TC.NumRetiroAutomatico,
            @ComisionHumano = TC.ComisionHumano,
            @ComisionAutomatico = TC.ComisionAutomatico,
            @TasaInteresAnual = TC.TasaInteresAnual
        FROM dbo.EstadoCuenta AS EC
        INNER JOIN dbo.Cuenta AS C
            ON C.Id = EC.IdCuenta
        INNER JOIN dbo.TipoCuentaAhorros AS TC
            ON TC.Id = C.IdTipoCuenta
        WHERE EC.Id = @inIdEstadoCuenta;

        IF @IdCuenta IS NULL
            THROW 50003, 'Estado de cuenta no encontrado.', 1;


        ------------------------------------------------------------
        -- 2. INTERESES SOBRE EL SALDO MINIMO DEL MES
        -- La tasa es anual y en porcentaje, se aplica la de un mes
        ------------------------------------------------------------

        SET @Monto = ROUND(@SaldoMinimoMes * @TasaInteresAnual / 100 / 12, 2);

        IF @Monto > 0
            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 12,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Intereses del mes';


        ------------------------------------------------------------
        -- 3. COMISION POR EXCESO DE OPERACIONES EN CAJERO AUTOMATICO
        ------------------------------------------------------------

        IF @CantidadATM > @NumRetiroAutomatico
        BEGIN
            SET @Monto = (@CantidadATM - @NumRetiroAutomatico) * @ComisionAutomatico;

            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 7,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Comision por exceso de operaciones en cajero automatico';
        END;


        ------------------------------------------------------------
        -- 4. COMISION POR EXCESO DE OPERACIONES EN CAJERO HUMANO
        ------------------------------------------------------------

        IF @CantidadHumano > @NumRetiroHumano
        BEGIN
            SET @Monto = (@CantidadHumano - @NumRetiroHumano) * @ComisionHumano;

            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 6,
                @inFecha = @FechaCierre,
                @inMonto = @Monto,
                @inDescripcion = 'Comision por exceso de operaciones en ventana';
        END;


        ------------------------------------------------------------
        -- 5. MULTA POR SALDO MINIMO
        -- Si en algun momento del mes el saldo bajo del minimo
        -- permitido por el tipo de cuenta
        ------------------------------------------------------------

        IF @SaldoMinimoMes < @SaldoMinimoPermitido
            EXEC dbo.AplicarMovimiento
                @inIdCuenta = @IdCuenta,
                @inIdTipoMovimiento = 16,
                @inFecha = @FechaCierre,
                @inMonto = @MultaSaldoMin,
                @inDescripcion = 'Multa por saldo minimo';


        ------------------------------------------------------------
        -- 6. CARGO POR SERVICIO MENSUAL
        ------------------------------------------------------------

        EXEC dbo.AplicarMovimiento
            @inIdCuenta = @IdCuenta,
            @inIdTipoMovimiento = 11,
            @inFecha = @FechaCierre,
            @inMonto = @CargoMensual,
            @inDescripcion = 'Cargo por servicio mensual';


        ------------------------------------------------------------
        -- 7. ABRIR EL ESTADO DE CUENTA DEL SIGUIENTE PERIODO
        ------------------------------------------------------------

        EXEC dbo.AbrirEstadoCuenta
            @inIdCuenta = @IdCuenta,
            @inFechaCierre = @FechaCierre;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[DeleteBeneficiario]
    @inId INT,
    @inUsuario VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT 1 FROM Beneficiario WHERE Id=@inId)
        THROW 50001, 'Beneficiario invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Beneficiario WHERE Id = @inId AND flagActivo = 1)
        THROW 50002, 'El beneficiario ya esta inactivo.', 1;
        
    UPDATE Beneficiario
    SET flagActivo = 0, FechaDesactivacion = SYSDATETIME()
    WHERE Id = @inId
    
    SELECT 0 AS Codigo
END


select * from Beneficiario where flagActivo=0

update Beneficiario
SET flagActivo=1
where Id = 47

CREATE OR ALTER PROCEDURE dbo.DeleteBeneficiario
    @inUser VARCHAR(32),
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

        SELECT
            @IdUsuario = Id,
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
           (
               SELECT 1
               FROM dbo.UsuarioVer
               WHERE IdUsuario = @IdUsuario
                 AND IdCuenta = @IdCuenta
           )
        BEGIN
            ROLLBACK;
            SELECT 0 AS Resultado,
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
            SELECT 0 AS Resultado,
                   'Beneficiario activo no encontrado.' AS Mensaje;
            RETURN;
        END;

        UPDATE dbo.Beneficiario
        SET
            flagActivo = 0,
            FechaDesactivacion = SYSDATETIME()
        WHERE Id = @inIdBeneficiario;

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            5,
            NULL,
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje,
                    1 AS flagActivo
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    @inIdBeneficiario AS IdBeneficiario,
                    @PorcentajeAnterior AS Porcentaje,
                    0 AS flagActivo
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            SYSDATETIME()
        );

        SELECT @SumaPorcentajes = ISNULL(SUM(Porcentaje), 0)
        FROM dbo.Beneficiario
        WHERE IdCuenta = @IdCuenta
          AND flagActivo = 1;

        COMMIT;

        SELECT
            1 AS Resultado,
            'Beneficiario eliminado correctamente.' AS Mensaje,
            @SumaPorcentajes AS SumaPorcentajes,
            CASE
                WHEN @SumaPorcentajes = 100 THEN 1
                ELSE 0
            END AS PorcentajesCompletos;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE dbo.GetAccountBeneficiaries
    @inCuenta VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        B.Id AS Id,
        P.Nombre AS Nombre,
        TD.Nombre AS DocuID,
        P.TipoDocuIdentidad AS TipoDocuIdentidad,
        TD.Nombre AS NombreDocuIdentidad,
        B.IdParentezco AS IdParentezco,
        PT.Nombre AS NombreParentezco,
        B.Porcentaje AS Porcentaje,
        P.Email AS Email,
        P.FechaNacimiento AS FechaNacimiento,
        P.ValorDocumentoIdentidad AS IdBeneficiario,
        P.Telefono AS Telefono,
        P.Telefono2 AS Telefono2
        
    FROM Cuenta AS C
        INNER JOIN dbo.Beneficiario B ON C.Id = B.IdCuenta
        INNER JOIN dbo.Persona P on P.Id = B.IdBeneficiario
        INNER JOIN dbo.TipoDocuIdentidad TD ON TD.Id = P.TipoDocuIdentidad
        INNER JOIN dbo.Parentezco PT on PT.Id = B.IdParentezco

        INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
        INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
    WHERE C.NumeroCuenta = @inCuenta
        AND B.flagActivo = 1
END

exec GetAccountBeneficiaries @inCuenta = '11000010'

SELECT C.NumeroCuenta,
       P.Email,
       PT.Nombre,
       B.Porcentaje
FROM Cuenta AS C
         INNER JOIN dbo.Beneficiario B ON C.Id = B.IdCuenta
         INNER JOIN dbo.Persona P on P.Id = B.IdBeneficiario
         INNER JOIN dbo.Parentezco PT on PT.Id = B.IdParentezco

         INNER JOIN TipoCuentaAhorros AS TC ON TC.Id = C.IdTipoCuenta
         INNER JOIN TipoMoneda AS TM ON TM.Id = C.IdTipoCuenta
WHERE C.NumeroCuenta = '11000010' AND B.flagActivo=1

select * from Beneficiario as B
    Inner Join Cuenta as C On C.Id = B.IdCuenta
Where C.NumeroCuenta = '11000010'

select * from Cuenta

select * from Beneficiario

select * from usuario

select * from TipoOperacion

GO

CREATE OR ALTER PROCEDURE [dbo].[GetAccountStatements]
    @inUser VARCHAR(32),
    @inNumeroCuenta VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        DECLARE @IdUsuario INT;
        DECLARE @IdCuenta INT;
        DECLARE @EsAdministrador BIT;

        ------------------------------------------------------------
        -- 1. OBTENER USUARIO
        ------------------------------------------------------------

        SELECT
            @IdUsuario = U.Id,
            @EsAdministrador = U.flagEsAdministrador
        FROM dbo.Usuario AS U
        WHERE U.[User] = @inUser;


        IF @IdUsuario IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Usuario no encontrado.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 2. OBTENER CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = C.Id
        FROM dbo.Cuenta AS C
        WHERE C.NumeroCuenta = @inNumeroCuenta;


        IF @IdCuenta IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Cuenta no encontrada.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 3. VALIDAR PERMISO
        ------------------------------------------------------------

        IF ISNULL(@EsAdministrador, 0) = 0
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UsuarioVer AS UV
                WHERE UV.IdUsuario = @IdUsuario
                  AND UV.IdCuenta = @IdCuenta
            )
            BEGIN
                SELECT
                    0 AS Resultado,
                    'El usuario no tiene acceso a esta cuenta.' AS Mensaje;

                RETURN;
            END;
        END;


        ------------------------------------------------------------
        -- 4. REGISTRAR CONSULTA EN BITACORA
        -- TipoOperacion 7 = Consultar estado de cuenta
        ------------------------------------------------------------

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            7,
            NULL,
            NULL,
            NULL,
            SYSDATETIME()
        );


        ------------------------------------------------------------
        -- 5. DEVOLVER LOS ESTADOS DE CUENTA
        -- Del mas reciente al mas antiguo
        ------------------------------------------------------------

        SELECT
            EC.Id,
            C.NumeroCuenta,
            EC.FechaInicio,
            EC.FechaFin,
            EC.SaldoInicial,
            EC.SaldoFinal,
            EC.SaldoMinimo,
            EC.CantidadOperacionesATM,
            EC.CantidadOperacionesHumano,
            EC.CantidadOperacionesSinpe
        FROM dbo.EstadoCuenta AS EC

        INNER JOIN dbo.Cuenta AS C
            ON C.Id = EC.IdCuenta

        WHERE EC.IdCuenta = @IdCuenta

        ORDER BY
            EC.FechaFin DESC,
            EC.Id DESC;

    END TRY

    BEGIN CATCH

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[GetMovimientosEstadoCuenta]
    @inUser VARCHAR(32),
    @inIdEstadoCuenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        DECLARE @IdUsuario INT;
        DECLARE @EsAdministrador BIT;
        DECLARE @IdCuenta INT;
        DECLARE @FechaInicio DATE;
        DECLARE @FechaFin DATE;

        ------------------------------------------------------------
        -- 1. OBTENER USUARIO
        ------------------------------------------------------------

        SELECT
            @IdUsuario = U.Id,
            @EsAdministrador = U.flagEsAdministrador
        FROM dbo.Usuario AS U
        WHERE U.[User] = @inUser;


        IF @IdUsuario IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Usuario no encontrado.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 2. OBTENER ESTADO DE CUENTA
        ------------------------------------------------------------

        SELECT
            @IdCuenta = EC.IdCuenta,
            @FechaInicio = EC.FechaInicio,
            @FechaFin = EC.FechaFin
        FROM dbo.EstadoCuenta AS EC
        WHERE EC.Id = @inIdEstadoCuenta;


        IF @IdCuenta IS NULL
        BEGIN
            SELECT
                0 AS Resultado,
                'Estado de cuenta no encontrado.' AS Mensaje;

            RETURN;
        END;


        ------------------------------------------------------------
        -- 3. VALIDAR PERMISO
        ------------------------------------------------------------

        IF ISNULL(@EsAdministrador, 0) = 0
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UsuarioVer AS UV
                WHERE UV.IdUsuario = @IdUsuario
                  AND UV.IdCuenta = @IdCuenta
            )
            BEGIN
                SELECT
                    0 AS Resultado,
                    'El usuario no tiene acceso a esta cuenta.' AS Mensaje;

                RETURN;
            END;
        END;


        ------------------------------------------------------------
        -- 4. REGISTRAR CONSULTA EN BITACORA
        -- TipoOperacion 8 = Consultar movimientos de estado de cuenta
        ------------------------------------------------------------

        INSERT INTO dbo.Bitacora
        (
            IdUsuario,
            IdTipoOperacion,
            IP,
            DatosAntes,
            DatosDespues,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            8,
            NULL,
            NULL,
            NULL,
            SYSDATETIME()
        );


        ------------------------------------------------------------
        -- 5. DEVOLVER LOS MOVIMIENTOS DEL PERIODO
        -- En orden cronologico, en la moneda de la cuenta
        ------------------------------------------------------------

        SELECT
            M.Id,
            M.Fecha,
            TMV.Nombre AS TipoMovimiento,
            TMV.flagEsCredito,
            M.Monto,
            TM.Simbolo,
            M.Descripcion,
            M.NuevoSaldo
        FROM dbo.Movimiento AS M

        INNER JOIN dbo.TipoMovimiento AS TMV
            ON TMV.Id = M.IdTipoMovimiento

        INNER JOIN dbo.Cuenta AS C
            ON C.Id = M.IdCuenta

        INNER JOIN dbo.TipoCuentaAhorros AS TC
            ON TC.Id = C.IdTipoCuenta

        INNER JOIN dbo.TipoMoneda AS TM
            ON TM.Id = TC.IdTipoMoneda

        WHERE M.IdCuenta = @IdCuenta
          AND M.Fecha BETWEEN @FechaInicio AND @FechaFin

        ORDER BY
            M.Fecha ASC,
            M.Id ASC;

    END TRY

    BEGIN CATCH

        SELECT
            0 AS Resultado,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[GetParentescos] 
AS
BEGIN
    SET NOCOUNT ON
    SELECT Id, Nombre FROM Parentezco
END

-- EXEC GetParentescos

GO

CREATE OR ALTER PROCEDURE dbo.GetPorcentajeBeneficiarios
    @inCuenta VARCHAR(64)
AS
BEGIN
    SELECT SUM(Porcentaje) AS Total 
    FROM Beneficiario as B
    INNER JOIN Cuenta AS C ON C.Id = B.IdCuenta 
    WHERE C.NumeroCuenta = @inCuenta AND B.flagActivo = 1
END


SELECT Porcentaje FROM Beneficiario as B
WHERE IdCuenta = 3

-- EXEC GetPorcentajeBeneficiarios @inCuenta = '11000010'

GO

CREATE OR ALTER PROCEDURE [dbo].[GetTipoDocId] 
AS
BEGIN
    SET NOCOUNT ON
    SELECT Id, Nombre FROM TipoDocuIdentidad
END

-- EXEC GetTipoDocId

GO

CREATE OR ALTER PROCEDURE dbo.GetUserAccounts
    @inUser VARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdUsuario INT;
    DECLARE @EsAdministrador BIT;

    SELECT
        @IdUsuario = Id,
        @EsAdministrador = flagEsAdministrador
    FROM dbo.Usuario
    WHERE [User] = @inUser;

    IF @IdUsuario IS NULL
    BEGIN
        SELECT 0 AS Resultado,
               'Usuario no encontrado.' AS Mensaje;
        RETURN;
    END;

    SELECT
        C.Id,
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
    WHERE
        @EsAdministrador = 1
        OR EXISTS
        (
            SELECT 1
            FROM dbo.UsuarioVer UV
            WHERE UV.IdUsuario = @IdUsuario
              AND UV.IdCuenta = C.Id
        )
    ORDER BY C.NumeroCuenta;
END;

GO

CREATE OR ALTER PROCEDURE dbo.Login
    @inUser VARCHAR(32),
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
        SELECT 0 AS Resultado,
               'Usuario o contraseña incorrectos.' AS Mensaje;
        RETURN;
    END;

    INSERT INTO dbo.Bitacora
    (
        IdUsuario, IdTipoOperacion, IP,
        DatosAntes, DatosDespues, FechaHora
    )
    VALUES
    (
        @IdUsuario, 1, @inIP,
        NULL, NULL, SYSDATETIME()
    );

    SELECT
        1 AS Resultado,
        'Login correcto.' AS Mensaje,
        U.Id,
        U.[User],
        U.flagEsAdministrador
    FROM dbo.Usuario U
    WHERE U.Id = @IdUsuario;
END;

GO

-- =============================================
-- Procedimiento: ProcesarCierresEstadoCuenta
-- Descripcion: Cierra todos los estados de cuenta
-- cuya fecha final es la fecha que se esta
-- procesando. Cada cierre se hace por separado
-- en su propia transaccion (CerrarEstadoCuenta).
-- Un estado que ya fue cerrado (ya tiene el estado
-- del siguiente periodo) no se vuelve a cerrar, asi
-- el proceso puede correrse de nuevo sin duplicar.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[ProcesarCierresEstadoCuenta]
    @inFecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Cierres TABLE
    (
        Secuencia      INT IDENTITY(1, 1),
        IdEstadoCuenta INT
    );

    DECLARE @Actual INT;
    DECLARE @Total INT;
    DECLARE @IdEstadoCuenta INT;

    INSERT INTO @Cierres (IdEstadoCuenta)
    SELECT EC.Id
    FROM dbo.EstadoCuenta AS EC
    WHERE EC.FechaFin = @inFecha
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.EstadoCuenta AS SIG
          WHERE SIG.IdCuenta = EC.IdCuenta
            AND SIG.FechaInicio = DATEADD(DAY, 1, @inFecha)
      )
    ORDER BY EC.Id;

    SELECT @Total = COUNT(*)
    FROM @Cierres;

    SET @Actual = 1;

    WHILE @Actual <= @Total
    BEGIN
        SELECT @IdEstadoCuenta = C.IdEstadoCuenta
        FROM @Cierres AS C
        WHERE C.Secuencia = @Actual;

        EXEC dbo.CerrarEstadoCuenta
            @inIdEstadoCuenta = @IdEstadoCuenta;

        SET @Actual = @Actual + 1;
    END;

    RETURN 0;
END;

GO

CREATE OR ALTER PROCEDURE [dbo].[UpdateBeneficiario]
    @inId INT,
    @inPorcentaje INT,
    @inNombre VARCHAR(64),
    @inParentesco INT,
    @inUsuario VARCHAR(32),
    @inIP VARCHAR(64) = null
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
        (
            IdUsuario, IdTipoOperacion, IP,
            DatosAntes, DatosDespues, FechaHora
        )
        VALUES
            (
                @IdUsuario, 4, @inIP,
                NULL, NULL, SYSDATETIME()
            );
        
        -- Actualizar Parentezco
        update Beneficiario
        SET IdParentezco = @inParentesco
        where Id = @inId

        -- Actualizar porcentaje
        update Beneficiario
        SET Porcentaje = @inPorcentaje
        where Id = @inId

        -- Actualizar Nombre de persona
        update P
        SET Nombre = @inNombre
        FROM Persona as P
        INNER JOIN Beneficiario AS B ON B.IdBeneficiario = P.Id
        where B.Id = @inId
            
        COMMIT
        SELECT 0 AS Codigo
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH 
END
    
-- EXEC dbo.UpdateBeneficiario @inId = 25, @inPorcentaje = 34, @inNombre = 'Lucia Soto Calderon', @inParentesco = 8

GO

CREATE OR ALTER PROCEDURE [dbo].[ProcesarCuenta]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Cuentas TABLE (
        IdCliente INT,
        idTipoCuenta INT,
        NumeroCuenta varchar(64),
        FechaCreacion DATE,
        Saldo MONEY
    )
    
    Insert into @Cuentas
    SELECT
        P.Id,
        F.f.value('@TipoCuentaId', 'INT') AS IdTipoCuenta,
        F.f.value('@NumeroCuenta', 'varchar(64)') AS NumeroCuenta,
        F.f.value('@FechaCreacion', 'Date') AS FechaCreacion,
        F.f.value('@Saldo', 'Money') as Saldo
        
    FROM @XmlDia.nodes('/FechaOperacion/Cuenta') AS F(f)
    inner join Persona as P on P.ValorDocumentoIdentidad = F.f.value('@ValorDocumentoIdentidadDelCliente', 'varchar(64)')
    
    insert into Cuenta(IdCliente, IdTipoCuenta, NumeroCuenta, FechaCreacion, Saldo) 
    select IdCliente, idTipoCuenta, NumeroCuenta, FechaCreacion, Saldo 
    from @Cuentas


    insert into Bitacora (IdUsuario, IdTipoOperacion, IP, DatosAntes, DatosDespues)
    select
        1 AS idUsuario,
        1 AS idTipoOperacion,
        '000.000.000' as IP,
        null as DatosAntes,
        (
            SELECT
                c.IdCliente,
                c.idTipoCuenta,
                c.NumeroCuenta,
                c.FechaCreacion,
                c.Saldo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as DatosDespues
    from @Cuentas C
    
    RETURN 0;
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ProcesarOperaciones]
    @XmlDatos XML
AS
BEGIN
    SET NOCOUNT ON;

    Declare @FechaInicial Date;
    Declare @FechaFinal Date;
    
    create table #Fechas(
        Fecha Date NOT NULL,
        XmlDia XML
    )
    
    insert into #Fechas (Fecha, XmlDia)
        SELECT 
            F.f.value('@Fecha', 'DATE') AS Fecha,
            F.f.query('.')              AS XmlDia
        FROM @XmlDatos.nodes('/Operaciones/FechaOperacion') AS F(f)
    
    select * from #Fechas
    
    select 
        @FechaInicial = MIN(Fecha),
        @FechaFinal = MAX(Fecha)
    from #Fechas
    
    Declare @FechaActual DATE
    SET @FechaActual = @FechaInicial

    SET @FechaFinal = DATEADD(DAY, 3, @FechaActual)
    
    -- create table #DatosProcesados (MyXml XML)
    
    While (@FechaActual<@FechaFinal)
    BEGIN
        DECLARE @XmlActual Xml;
        Select @XmlActual = XmlDia
        from #Fechas WHERE Fecha=@FechaActual;

        BEGIN TRY
            BEGIN TRANSACTION;
            -- Colocar acá llamadas a SPs que para cada tipo de operación
            -- Cada SP debería recibir el XmlActual y la FechaActual y extraer los nodos relevantes para su
            -- proposito basado en esto, no deberian crear transacciones ya que este SP se encarga de eso
                
            -- Exec ProcesarPersona @XmlDia=XmlActual, @Fecha = @FechaActual
        
            ----------DEBUG----------
            -- Insert Into #DatosProcesados(MyXml) Values(@MiXml);
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH
        
        Print @FechaActual
        Set @FechaActual = DATEADD(DAY, 1, @FechaActual) 
    END

    -- Select * From #DatosProcesados
    RETURN 0;
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ProcesarPersona]
    @XmlDia XML,
    @Fecha Date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Personas TABLE (
        TipoDocuIdentidad       INT,
        Nombre                  VARCHAR(64),
        ValorDocumentoIdentidad VARCHAR(64),
        FechaNacimiento         DATE,
        Email                   VARCHAR(64),
        Telefono                VARCHAR(32),
        Telefono2               VARCHAR(32)
    );
    
    insert into @Personas
    SELECT
        F.f.value('@TipoDocuIdentidad', 'INT') AS TipoDocuIdentidad,
        F.f.value('@Nombre', 'varchar(64)') AS Nombre,
        F.f.value('@ValorDocumentoIdentidad', 'varchar(64)') AS ValorDocumentoIdentidad,
        F.f.value('@FechaNacimiento', 'DATE') AS Nacimiento,
        F.f.value('@Email', 'VARCHAR(64)') AS email,
        F.f.value('@telefono1', 'VARCHAR(32)') AS telefono1,
        F.f.value('@telefono2', 'VARCHAR(32)') AS telefono2
        --F.f.query('.') AS XmlDia
    FROM @XmlDia.nodes('/FechaOperacion/Persona') AS F(f)

    INSERT INTO Persona (
        TipoDocuIdentidad, Nombre, ValorDocumentoIdentidad,
        FechaNacimiento, Email, Telefono, Telefono2
    )
    SELECT
        TipoDocuIdentidad, Nombre, ValorDocumentoIdentidad,
        FechaNacimiento, Email, Telefono, Telefono2
    FROM @Personas;
    
    insert into Bitacora (IdUsuario, IdTipoOperacion, IP, DatosAntes, DatosDespues) 
    select 
        1 AS idUsuario,
        1 AS idTipoOperacion,
        '000.000.000' as IP,
        null as DatosAntes,
        (
            SELECT
                p.TipoDocuIdentidad,
                p.Nombre,
                p.ValorDocumentoIdentidad,
                p.FechaNacimiento,
                p.Email,
                p.Telefono,
                p.Telefono2
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as DatosDespues
    from @Personas p
    
    select * from Bitacora
    
    RETURN 0;
END

GO
