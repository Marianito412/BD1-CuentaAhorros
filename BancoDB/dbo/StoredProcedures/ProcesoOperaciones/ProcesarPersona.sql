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
    
    /*
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
     */
    
    RETURN 0;
END
GO