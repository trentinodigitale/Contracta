USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_CONTROLLI_OE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_CONTROLLI_OE]
AS
BEGIN
	
	--SE NON E' ATTIVO IL MODULO PER IL CONTROLLO OE SETTO I CAMPI NON OBBLIGATORI e NASCOSTI
	--SUL MODELLO PARAMETRI_SDA_CONTROLLI PERCHE' LA SEZIONE E' NASCOSTA
	--SUL MODELLO BANDO_SDA_CAPTION_CONTROLLI NASCONDO (USATO SUL SINGOLO SDA) LA LABEL E AL LINEA HR1
	IF dbo.PARAMETRI('ATTIVA_MODULO','CONTROLLI_OE','ATTIVA','NO',-1) = 'NO'
	begin

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='Conferma_Gestore' and Proprieta='Obbligatory'
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='elenco_documenti_controlli_OE' and Proprieta='Obbligatory'

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='FreqControlli' and Proprieta='Obbligatory'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='Conferma_Gestore' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='elenco_documenti_controlli_OE' and Proprieta='Hide'

		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='FreqControlli' and Proprieta='Hide'			

		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_SDA_CAPTION_CONTROLLI' and Oggetto='Static' and Proprieta='Hide'			

		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='BANDO_SDA_CAPTION_CONTROLLI' and Oggetto='HR1' and Proprieta='Hide'

	end
	else
	begin

		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='Conferma_Gestore' and Proprieta='Obbligatory'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='elenco_documenti_controlli_OE' and Proprieta='Obbligatory'

		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='FreqControlli' and Proprieta='Obbligatory'	
	
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='Conferma_Gestore' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='elenco_documenti_controlli_OE' and Proprieta='Hide'

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='PARAMETRI_SDA_CONTROLLI' and Oggetto='FreqControlli' and Proprieta='Hide'			


		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_SDA_CAPTION_CONTROLLI' and Oggetto='Static' and Proprieta='Hide'			

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='BANDO_SDA_CAPTION_CONTROLLI' and Oggetto='HR1' and Proprieta='Hide'

	end

END
GO
