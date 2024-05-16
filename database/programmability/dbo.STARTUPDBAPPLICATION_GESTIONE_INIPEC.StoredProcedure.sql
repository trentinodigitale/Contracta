USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GESTIONE_INIPEC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GESTIONE_INIPEC]
AS
BEGIN
		
	-----------------------------------------------------------------------
	-- attivazione e disattivazione del modulo GESTIONE_INIPEC
	-----------------------------------------------------------------------

	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GESTIONE_INIPEC,%'	)
	BEGIN
		update CTL_Parametri 
				set Valore='0' 
			where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='statoInipec' 
			  and Proprieta='Hide'  
	END
	ELSE
	BEGIN
		update CTL_Parametri 
				set Valore='1' 
			where Contesto='DASHBOARD_VIEW_FORNITORIFiltro' and Oggetto='statoInipec' 
			  and Proprieta='Hide'
	END
END
GO
