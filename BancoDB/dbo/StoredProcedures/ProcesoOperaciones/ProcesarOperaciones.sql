CREATE OR ALTER PROCEDURE [dbo].[ProcesarOperaciones]
    @XmlDatos XML
AS
BEGIN
    SET NOCOUNT ON;

    Declare @FechaInicial Date;
    Declare @FechaFinal Date;
    
    create table #Fechas(
        Fecha Date NOT NULL,
        XmlDia XML
    )
    
    insert into #Fechas (Fecha, XmlDia)
        SELECT 
            F.f.value('@Fecha', 'DATE') AS Fecha,
            F.f.query('.')              AS XmlDia
        FROM @XmlDatos.nodes('/Operaciones/FechaOperacion') AS F(f)
    
    select * from #Fechas
    
    select 
        @FechaInicial = MIN(Fecha),
        @FechaFinal = MAX(Fecha)
    from #Fechas
    
    Declare @FechaActual DATE
    SET @FechaActual = @FechaInicial

    SET @FechaFinal = DATEADD(DAY, 3, @FechaActual)
    
    -- create table #DatosProcesados (MyXml XML)
    
    While (@FechaActual<@FechaFinal)
    BEGIN
        DECLARE @XmlActual Xml;
        Select @XmlActual = XmlDia
        from #Fechas WHERE Fecha=@FechaActual;

        BEGIN TRY
            BEGIN TRANSACTION;
            -- Colocar acá llamadas a SPs que para cada tipo de operación
            -- Cada SP debería recibir el XmlActual y la FechaActual y extraer los nodos relevantes para su
            -- proposito basado en esto, no deberian crear transacciones ya que este SP se encarga de eso
                
            -- Exec ProcesarPersona @XmlDia=XmlActual, @Fecha = @FechaActual
        
            ----------DEBUG----------
            -- Insert Into #DatosProcesados(MyXml) Values(@MiXml);
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH
        
        Print @FechaActual
        Set @FechaActual = DATEADD(DAY, 1, @FechaActual) 
    END

    -- Select * From #DatosProcesados
    RETURN 0;
END
GO

DECLARE @xml XML;

SELECT @xml = CONVERT(XML, BulkColumn, 2)
FROM OPENROWSET(
             BULK 'E:\TEC\2026 SEMESTRE 2\Bases de Datos 1\Proyectos\Tarea2\OperacionesTarea3.xml',
             SINGLE_BLOB
     ) AS x;

EXEC dbo.ProcesarOperaciones @XmlDatos = @xml;