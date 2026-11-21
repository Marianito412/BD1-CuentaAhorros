CREATE TABLE dbo.FechaProcesada (
    Fecha            DATE      NOT NULL PRIMARY KEY,
    FechaHoraProceso DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
