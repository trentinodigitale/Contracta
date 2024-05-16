USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOC_NOTIER_ISCRIZ_INFO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_DOC_NOTIER_ISCRIZ_INFO] as

	select d.*,
			-- con l'introduzione della registrazione peppol fatture questo ragionamento su utente_uno non è più valido. ci baseremo sulla presenza dei documenti di richiesta e non sull'id peppol
			--case when DM.vatValore_FT is null 
			--			then '1' 
			--			else '0' 
			--end as utente_uno, 

			case when doc.id is null 
						then '1' 
						else '0' 
			end as utente_uno, 


			dm.vatValore_FT as IDNOTIER,
			isnull(d3.value,dm2.vatValore_FT) as PARTICIPANTID,
			p.pfuCodiceFiscale as codicefiscale,
			isnull(d2.value,'') as CFRapLeg

			--,case when D.JumpCheck = '' then 'HELP_UTENTE_ISCRIZIONE_NOTIER' else 'HELP_UTENTE_ISCRIZIONE_NOTIER_FATTURE' end as Chiede

		 from ctl_doc D with(nolock)
				left join profiliutente P with(nolock) ON d.idpfu = p.idpfu
				left join  aziende A with(nolock) ON p.pfuidazi=a.idazi
				left join  DM_Attributi DM with(nolock) ON dm.lnk = a.idazi and dm.dztNome = 'IDNOTIER'
				left join  DM_Attributi DM2 with(nolock) ON DM2.lnk = a.idazi and DM2.dztNome = 'PARTICIPANTID'

				left join CTL_DOC_VALUE d2 with(nolock) ON d2.IdHeader = d.id and d2.dse_id = 'INFO' and d2.dzt_name = 'codicefiscale' and isnull(d2.value,'') <> ''
				left join CTL_DOC_VALUE d3 with(nolock) ON d3.IdHeader = d.id and d3.dse_id = 'INFO' and d3.dzt_name = 'PARTICIPANTID' and isnull(d3.value,'') <> ''

				left join ctl_doc doc with(nolock) on doc.Azienda = d.Azienda and doc.TipoDoc = 'NOTIER_ISCRIZ' and doc.StatoFunzionale = 'Inviato' and d.JumpCheck = doc.JumpCheck and doc.id <> d.id and doc.Deleted = 0


		where D.tipodoc = 'NOTIER_ISCRIZ'

GO
