CREATE TABLE [dbo].[TipoCuentaAhorros] (
    [Id]                  INT   IDENTITY (1, 1) NOT NULL,
    [Nombre]              INT   NULL,
    [IdTipoMoneda]        INT   NULL,
    [SaldoMinimo]         MONEY NULL,
    [MultaSaldoMin]       MONEY NULL,
    [CargoAnual]          MONEY NULL,
    [NumRetiroHumano]     INT   NULL,
    [NumRetiroAutomatico] INT   NULL,
    [ComisionHumano]      MONEY NULL,
    [ComisionAutomatico]  MONEY NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

