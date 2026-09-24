CREATE TABLE [dbo].[TipoMoneda] (
    [Id]      INT          IDENTITY (1, 1) NOT NULL,
    [Nombre]  VARCHAR (32) NULL,
    [Simbolo] VARCHAR (4)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

