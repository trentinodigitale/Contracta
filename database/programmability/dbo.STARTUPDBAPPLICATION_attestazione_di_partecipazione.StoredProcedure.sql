USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_attestazione_di_partecipazione]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_attestazione_di_partecipazione]
AS
BEGIN
  -----------------------------------------------------------------------------------
  --SE IL PARAMETRO attestazione_di_partecipazione E' ATTIVO SUL CLIENTE LE PROPRIETA'
  --VENGONO MESSE PER RENDERE VISIBILI I CAMPI	
  --ALTRIMENTI METTE HIDE	
  -----------------------------------------------------------------------------------
  IF dbo.PARAMETRI('ATTIVA_MODULO', 'attestazione_di_partecipazione', 'ATTIVA', 'YES', - 1) = 'NO'
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'CONFIG_MODELLI_LOTTI_MODELLI'
          AND Oggetto = 'MOD_Cauzione'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'BANDO_SEMPLIFICATO_TESTATA2'
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'BANDO_SEMPLIFICATO_IN_APPROVE_TESTATA'
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA_AVVISO', 'TEMPLATE_GARA_TESTATA_AVVISO')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA_ACCORDOQUADRO', 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto IN ('BANDO_GARA_TESTATA', 'TEMPLATE_GARA_TESTATA')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    --UPDATE CTL_Parametri
    --SET Valore = '1'
    --WHERE Contesto IN ('TEMPLATE_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI', 'TEMPLATE_GARA_TESTATA_COTTIMO', 'TEMPLATE_GARA_TESTATA_GAREINFORMALI', 'TEMPLATE_GARA_TESTATA_RDO')
    --      AND Oggetto = 'ClausolaFideiussoria'
    --      AND Proprieta = 'Hide'
  END
  ELSE
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'CONFIG_MODELLI_LOTTI_MODELLI'
          AND Oggetto = 'MOD_Cauzione'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'BANDO_SEMPLIFICATO_TESTATA2'
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'BANDO_SEMPLIFICATO_IN_APPROVE_TESTATA'
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA_AVVISO', 'TEMPLATE_GARA_TESTATA_AVVISO')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA_ACCORDOQUADRO', 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto IN ('BANDO_GARA_TESTATA', 'TEMPLATE_GARA_TESTATA')
          AND Oggetto = 'ClausolaFideiussoria'
          AND Proprieta = 'Hide'

    --UPDATE CTL_Parametri
    --SET Valore = '0'
    --WHERE Contesto IN ('TEMPLATE_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI', 'TEMPLATE_GARA_TESTATA_COTTIMO', 'TEMPLATE_GARA_TESTATA_GAREINFORMALI', 'TEMPLATE_GARA_TESTATA_RDO')
    --      AND Oggetto = 'ClausolaFideiussoria'
    --      AND Proprieta = 'Hide'
  END
END
GO
