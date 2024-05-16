USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GROUP_SIMOG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GROUP_SIMOG]
AS
BEGIN
  IF EXISTS (
      SELECT items
      FROM dbo.Split((SELECT DZT_ValueDef
                      FROM lib_dictionary WITH (NOLOCK)
                      WHERE DZT_Name = 'SYS_MODULI_GRUPPI'), ',')
      WHERE items = 'GROUP_SIMOG')
	  or 
		dbo.attivoPCP ()=1
		
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'ODC_DOCUMENT'
          AND Oggetto = 'idpfuRup'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'ODC_DOCUMENT'
          AND Oggetto = 'RichiestaCigSimog'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '0'
    WHERE Contesto = 'PREGARA_TESTATA'
          AND Oggetto = 'RichiestaCigPreGara'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET valore = '0'
    WHERE contesto IN ('BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_GARA_TESTATA_GAREINFORMALI'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
          AND oggetto IN ('ID_MOTIVO_DEROGA'
                          , 'FLAG_MISURE_PREMIALI'
                          , 'ID_MISURA_PREMIALE'
                          , 'FLAG_PREVISIONE_QUOTA'
                          , 'QUOTA_FEMMINILE'
                          , 'QUOTA_GIOVANILE'
                         )
          AND Proprieta = 'HIDE'


		   IF EXISTS (SELECT items FROM dbo.Split((SELECT DZT_ValueDef FROM lib_dictionary WITH (NOLOCK) WHERE DZT_Name = 'SYS_MODULI_GRUPPI'), ',') WHERE items = 'SIMOG_DELEGAGARA')
				BEGIN
					if not exists (select * from ctl_parametri with(nolock) where contesto='RICHIESTA_CIG_GARA_DELEGA' and Oggetto='GestioneCiGconDelega' and Proprieta='HIDE')
						begin
							insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
								 values('RICHIESTA_CIG_GARA_DELEGA', 'GestioneCiGconDelega', 'HIDE', '0', '###0###1###', 'Serve per capire se è attivo o meno la richiesta cig con delega')
						end
					else
						begin 
							update ctl_parametri set Valore = '0' where contesto='RICHIESTA_CIG_GARA_DELEGA' and Oggetto='GestioneCiGconDelega' and Proprieta='HIDE'
						end	
				END
			else
				BEGIN
					if not exists (select * from ctl_parametri with(nolock) where contesto='RICHIESTA_CIG_GARA_DELEGA' and Oggetto='GestioneCiGconDelega' and Proprieta='HIDE')
						begin
							insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
								 values('RICHIESTA_CIG_GARA_DELEGA', 'GestioneCiGconDelega', 'HIDE', '1', '###0###1###', 'Serve per capire se è attivo o meno la richiesta cig con delega')
						end
					else
						begin 
							update ctl_parametri set Valore = '1' where contesto='RICHIESTA_CIG_GARA_DELEGA' and Oggetto='GestioneCiGconDelega' and Proprieta='HIDE'
						end	
				END

  END
  ELSE
  BEGIN
    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'ODC_DOCUMENT'
          AND Oggetto = 'idpfuRup'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'ODC_DOCUMENT'
          AND Oggetto = 'RichiestaCigSimog'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET Valore = '1'
    WHERE Contesto = 'PREGARA_TESTATA'
          AND Oggetto = 'RichiestaCigPreGara'
          AND Proprieta = 'Hide'

    UPDATE CTL_Parametri
    SET valore = '1'
    WHERE contesto IN ('BANDO_GARA_TESTATA_COTTIMO'
                       , 'BANDO_GARA_TESTATA_ACCORDOQUADRO'
                       , 'BANDO_GARA_TESTATA_RDO'
                       , 'BANDO_GARA_TESTATA'
                       , 'BANDO_GARA_TESTATA_AVVISO'
                       , 'BANDO_SEMPLIFICATO_TESTATA2'
                       , 'TEMPLATE_GARA_TESTATA'
                       , 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO'
                       , 'TEMPLATE_GARA_TESTATA_AVVISO'
                       , 'TEMPLATE_GARA_TESTATA_COTTIMO'
                       , 'TEMPLATE_GARA_TESTATA_GAREINFORMALI'
                       , 'TEMPLATE_GARA_TESTATA_RDO'
                      )
      AND oggetto IN ('ID_MOTIVO_DEROGA'
                      , 'FLAG_MISURE_PREMIALI'
                      , 'ID_MISURA_PREMIALE'
                      , 'FLAG_PREVISIONE_QUOTA'
                      , 'QUOTA_FEMMINILE'
                      , 'QUOTA_GIOVANILE'
                     )
      AND Proprieta = 'HIDE'
  END
END
GO
