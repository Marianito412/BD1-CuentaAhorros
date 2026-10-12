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
        -- 4. ESTADOS DE CUENTA
        ------------------------------------------------------------
        INSERT INTO dbo.EstadoCuenta
        (
            IdCuenta,
            FechaInicio,
            FechaFin,
            SaldoInicial,
            SaldoFinal,
            SaldoMinimo,
            InteresesAcumulados,
            CantidadRetiros,
            CantidadDepositos,
            CantidadSinpeEntrantes,
            CantidadSinpeSalientes
        )
        SELECT
            C.Id,
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
        (
            SELECT 1
            FROM dbo.EstadoCuenta EC
            WHERE EC.IdCuenta = C.Id
              AND EC.FechaInicio = X.N.value('@fechaInicio', 'DATE')
              AND EC.FechaFin = X.N.value('@fechafin', 'DATE')
        );

        ------------------------------------------------------------
        -- 5. USUARIOS
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
        -- 6. USUARIO VER CUENTAS
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