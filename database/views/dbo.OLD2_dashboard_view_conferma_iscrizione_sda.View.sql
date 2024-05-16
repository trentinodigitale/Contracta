USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_dashboard_view_conferma_iscrizione_sda]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_dashboard_view_conferma_iscrizione_sda] as
select 
	
		d.Titolo
		--bando.titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,d.ProtocolloRiferimento
		,d.Protocollo
		,d.tipoDoc as OPEN_DOC_NAME
		,d.id
		,d.StatoFunzionale
		,d.StatoDoc
		,a.aziPartitaIVA
		,f.vatvalore_ft as CodiceFiscale
		,a.idazi
		, d.Data
		,cast(a.idazi as varchar(400)) as idAziPartecipante
		,bando.titolo as TitoloBando
		,Rif.idpfu 
		,bando.id as ListaAlbi
FROM CTL_DOC d
	inner join aziende a on d.Destinatario_Azi = a.idazi
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
	left join CTL_DOC istanza ON d.linkeddoc = istanza.id
	left join CTL_DOC bando ON istanza.linkeddoc = bando.id
	left join Document_Bando_Riferimenti RIF on RIF.idHeader=bando.id and RIF.RuoloRiferimenti='Istanze' 
	--left join profiliutente p on p.idpfu = RIF.idPfu

where d.tipoDoc = 'CONFERMA_ISCRIZIONE_SDA' and d.deleted=0



GO
