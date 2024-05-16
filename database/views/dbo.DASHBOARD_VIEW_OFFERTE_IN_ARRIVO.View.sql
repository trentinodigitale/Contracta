USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_OFFERTE_IN_ARRIVO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_OFFERTE_IN_ARRIVO] as
--Versione=1&data=2012-12-18&Attivita=40053&Nominativo=Sabato
select 
		p.idPfu -- utenti dell'azienda destinataria
		,d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,d.ProtocolloRiferimento
		,d.Protocollo
		,d.tipoDoc as OPEN_DOC_NAME
		,d.id
		,case when r.DOC_NAME is not null then '0' else '1'end as bRead 
		,d.StatoFunzionale
		,d.StatoDoc
		,a.aziPartitaIVA
		,f.vatvalore_ft as CodiceFiscale
		,a.idazi
		,a.idazi as idAziPartecipante
		, d.DataScadenza
		, d.DataScadenza as DataScadenzaA

		, ba.Protocollo as ProtocolloBando


FROM CTL_DOC d  -- offerta
	inner join CTL_DOC ba on ba.id = d.linkeddoc -- bando
	inner join Document_Bando bd on ba.id = bd.idheader -- dettagli del bando
	inner join profiliutente p on p.pfuidazi = d.Destinatario_Azi -- gli utenti dell'azienda destinataria
	inner join aziende a on d.azienda = a.idazi 
	left outer join CTL_DOC_READ r on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1


where d.StatoDoc <> 'Saved'
	and  d.tipoDoc  = 'OFFERTA'
	and d.deleted = 0

	-- le offerte saranno visibili solo dopo la data di apertura delle offerte
	and getdate() >= bd.DataAperturaOfferte 


GO
