USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_NUOVA_PROCEDURA_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_NUOVA_PROCEDURA_FROM_USER] as 
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

	from profiliutente with (nolock)
		left join ( 
					select items from dbo.Split(
					(	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
				) W on W.items ='AFFIDAMENTO_DIRETTO_DUE_FASI'
					


GO
