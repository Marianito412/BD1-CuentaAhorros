CREATE TABLE [dbo].[Cuenta] (
    [Id]            INT          IDENTITY (1, 1) NOT NULL,
    [IdCliente]     VARCHAR (64) NULL,
    [NumeroCuenta]  VARCHAR (64) NULL,
    [FechaCreacion] DATE         NULL,
    [Saldo]         MONEY        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

