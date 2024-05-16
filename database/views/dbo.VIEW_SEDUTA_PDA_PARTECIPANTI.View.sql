USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_SEDUTA_PDA_PARTECIPANTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select linkeddoc,* from ctl_doc where id = 410711

CREATE VIEW [dbo].[VIEW_SEDUTA_PDA_PARTECIPANTI]   as

select 
	S.id as IdSeduta, M.* , A.aziRagioneSociale, pfuNome , M.type as ActionTypeChat
	from 
	ctl_doc S with (nolock)
		inner join ctl_doc_value  SD_start with (nolock) on SD_start.idheader = S.id  and SD_start.dse_id='DATE' and SD_start.DZT_Name='DataInizio'
			inner join ctl_doc_value  SD_End with (nolock) on SD_End.idheader = S.id  and SD_End.dse_id='DATE' and SD_End.DZT_Name='DataFine'
			inner join ctl_doc PDA with (nolock) on PDA.id = S.linkeddoc  and pda.tipodoc='PDA_MICROLOTTI'
			inner join CTL_CHAT_MESSAGES M with (nolock) on M.idHeader = PDA.id and M.type in ('IN','OUT')
			inner join profiliutente U with (nolock) on U.idpfu = M.idpfu 
			inner join aziende A with (nolock) on A.idazi=U.pfuIdAzi

		where
			
			S.Tipodoc = 'SEDUTA_PDA'and S.StatoFunzionale <> 'InLavorazione'
			and M.dataIns >= SD_start.value and M.dataIns <= SD_End.value
			--and S.id = 410711   
		

	
GO
