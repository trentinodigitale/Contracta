USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_SCELTA_RUP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_SCELTA_RUP]
AS
BEGIN
	--SE NON ATTIVO IL MODULO DEL MERCATO ELETTRONICO NASCONDO IL CAMPO "SCELTA_RUP" SULLA
	--MASCHERA DEL CAMBIO_RUOLO
	IF NOT EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_Albo_Telematico' 
			)
	BEGIN
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CAMBIO_RUOLO_UTENTE_SCELTA_RUOLO' and Oggetto='scelta_RUP' and Proprieta='Hide' 
	END
	ELSE
	BEGIN
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CAMBIO_RUOLO_UTENTE_SCELTA_RUOLO' and Oggetto='scelta_RUP' and Proprieta='Hide' 
	END

END
GO
