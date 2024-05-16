USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NUOVA_PROCEDURA_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[NUOVA_PROCEDURA_FROM_USER] as 
select 
	idpfu as ID_FROM
	,pfuidazi as Azienda
	,cast( pfuidazi as varchar) + '#' + '\0000\0000' as StrutturaAziendale
	,cast( pfuidazi as varchar) + '#' + '\0000\0000' as DirezioneEspletante
	,idpfu as UserRUP
	,case
		when W.items IS not null then '1'
		else '0'
	 end AS AFFIDAMENTO_DIRETTO_DUE_FASI
	
	, CU.Cottimo_Gara_Unificato_Attivo

	from profiliutente with (nolock)
		left join ( 
					select items from dbo.Split(
					(	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
				) W on W.items ='AFFIDAMENTO_DIRETTO_DUE_FASI'
					
		--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
		cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato_Attivo ) CU  


GO
