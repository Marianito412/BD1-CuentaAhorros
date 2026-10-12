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
