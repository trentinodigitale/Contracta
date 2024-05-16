USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_TED]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_TED]
AS
BEGIN
  -----------------------------------------------------------------------------------
  -- SE NON E' ATTIVA L'INTEGRAZIONE CON IL TED NASCONDIAMO IL CAMPO RichiestaTED PRESENTE SUI MODELLI DELLE PROCEDURE
  -----------------------------------------------------------------------------------
  IF dbo.IsTedActive(0) = 0
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'
                       , 'TEMPLATE_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI'
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND Oggetto = 'RichiestaTED'
          AND Proprieta = 'HIDE'
  END
  ELSE
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA', 'TEMPLATE_GARA_TESTATA')
          AND Oggetto = 'RichiestaTED'
          AND Proprieta = 'HIDE'
  END
END
GO
