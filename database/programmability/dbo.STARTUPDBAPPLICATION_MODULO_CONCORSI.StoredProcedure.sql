USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_CONCORSI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_CONCORSI]
AS
BEGIN
  
  declare @Value_ML_Viewer as  nvarchar(max)
  
  declare @Value_ML_Cartella as  nvarchar(max)

  
  
  -----------------------------------------------------------------------------------
  --se sul cliente è attivo il modulo GROUP_CONCORSI 
  --allora modifico il valore delle SYS "SYS_BANDI_CUI_STO_PARTECIPANDO" e "SYS_BANDI_PRIVATI"
  --con il valore si due nuove key ML adatte quando ci sono attivi anche i concorsi
  -----------------------------------------------------------------------------------
	IF EXISTS (	select id from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GROUP_CONCORSI,%'	)
	begin
		
		select @Value_ML_Viewer=dbo.CNV_ESTESA('Avvisi / Bandi | Bandi a cui sto partecipando (solo Procedure Aperte, Ristrette e Concorsi)','I')
		select @Value_ML_Cartella=dbo.CNV_ESTESA('Bandi a cui sto partecipando (solo Procedure Aperte, Ristrette e Concorsi)','I')

	end
	else
	begin
		set @Value_ML_Viewer = 'Avvisi / Bandi | Bandi a cui sto partecipando (solo Procedure Aperte e Ristrette)'
		set @Value_ML_Cartella = 'Bandi a cui sto partecipando (solo Procedure Aperte e Ristrette)'
	end


	update lib_dictionary
			set DZT_ValueDef = @Value_ML_Viewer
			where DZT_Name='SYS_BANDI_CUI_STO_PARTECIPANDO'

    update lib_dictionary
			set DZT_ValueDef = @Value_ML_Cartella
			where DZT_Name='SYS_BANDI_PRIVATI'

END
GO
