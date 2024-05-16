USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_STRUTTURA_ENTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_STRUTTURA_ENTI]
AS
BEGIN
  --SE NON ATTIVO IL MODULO "MODULO_STRUTTURA_ENTI" NASCONDO IL CAMPO "Struttura di Appartenenza" SULLA
  --MASCHERA DEL CAMBIO_RUOLO, MASCHERA DOCUMENTO USER_DOC
  --SUL BANDO GARA e BANDO SEMPLIFICATO RENDO VISIBILI I CAMPI "DIREZIONE PROPONENTE" E "DIREZIONE ESPLETANTE"
  IF NOT EXISTS (
      SELECT items
      FROM dbo.Split((SELECT DZT_ValueDef
                      FROM lib_dictionary WITH (NOLOCK)
                      WHERE DZT_Name = 'SYS_MODULI_GRUPPI'), ',')
      WHERE items = 'MODULO_STRUTTURA_ENTI')
  BEGIN
    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'CAMBIO_RUOLO_UTENTE_PLANT'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'USER_DOC_UTENTI'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto IN ('BANDO_GARA_TESTATA', 'TEMPLATE_GARA_TESTATA')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto IN ('BANDO_GARA_TESTATA_AVVISO', 'TEMPLATE_GARA_TESTATA_AVVISO')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto IN ('BANDO_GARA_TESTATA_GAREINFORMALI', 'TEMPLATE_GARA_TESTATA_GAREINFORMALI')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'BANDO_SEMPLIFICATO_TESTATA2'
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'CONVENZIONE_PLANT'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'QUOTA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'RICHIESTAQUOTA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'RICHIESTAQUOTAINTERNA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '1'
    WHERE contesto = 'ODC_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'
  END
  ELSE
  BEGIN
    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'CAMBIO_RUOLO_UTENTE_PLANT'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'USER_DOC_UTENTI'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto IN ('BANDO_GARA_TESTATA', 'TEMPLATE_GARA_TESTATA')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto IN ('BANDO_GARA_TESTATA_AVVISO', 'TEMPLATE_GARA_TESTATA_AVVISO')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto IN ('BANDO_GARA_TESTATA_GAREINFORMALI', 'TEMPLATE_GARA_TESTATA_GAREINFORMALI')
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'BANDO_SEMPLIFICATO_TESTATA2'
          AND Oggetto = 'DirezioneEspletante'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'CONVENZIONE_PLANT'
          AND Oggetto = 'Plant'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'QUOTA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'RICHIESTAQUOTA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'RICHIESTAQUOTAINTERNA_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'

    UPDATE ctl_parametri
    SET Valore = '0'
    WHERE contesto = 'ODC_TESTATA'
          AND Oggetto = 'StrutturaAziendale'
          AND Proprieta = 'Hide'
  END
END
GO
