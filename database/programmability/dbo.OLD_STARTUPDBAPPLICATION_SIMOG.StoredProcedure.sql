USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_SIMOG]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_SIMOG]
AS
BEGIN

	-----------------------------------------------------------------------------------
	--se è attiva l'integrazione simog deve essere attivo anche il parametro simog_get che consente il recuperato dati da simog quando su una procedura, la richiesta cig simog è "no"
	-----------------------------------------------------------------------------------
	IF EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_SIMOG' 
			)
			or
			dbo.attivoPCP()=1
	BEGIN

		update CTL_Parametri set valore='YES' where contesto='simog' and oggetto='SIMOG_GET' and Proprieta='ATTIVO'
		update CTL_Parametri set valore='YES' where contesto='ATTIVA_MODULO' and oggetto='MODULO_APPALTO_PNRR_PNC' and Proprieta='ATTIVA'

	END
	ELSE
	BEGIN

		update CTL_Parametri set valore='NO' where contesto='simog' and oggetto='SIMOG_GET' and Proprieta='ATTIVO'
		update CTL_Parametri set valore='NO' where contesto='ATTIVA_MODULO' and oggetto='MODULO_APPALTO_PNRR_PNC' and Proprieta='ATTIVA'

	END

END
GO
