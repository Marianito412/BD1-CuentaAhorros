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
        SET
            TM.Nombre = X.Nombre,
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
        SET
            TCA.Nombre = X.Nombre,
            TCA.IdTipoMoneda = X.IdTipoMoneda,
            TCA.SaldoMinimo = X.SaldoMinimo,
            TCA.MultaSaldoMin = X.MultaSaldoMin,
            TCA.CargoAnual = X.CargoAnual,
            TCA.NumRetiroHumano = X.NumRetiroHumano,
            TCA.NumRetiroAutomatico = X.NumRetiroAutomatico,
            TCA.ComisionHumano = X.ComisionHumano,
            TCA.ComisionAutomatico = X.ComisionAutomatico,
            TCA.Interes = X.Interes
        FROM dbo.TipoCuentaAhorros AS TCA
        INNER JOIN
        (
            SELECT
                N.value('@Id', 'INT') AS Id,
                N.value('@Nombre', 'VARCHAR(64)') AS Nombre,
                N.value('@IdTipoMoneda', 'INT') AS IdTipoMoneda,
                N.value('@SaldoMinimo', 'MONEY') AS SaldoMinimo,
                N.value('@MultaSaldoMin', 'MONEY') AS MultaSaldoMin,
                N.value('@CargoAnual', 'MONEY') AS CargoAnual,
                N.value('@NumRetirosHumano', 'INT') AS NumRetiroHumano,
                N.value('@NumRetirosAutomatico', 'INT') AS NumRetiroAutomatico,
                N.value('@comisionHumano', 'MONEY') AS ComisionHumano,
                N.value('@comisionAutomatico', 'MONEY') AS ComisionAutomatico,
                N.value('@interes', 'DECIMAL(10,4)') AS Interes
            FROM @XmlDatos.nodes(
                '/Catalogos/Tipo_Cuenta_Ahorros/TipoCuentaAhorro'
            ) AS T(N)
        ) AS X
            ON TCA.Id = X.Id;

        INSERT INTO dbo.TipoCuentaAhorros
        (
            Id,
            Nombre,
            IdTipoMoneda,
            SaldoMinimo,
            MultaSaldoMin,
            CargoAnual,
            NumRetiroHumano,
            NumRetiroAutomatico,
            ComisionHumano,
            ComisionAutomatico,
            Interes
        )
        SELECT
            N.value('@Id', 'INT'),
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
        (
            SELECT 1
            FROM dbo.TipoCuentaAhorros AS TCA
            WHERE TCA.Id = N.value('@Id', 'INT')
        );


        ------------------------------------------------------------
        -- 5. TIPOS DE OPERACION DE BITACORA
        ------------------------------------------------------------

        UPDATE TOB
        SET TOB.Nombre = X.Nombre
        FROM dbo.TipoOperacion AS TOB
        INNER JOIN
        (
            SELECT
                N.value('@id', 'INT') AS Id,
                N.value('@nombre', 'VARCHAR(64)') AS Nombre
            FROM @XmlDatos.nodes(
                '/Catalogos/TipoOperacionesBitacora/TipoOperacion'
            ) AS T(N)
        ) AS X
            ON TOB.Id = X.Id;

        INSERT INTO dbo.TipoOperacion
        (
            Id,
            Nombre
        )
        SELECT
            N.value('@id', 'INT'),
            N.value('@nombre', 'VARCHAR(64)')
        FROM @XmlDatos.nodes(
            '/Catalogos/TipoOperacionesBitacora/TipoOperacion'
        ) AS T(N)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TipoOperacion AS TOB
            WHERE TOB.Id = N.value('@id', 'INT')
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