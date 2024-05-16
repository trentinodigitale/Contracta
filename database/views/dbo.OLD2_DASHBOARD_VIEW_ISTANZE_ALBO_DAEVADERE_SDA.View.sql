USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  view [dbo].[OLD2_DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA] as
select 
		p.idPfu -- utenti dell'azienda destinataria
		,d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,ba.Protocollo as ProtocolloRiferimento
		,d.Protocollo
		,d1.vatvalore_ft as CancellatoDiUfficio
		,e.vatvalore_ft as CarBelongTo
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
		, convert( datetime , sp.Value , 126 ) as DataScadenzaPerentoria
		, d.DataScadenza as DataScadenzaA
		, convert( datetime , sp.Value , 126 )  as DataScadenzaPerentoriaA

		--, ba.Protocollo as ProtocolloBando
		, bando.ProtocolloBando
		, ba.titolo as TitoloSDA

		, case when isnull( v.id , 0 ) = 0 then 0 else 1 end as Valutato 
		,ba.id as ListaAlbi
		,d.idPfuInCharge
		, convert( varchar(10) , d.DataInvio , 121 ) as DataInvioAl
	  ,convert( varchar(10) , d.DataInvio , 121 ) as DataInvioDal

FROM CTL_DOC d
	--inner join CTL_DOC_Destinatari des on d.id = des.idheader
	inner join CTL_DOC ba on ba.id = d.linkeddoc
	inner join document_bando bando on ba.id = bando.idheader
	inner join profiliutente p on p.pfuidazi = ba.Azienda--des.IdAzi
	inner join aziende a on d.azienda = a.idazi
	left outer join CTL_DOC_READ r on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
	left outer join dm_attributi d1 on d.azienda =d1.lnk and d1.dztnome = 'CancellatoDiUfficio' and d1.idapp=1
    left outer join dm_attributi e on d.azienda =e.lnk and e.dztnome = 'CarBelongTo' and e.idapp=1
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
	left outer join CTL_DOC_Value sp on sp.IdHeader = d.id and DSE_ID = 'SCADENZA' and DZT_Name = 'DataScadenzaPerentoria'
	-- verifico la presenza di un documento di valutazione già valutato
	left outer join  CTL_DOC v on v.linkedDoc =  d.id
							and v.TipoDoc in ( 'SCARTO_ISCRIZIONE_SDA' ,'INTEGRA_ISCRIZIONE_SDA' , 'CONFERMA_ISCRIZIONE_SDA' ) 
							and v.StatoFunzionale in ( 'Valutato' ,'InvioInCorso')--'InLavorazione'
							and v.deleted = 0
	inner join  Document_Bando_Riferimenti RIF on RIF.idHeader=ba.id and RIF.RuoloRiferimenti='Istanze' and RIF.idPfu=p.idpfu

where 
    d.StatoDoc <> 'Saved'
    --d.StatoDoc not in ('Saved' ,'Invalidate')
    and left ( d.tipoDoc , 11 ) = 'ISTANZA_SDA'
    and d.deleted = 0
	-- sono abilitati alla visione gli utenti in carico se presente altrimenti tutti
	--and ( isnull(d.idPfuInCharge , 0 ) = 0 or p.idPfu = isnull(d.idPfuInCharge , 0 ) )

	-- non devono essere visualizzate istanze già valutate ma non notificate
	--and v.id is null





GO
