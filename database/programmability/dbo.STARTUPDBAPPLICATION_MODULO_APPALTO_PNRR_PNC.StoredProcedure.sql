USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_APPALTO_PNRR_PNC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_APPALTO_PNRR_PNC]
AS
BEGIN
  -----------------------------------------------------------------------------------
  --( in presenza del modulo simog attivo si attiverà in automatico anche il modulo PNRR_PNC )
  -----------------------------------------------------------------------------------
  --se sul cliente è attivo il modulo MODULO_APPALTO_PNRR_PNC allora rendo visibili i campi sui modelli delle gare
  -----------------------------------------------------------------------------------
  IF dbo.PARAMETRI('ATTIVA_MODULO', 'MODULO_APPALTO_PNRR_PNC', 'ATTIVA', 'YES', - 1) = 'YES'
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREFiltro'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREGriglia'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Appalto_PNRR'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREFiltro'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREGriglia'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Appalto_PNC'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Motivazione_Appalto_PNRR'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Motivazione_Appalto_PNC'
          AND Proprieta = 'Hide'
  END
  ELSE
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREFiltro'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREGriglia'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Appalto_PNRR'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREFiltro'
                       , 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDUREGriglia'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Appalto_PNC'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Motivazione_Appalto_PNRR'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'                       
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'Motivazione_Appalto_PNC'
          AND Proprieta = 'Hide'
  END
END
GO
