USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_FASCICOLO_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[OLD_MAIL_FASCICOLO_GARA] as

	select	d.id as iddoc
			, lngSuffisso as LNG
			, d.tipodoc
			, d.data
			, d.Protocollo
			, d.titolo
			, d.Body
			, d.DataInvio
			, d.ProtocolloGenerale
			, d.Fascicolo 
			, d.NumeroDocumento as CIG
			, a.aziRagioneSociale
			, convert( varchar , dateadd(dd,NumGiorni,d.DataInvio ) , 103 ) as DataDisponibilita
	from ctl_doc d with(nolock) 
			cross join Lingue with(nolock) 
			inner join profiliutente p  with(nolock) on p.idpfu = d.idpfu
			inner join aziende a with(nolock) on a.idazi = d.azienda
			--left join aziende a  with(nolock) on a.idazi = p.pfuidazi
			cross join 
				(
				select NumGiorni  from ctl_doc with (nolock)
					inner join Document_Config_FascicoloGara with (nolock) on idheader = id
					where tipodoc='parametri_fascicolo_gara' and statofunzionale='confermato'
				) Giorni
	where 
		tipodoc='FASCICOLO_GARA'


GO
