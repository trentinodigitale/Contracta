USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_LISTINO_ORDINI_CONVENZIONI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_LISTINO_ORDINI_CONVENZIONI]
AS
BEGIN
	
	--SE ATTIVO/NON ATTIVO il MODULO "LISTINO_ORDINI_CONVENZIONI" 
	--SULLA GESTIONE DEI MODELLI DI CONVENZIONE VISUALIZZO/NASCONDO LE COLONNE "Listino Ordini" E "Perfezionamento Listino Ordini" 
	--SULLA GESTIONE CONVENZIONE VISUALIZZO/NASCONDO I CAMPI "Registro di Sistema Listino Ordini", "Registro di Sistema Listino Ordini", "Data Listino Ordini", "Stato Listino Ordini"
	IF NOT EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'LISTINO_ORDINI_CONVENZIONI' 
			)
	BEGIN
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONFIG_MODELLI_CONVENZIONI_MODELLI' and Oggetto='MOD_ListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONFIG_MODELLI_CONVENZIONI_MODELLI' and Oggetto='MOD_PerfListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONVENZIONE_TESTATA' and Oggetto='PresenzaListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='ProtocolloListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='DataListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIFiltro' and Oggetto='PresenzaListinoOrdini' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIFiltro' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='1'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIGriglia' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'
		

	END
	ELSE
	BEGIN
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONFIG_MODELLI_CONVENZIONI_MODELLI' and Oggetto='MOD_ListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONFIG_MODELLI_CONVENZIONI_MODELLI' and Oggetto='MOD_PerfListinoOrdini' and Proprieta='Hide'
		
		--PresenzaListinoOrdini in testata della convenzione se presente il parametro per attivarlo lo metto visibile
		--altrimenti lo lascio nascosto per consentire al cliente di adeguare i modelli relativi
		if exists(select id from CTL_Parametri with (nolock) where Contesto='CONVENZIONE' and Oggetto='PresenzaListinoOrdini' and Proprieta='ATTIVA' and valore='YES')
		begin
			update 	
				ctl_parametri
					set Valore='0'
				where 
					contesto='CONVENZIONE_TESTATA' and Oggetto='PresenzaListinoOrdini' and Proprieta='Hide'
		end
		else
		begin
			update 	
				ctl_parametri
					set Valore='1'
				where 
					contesto='CONVENZIONE_TESTATA' and Oggetto='PresenzaListinoOrdini' and Proprieta='Hide'
		end

		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='ProtocolloListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='DataListinoOrdini' and Proprieta='Hide'
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='CONVENZIONE_DOCUMENT' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'

		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIFiltro' and Oggetto='PresenzaListinoOrdini' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIFiltro' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'
		
		update 	
			ctl_parametri
				set Valore='0'
			where 
				contesto='DASHBOARD_VIEW_CONVENZIONIGriglia' and Oggetto='StatoListinoOrdini' and Proprieta='Hide'
		

	END

END
GO
