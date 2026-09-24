CREATE TABLE [dbo].[Persona] (
    [Id]                      INT          IDENTITY (1, 1) NOT NULL,
    [TipoDocuIdentidad]       INT          NULL,
    [ValorDocumentoIdentidad] VARCHAR (64) NULL,
    [FechaNacimiento]         DATE         NULL,
    [Email]                   VARCHAR (64) NULL,
    [Telefono]                VARCHAR (32) NULL,
    [Telefono2]               VARCHAR (32) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

