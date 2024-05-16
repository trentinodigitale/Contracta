USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CONFIGURAZIONE_ENTE_AVCP]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_CONFIGURAZIONE_ENTE_AVCP] as
--recupero i documenti di configurazione per gli enti
	select 
		D.id,
		D.idpfu,
		D.azienda as azi_ente,
		D.StatoFunzionale,
		D.DataInvio,
		'' as FNZ_OPEN,
		'AVCP_CONFIG.900.600' as OPEN_DOC_NAME,
		case 
			-- se non ci sta testo finisce con /
			when CHARINDEX('/',REVERSE(C.URL_CLIENT)) > 0 and  RIGHT(C.URL_CLIENT, CHARINDEX('/',REVERSE(C.URL_CLIENT))-1) = '' then C.URL_CLIENT+FileNameIndice+'.xml'
			else C.URL_CLIENT+'/'+FileNameIndice+'.xml'
		end
		as URL_CLIENT,
		aziragionesociale
	from ctl_doc D
	inner join Document_AVCP_CONFIG C on C.idheader=D.id
	inner join aziende on idazi=azienda
	where D.tipodoc='AVCP_CONFIG' and D.StatoFunzionale='Pubblicato'

union
---recupero gli enti per i quali non è presente un doc di configurazione
select 
	-idazi as id,
	NULL as idpfu,
	idazi  as azi_ente,
	'' as StatoFunzionale,
	NULL as DataInvio,
	'../toolbar/write.jpg' as FNZ_OPEN,
	'AVCP_CONFIG' as OPEN_DOC_NAME,
	'' as URL_CLIENT,
	aziragionesociale
from aziende
where azivenditore = 0 and azideleted=0  and idazi not in (
		--recupero l'elenco delle aziende che hanno un doc di configurazione per codice fiscale
		select lnk from dm_attributi
		inner join ctl_doc on Azienda=lnk and Deleted=0 and StatoFunzionale='Pubblicato' and tipodoc='AVCP_CONFIG'
		where dztnome='codicefiscale' 
)


GO
