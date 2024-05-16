USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GROUP_NOTIER_PA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GROUP_NOTIER_PA]
AS
BEGIN

	-----------------------------------------------------------------------------------
	--SE IL MODULO GROUP_NOTIER_PA E' ATTIVO SUL CLIENTE LE PROPRIETA'
	--VIENE SETTATA PER RENDERE VISIBILE NEL FILTRO ATTRIBUTO
	--ALTRIMENTI METTE HIDE	
	-----------------------------------------------------------------------------------
	IF EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_NOTIER_PA' 
			)
	BEGIN
		update CTL_Parametri 
				set Valore='0' 
				where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='iscrittoPeppol' 
				and Proprieta='Hide'
			  
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide' 
		
		--filtro su gestione enti- anagrafice
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='iscrittoPeppolEnte' 
			and Proprieta='Hide' 
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide'
		--griglia  su gestione enti- anagrafiche
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='DASHBOARD_VIEW_ENTIGriglia' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide' 

	END
	ELSE
	BEGIN
		update CTL_Parametri 
				set Valore='1' 
				where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='iscrittoPeppol' 
				and Proprieta='Hide'
			  
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide' 
		
		--filtro su gestione enti- anagrafice
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='iscrittoPeppolEnte' 
			and Proprieta='Hide' 
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide' 
		--griglia  su gestione enti- anagrafiche
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='DASHBOARD_VIEW_ENTIGriglia' and Oggetto='PARTICIPANTID' 
			and Proprieta='Hide' 
	END

END
GO
