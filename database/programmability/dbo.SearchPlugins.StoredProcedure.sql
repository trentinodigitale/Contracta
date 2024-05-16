USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SearchPlugins]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[SearchPlugins] (
                                   @IdMarketPlace INT,
				   @TipoPlugin    INT,
                                   @IdDcm         INT,
                                   @dcmIType      SMALLINT = NULL,
                                   @dcmIsubType   SMALLINT = NULL
                                   )
AS
BEGIN
      DECLARE @SQLString  VARCHAR(8000)
      DECLARE @SQLString1 VARCHAR(8000)
       
      IF @IdMarketPlace IS NULL
      BEGIN
           RAISERROR ('Parmatetro @IdMarketPlace non valorizzato', 16, 1)
           RETURN 99
      END 
      SET @SQLString = 'SELECT p.*,pd.pdStartPage,pd.pdActivation,pd.pdImageName,pd.pdIsAbsolute,d.dcmIType,d.dcmIsubType,pd.pdOrder,
			       pd.pdVisualAttrib,pd.pdURLParms	 
                          FROM Plugin p 
                         INNER JOIN PluginDetails pd ON p.IdPlg = pd.pdIdPlg 
                         INNER JOIN document d ON pd.pdIdDcm = d.IdDcm 
                         WHERE pd.pdType = ' + CAST(@TipoPlugin AS VARCHAR) + 
                       '   AND dcmdeleted = 0 
                           AND pdIdMp = ' + convert(varchar(10),@IdMarketPlace) 
      SET @SQLString1 = ' UNION
                         SELECT p.*,pd.pdStartPage,pd.pdActivation,pd.pdImageName,pd.pdIsAbsolute,d.dcmIType,d.dcmIsubType,pd.pdOrder,
			        pd.pdVisualAttrib,pd.pdURLParms
                           FROM Plugin p 
                          INNER JOIN PluginDetails pd ON p.IdPlg = pd.pdIdPlg 
                          INNER JOIN document d ON pd.pdIdDcm = d.IdDcm 
                          WHERE pd.pdType = ' + CAST(@TipoPlugin AS VARCHAR) + 
                        '   AND dcmdeleted = 0 
                            AND pdIdMp = 0'
      IF (@dcmIType IS NULL AND @dcmIsubType IS NULL) 
      BEGIN
            IF (@IdDcm IS NULL)
            BEGIN
                 RAISERROR ('Parametro @IdDcm non valorizzato', 16, 1)
                 RETURN 99      
            END 
            SET @SQLString  = @SQLString  + ' AND pdIdDcm  = '+ CAST (@IdDcm AS VARCHAR)
            SET @SQLString1 = @SQLString1 + ' AND pdIdDcm  = '+ CAST (@IdDcm AS VARCHAR)
                    
      END 
      ELSE 
      BEGIN 
           IF (@dcmIType IS NULL OR @dcmIsubType IS NULL)
           BEGIN
                RAISERROR ('Parametri @dcmIType e @dcmIsubType non valorizzati', 16, 1)
                RETURN 99      
           END 
           SET @SQLString  = @SQLString  + ' AND d.dcmIType = '    + CAST(@dcmIType AS VARCHAR) + 
                                           ' AND d.dcmIsubType = ' + CAST(@dcmIsubType AS VARCHAR)
           SET @SQLString1 = @SQLString1 + ' AND d.dcmIType = '    + CAST(@dcmIType AS VARCHAR) + 
                                           ' AND d.dcmIsubType = ' + CAST(@dcmIsubType AS VARCHAR)
      END
      
      SET @SQLString = @SQLString + @SQLString1 + ' ORDER BY pd.pdOrder ASC'  
      EXECUTE (@SQLString)
       
END
GO
