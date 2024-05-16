USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RITIRA_OFFERTA_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[RITIRA_OFFERTA_TESTATA] as 


	select 
			 d.id 
			,d.id as idheader
			,d.Azienda 
			,o.Protocollo as ProtocolloOfferta 
			,o.datainvio as DataOperazione

			,nu.Value as NomeUtente
			,ru.Value as RuoloUtente
			,al.Value as Allegato

			,d.Destinatario_Azi
			,d.ProtocolloRiferimento as ProtocolloBando
			,Ba.CIG
			,d.Fascicolo
			,B.Body as  DescrizioneEstesa
			,d.Body
			,d.SIGN_ATTACH

		from CTL_DOC d with(nolock) 
			inner join CTL_DOC o with(nolock) on d.linkeddoc = o.id -- Offerta
			inner join CTL_DOC B with(nolock) on o.linkeddoc = B.id -- Bando
			inner join Document_Bando Ba with(nolock) on Ba.idHeader = o.LinkedDoc -- Bando

			left Outer Join CTL_DOC_Value nu with(nolock) on nu.IdHeader = d.id and nu.DSE_ID = 'FIRMA' and nu.DZT_Name = 'NomeUtente' 
			left Outer Join CTL_DOC_Value ru with(nolock) on ru.IdHeader = d.id and ru.DSE_ID = 'FIRMA' and ru.DZT_Name = 'RuoloUtente' 
			left Outer Join CTL_DOC_Value al with(nolock) on al.IdHeader = d.id and al.DSE_ID = 'FIRMA' and al.DZT_Name = 'Allegato' 



GO
