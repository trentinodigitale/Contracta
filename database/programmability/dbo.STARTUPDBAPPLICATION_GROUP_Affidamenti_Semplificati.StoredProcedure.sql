USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GROUP_Affidamenti_Semplificati]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GROUP_Affidamenti_Semplificati]
AS
BEGIN
	-----------------------------------------------------------------------------------
	--SE IL MODULO GROUP_Affidamenti_Semplificati NON E' ATTIVO SUL CLIENTE
	--I MODELLI ASSOCIATI VENGONO CANCELLATI
	-----------------------------------------------------------------------------------
	IF EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_Affidamenti_Semplificati' 
			)
	BEGIN
		update ctl_doc set deleted=0  where isnull(versione,'')='AFFIDAMENTO_DIRETTO_SEMPLIFICATO' and LinkedDoc = 0

	END
	ELSE
	BEGIN
		update ctl_doc set deleted=1  where isnull(versione,'')='AFFIDAMENTO_DIRETTO_SEMPLIFICATO' and LinkedDoc = 0
	END

END
GO
