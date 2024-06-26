USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GROUP_OCP_WS]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GROUP_OCP_WS]
AS
BEGIN
		
	--SE IL MODULO GROUP_OCP_WS E' ATTIVO SUL CLIENTE LA PROPRIETA'
	--VIENE SETTATA PER RENDERE VISIBILE NEL FILTRO ATTRIBUTO
	--ALTRIMENTI METTE HIDE	
	IF EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_OCP_WS' 
			)
	BEGIN
		update CTL_Parametri 
				set Valore='0' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='Attiva_OCP' 
			  and Proprieta='Hide'  
	END
	ELSE
	BEGIN
		update CTL_Parametri 
				set Valore='1' 
			where Contesto='DASHBOARD_VIEW_ENTIFiltro' and Oggetto='Attiva_OCP' 
			  and Proprieta='Hide'
	END
END
GO
