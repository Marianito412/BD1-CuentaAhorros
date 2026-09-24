CREATE TABLE [dbo].[Beneficiario] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [NumeroCuenta]   VARCHAR (50) NULL,
    [IdBeneficiario] VARCHAR (50) NULL,
    [ParentezcoId]   INT          NULL,
    [Porcentaje]     FLOAT (53)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

