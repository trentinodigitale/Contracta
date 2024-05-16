USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ESTRAZIONE_LISTINI_CONVENZIONI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[MAIL_ESTRAZIONE_LISTINI_CONVENZIONI] as

	select	d.id as iddoc
			, 'I' as LNG
			, d.tipodoc
			, d.data
			, isnull(d.Protocollo,'') as Protocollo
			, d.titolo as TipoListino
			, DMV_DescML as Ambito
			--, d.Body
			--, d.DataInvio
			--, d.ProtocolloGenerale
			--, d.Fascicolo 
			--, d.NumeroDocumento as CIG
			--, a.aziRagioneSociale
			--, convert( varchar , dateadd(dd,NumGiorni,d.DataInvio ) , 103 ) as DataDisponibilita
			--, PercorsoDiRete
			--, Soglia
	from ctl_doc d with(nolock) 
			--cross join Lingue with(nolock) 
			--inner join profiliutente p  with(nolock) on p.idpfu = d.idpfu
			--inner join aziende a with(nolock) on a.idazi = d.azienda
			inner join LIB_DomainValues with (nolock) on DMV_DM_ID ='Ambito' and DMV_Cod = JumpCheck
	where 
		tipodoc='ESTRAZIONE_LISTINI_CONVENZIONI'
		and statofunzionale='Invio_con_errori'


GO
