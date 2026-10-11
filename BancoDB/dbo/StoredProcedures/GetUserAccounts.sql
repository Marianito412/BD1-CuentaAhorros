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
