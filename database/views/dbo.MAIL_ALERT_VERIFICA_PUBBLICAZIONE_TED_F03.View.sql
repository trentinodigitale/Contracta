USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ALERT_VERIFICA_PUBBLICAZIONE_TED_F03]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_ALERT_VERIFICA_PUBBLICAZIONE_TED_F03] AS
	SELECT a.id AS idDOC, 
			'I' AS LNG, 
			a.note,
			DMV_DescML as StatoFunzionale,
			l.TED_CIG_AGG,
			--g.*
			Gara.Protocollo
			
		from CTL_DOC a with(nolock) 
			
				--inner join Document_TED_GARA g with(nolock) on g.idHeader = a.id
				inner join Document_TED_Aggiudicazione l with(nolock) on l.idHeader = a.id
				inner join ctl_Doc Gara with (nolock) on Gara.id=a.LinkedDoc
				left outer join LIB_DomainValues  with(nolock,index(IX_LIB_DomainValues_DMV_DM_ID_DMV_COD_DMV_DescML)) on a.statofunzionale=DMV_Cod and DMV_DM_ID='StatoFunzionale'

		where a.tipodoc = 'DELTA_TED_AGGIUDICAZIONE' --and a.StatoFunzionale <> 'Annullato'
GO
