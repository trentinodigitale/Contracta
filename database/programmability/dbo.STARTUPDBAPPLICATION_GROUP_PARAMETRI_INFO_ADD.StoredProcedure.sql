USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_GROUP_PARAMETRI_INFO_ADD]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_GROUP_PARAMETRI_INFO_ADD]
AS
BEGIN
	--se sul cliente è attivo il modulo GROUP_PARAMETRI_INFO_ADD 
	--la colonna Apri nella scheda anagrafica sarà visibile
	IF EXISTS ( select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'GROUP_PARAMETRI_INFO_ADD' )
	BEGIN
		update CTL_Parametri 
				set Valore='0' 
			where Contesto='SCHEDA_ANAGRAFICA_CLASSEISCRIZ' and Oggetto='FNZ_OPEN' 
			  and Proprieta='Hide'
	END
	ELSE
	BEGIN
		update CTL_Parametri 
			set Valore='1' 
		where Contesto='SCHEDA_ANAGRAFICA_CLASSEISCRIZ' and Oggetto='FNZ_OPEN' 
			  and Proprieta='Hide'
	END

END
GO
