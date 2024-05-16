USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpga_Aggiorna_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--drop procedure mpga_Aggiorna_I
CREATE PROCEDURE [dbo].[mpga_Aggiorna_I] (@lastDate DATETIME = NULL OUTPUT) 
as
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod 
   FROM srv_UltimaMod 
  WHERE umdNome = 'MPGerarchiaAttributi'
 IF (@ConfDate IS NULL) /* Non accade */
     begin
           SELECT @lastDate = GETDATE()
           
           SELECT IdTab,
                  tabIdMp,
                  tabContesto,
                  tabDescr,
                  tabValue,
                  tabPath,
                  tabLivello,
                  tabFoglia,
                  tabLenPathPadre,
                  tabDeleted AS flagDeleted,
                  tabUltimaMod,
                  tabProfili,
                  tabMultiSel
             FROM MPGerarchiaAttributi_I
           ORDER BY IdTab
    end 
ELSE 
    begin
          IF (@lastDate IS NULL)
               SELECT IdTab,
                      tabIdMp,
                      tabContesto,
                      tabDescr,
                      tabValue,
                      tabPath,
                      tabLivello,
                      tabFoglia,
                      tabLenPathPadre,
                      tabDeleted AS flagDeleted,
                      tabUltimaMod,
                      tabProfili,
                      tabMultiSel
                 FROM MPGerarchiaAttributi_I
               ORDER BY IdTab
          ELSE
          IF (@lastDate < @ConfDate)
               SELECT IdTab,
                      tabIdMp,
                      tabContesto,
                      tabDescr,
                      tabValue,
                      tabPath,
                      tabLivello,
                      tabFoglia,
                      tabLenPathPadre,
                      tabDeleted AS flagDeleted,
                      tabUltimaMod,
                      tabProfili,
                      tabMultiSel
                 FROM MPGerarchiaAttributi_I
                WHERE tabUltimaMod > @lastDate
               ORDER BY IdTab
         SELECT @lastDate = @ConfDate
 end
GO
