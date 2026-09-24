CREATE TABLE [dbo].[EstadoCuenta] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [NumeroCuenta] VARCHAR (50) NULL,
    [FechaInicio]  DATE         NULL,
    [FechaFin]     DATE         NULL,
    [SaldoInicial] MONEY        NULL,
    [SaldoFinal]   MONEY        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

