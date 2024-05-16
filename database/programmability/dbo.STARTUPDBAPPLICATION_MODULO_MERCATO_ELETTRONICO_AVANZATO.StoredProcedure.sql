USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_MERCATO_ELETTRONICO_AVANZATO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_MERCATO_ELETTRONICO_AVANZATO]
AS
BEGIN
	-----------------------------------------------------------------------------------
	-- atttivazione e disattivazione del modulo del MODULO_MERCATO_ELETTRONICO_AVANZATO
	-----------------------------------------------------------------------------------
	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,MODULO_MERCATO_ELETTRONICO_AVANZATO,%'	)
	BEGIN
		update CTL_Parametri 
				set Valore='0' 
			where Contesto='BANDO_COPERTINA' and Oggetto='PresenzaCatalogo' 
			  and Proprieta='Hide'  
	END
	ELSE
	BEGIN
		update CTL_Parametri 
				set Valore='1' 
			where Contesto='BANDO_COPERTINA' and Oggetto='PresenzaCatalogo' 
			  and Proprieta='Hide'
	END

END
GO
