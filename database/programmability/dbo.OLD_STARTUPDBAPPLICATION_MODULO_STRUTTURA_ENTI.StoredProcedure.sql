USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_MODULO_STRUTTURA_ENTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_MODULO_STRUTTURA_ENTI]
AS
BEGIN
	
	--SE NON ATTIVO IL MODULO "MODULO_STRUTTURA_ENTI" NASCONDO IL CAMPO "Struttura di Appartenenza" SULLA
	--MASCHERA DEL CAMBIO_RUOLO, MASCHERA DOCUMENTO USER_DOC
	--SUL BANDO GARA e BANDO SEMPLIFICATO RENDO VISIBILI I CAMPI "DIREZIONE PROPONENTE" E "DIREZIONE ESPLETANTE"
	IF NOT EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'MODULO_STRUTTURA_ENTI' 
			)
	BEGIN
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CAMBIO_RUOLO_UTENTE_PLANT' and Oggetto='Plant' and Proprieta='Hide' 
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='USER_DOC_UTENTI' and Oggetto='Plant' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_GARA_TESTATA' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_GARA_TESTATA_AVVISO' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_SEMPLIFICATO_TESTATA2' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 

		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_GARA_TESTATA_GAREINFORMALI' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 
				
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONVENZIONE_PLANT' and Oggetto='Plant' and Proprieta='Hide' 
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='QUOTA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='RICHIESTAQUOTA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='RICHIESTAQUOTAINTERNA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='ODC_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide'

	END
	ELSE
	BEGIN
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CAMBIO_RUOLO_UTENTE_PLANT' and Oggetto='Plant' and Proprieta='Hide' 

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='USER_DOC_UTENTI' and Oggetto='Plant' and Proprieta='Hide'
	
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_GARA_TESTATA' and Oggetto='DirezioneEspletante' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_GARA_TESTATA_AVVISO' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_SEMPLIFICATO_TESTATA2' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 
		
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_GARA_TESTATA_GAREINFORMALI' and Oggetto='DirezioneEspletante' and Proprieta='Hide' 

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONVENZIONE_PLANT' and Oggetto='Plant' and Proprieta='Hide' 

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='QUOTA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide' 
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='RICHIESTAQUOTA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='RICHIESTAQUOTAINTERNA_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide'

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='ODC_TESTATA' and Oggetto='StrutturaAziendale' and Proprieta='Hide'

	END

END
GO
