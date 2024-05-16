USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RITIRA_RISPOSTA_CONCORSO_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[RITIRA_RISPOSTA_CONCORSO_TESTATA] as 


	select 
			 d.id 
			,d.id as idheader
			--,d.Azienda 
			,case
				when isnull(AN.Value,'0') = '1' 
					then d.Azienda 
				else 
					null
			 end as Azienda 
			--,o.Protocollo as ProtocolloOfferta 
			,case
				when isnull(AN.Value,'0') = '1' 
					then o.Protocollo 
				else 
					null
			 end as ProtocolloOfferta,
			
			case
				when isnull(AN.Value,'0') = '1' 
					then o.datainvio 
				else 
					null
			 end as DataOperazione

			--,o.datainvio as DataOperazione

			--,nu.Value as NomeUtente
			--,ru.Value as RuoloUtente
			--,al.Value as Allegato

			--,d.Destinatario_Azi
			,case
				when isnull(AN.Value,'0') = '1' 
					then d.Destinatario_Azi 
				else 
					null
			 end as Destinatario_Azi
			,d.ProtocolloRiferimento as ProtocolloBando
			,Ba.CIG
			,d.Fascicolo
			,B.Body as  DescrizioneEstesa
			,d.Body
			,d.SIGN_ATTACH
			, d.StatoFunzionale
			, d.titolo
			, d.Protocollo
			, d.DataInvio
			, d.ProtocolloGenerale
			, d.DataProtocolloGenerale
			, d.LinkedDoc

		from CTL_DOC d with(nolock) 

			inner join CTL_DOC o with(nolock) on d.linkeddoc = o.id -- Risposta
			inner join CTL_DOC B with(nolock) on o.linkeddoc = B.id -- Bando
			inner join Document_Bando Ba with(nolock) on Ba.idHeader = o.LinkedDoc -- Bando

			--Recupero il flag sull'anonimato
			left join CTL_DOC_Value AN with (nolock) on o.id = AN.idheader and DSE_ID = 'ANONIMATO' and DZT_Name = 'DATI_IN_CHIARO'

			--left Outer Join CTL_DOC_Value nu with(nolock) on nu.IdHeader = d.id and nu.DSE_ID = 'FIRMA' and nu.DZT_Name = 'NomeUtente' 
			--left Outer Join CTL_DOC_Value ru with(nolock) on ru.IdHeader = d.id and ru.DSE_ID = 'FIRMA' and ru.DZT_Name = 'RuoloUtente' 
			--left Outer Join CTL_DOC_Value al with(nolock) on al.IdHeader = d.id and al.DSE_ID = 'FIRMA' and al.DZT_Name = 'Allegato' 


GO
