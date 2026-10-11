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