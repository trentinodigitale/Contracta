USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[StampaDettaglioOAP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[StampaDettaglioOAP]
  (@iIdoap INT,@iIdazi INT,@vcCodicePlant VARCHAR(20))
AS
 BEGIN 
      IF (      
            (@iIdoap IS NULL) or 
            (@iIdazi IS NULL) or 
            (@vcCodicePlant IS NULL)
         )
            BEGIN
                  RAISERROR ('Errore uno dei parametri _ NULLo',16,1)
                  RETURN 99            
            END 
      
      SELECT DataOaP,Protocol,AziRagioneSociale
        FROM OapTestata x, Aziende y
       WHERE x.IdAzi = y.Idazi AND aziDeleted = 0 AND 
           x.IdAzi = @iIdazi AND 
           x.idoap = @iIdoap AND 
           CodicePlant = @vcCodicePlant
      RETURN 0
 END 
GO
