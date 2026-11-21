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

    DECLARE @XmlActual Xml;
    
    While (@FechaActual <= @FechaFinal)
    BEGIN
        
        SET @XmlActual = (
            SELECT XmlDia AS [*]
            FROM #Fechas
            WHERE Fecha = @FechaActual
            FOR XML PATH(''), TYPE
        );

        SET @XmlActual = COALESCE(@XmlActual, CAST('<FechaOperacion/>' AS XML));
        
        BEGIN TRY
            BEGIN TRANSACTION;
            /*
                Colocar acá llamadas a SPs para cada tipo de operación
                Cada SP debería recibir el XmlActual y la FechaActual y extraer los nodos relevantes para su
                proposito basado en esto, no deberian crear transacciones ya que este SP se encarga de eso
            */
            EXEC ProcesarPersona @XmlDia=@XmlActual, @Fecha = @FechaActual
            EXEC ProcesarCuenta @XmlDia=@XmlActual, @Fecha = @FechaActual
            EXEC ProcesarBeneficiario @XmlDia=@XmlActual, @Fecha = @FechaActual
            EXEC ProcesarUsuario @XmlDia=@XmlActual, @Fecha = @FechaActual
            EXEC ProcesarUsuarioVer @XmlDia=@XmlActual, @Fecha = @FechaActual
            EXEC ProcesarMovimiento @XmlDia=@XmlActual, @Fecha = @FechaActual
            
            EXEC ProcesarCierresEstadoCuenta @inFecha = @FechaActual
            ----------DEBUG----------
            -- Insert Into #DatosProcesados(MyXml) Values(@MiXml);
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH
        
        Set @FechaActual = DATEADD(DAY, 1, @FechaActual) 
    END

    RETURN 0;
END
GO