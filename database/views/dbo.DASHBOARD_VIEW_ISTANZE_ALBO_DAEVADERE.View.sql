USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE] as
select 
		p.idPfu
		,d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,ba.protocollo as ProtocolloRiferimento
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
		, case when isnull( v.id , 0 ) = 0 then 0 else 1 end as Valutato 
		,d.IdpfuInCharge
		,d.tipoDoc
		,ba.id as ListaAlbi
		,ISNULL(ba.JumpCheck,'') as JumpCheck
		, convert( varchar(10) , d.DataInvio , 121 ) as DataInvioAl
	    , convert( varchar(10) , d.DataInvio , 121 ) as DataInvioDal
	    , des.DataConferma
FROM 
	CTL_DOC d with (nolock)
	--inner join CTL_DOC_Destinatari des on d.id = des.idheader
	inner join CTL_DOC ba with (nolock) on ba.id = d.linkeddoc
	left join CTL_DOC_Destinatari des  with (nolock) on ba.id = des.idheader and d.azienda = des.IdAzi
	inner join profiliutente p with (nolock) on p.pfuidazi = ba.azienda --des.IdAzi
	inner join aziende a with (nolock) on d.azienda = a.idazi
	left outer join CTL_DOC_READ r with (nolock) on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
	left outer join dm_attributi d1 with (nolock) on d.azienda =d1.lnk and d1.dztnome = 'CancellatoDiUfficio' and d1.idapp=1
    left outer join dm_attributi e with (nolock) on d.azienda =e.lnk and e.dztnome = 'CarBelongTo' and e.idapp=1
    left outer join dm_attributi f with (nolock)on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
    left outer join CTL_DOC_Value sp with (nolock) on sp.IdHeader = d.id and DSE_ID = 'SCADENZA' and DZT_Name = 'DataScadenzaPerentoria'
	-- verifico la presenza di un documento di valutazione già valutato
	left outer join  CTL_DOC v with (nolock) on v.linkedDoc =  d.id
							and v.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE','CONFERMA_ISCRIZIONE_LAVORI','SCARTO_ISCRIZIONE_LAVORI' ) 
							and v.StatoFunzionale in ( 'Valutato' ,'InvioInCorso')--'InLavorazione'
							and v.deleted = 0
	inner join  Document_Bando_Riferimenti RIF with (nolock) on RIF.idHeader=ba.id and RIF.RuoloRiferimenti='Istanze' and RIF.idPfu=p.idpfu

where d.StatoDoc <> 'Saved' 
     --d.StatoDoc not in ('Saved' ,'Invalidate')
	and left ( d.tipoDoc , 12 ) = 'ISTANZA_Albo'
	and d.deleted = 0
	
	-- sono abilitati alla visione gli utenti in carico se presente altrimenti tutti
	--and ( isnull(d.idPfuInCharge , 0 ) = 0 or p.idPfu = isnull(d.idPfuInCharge , 0 ) )

	-- non devono essere visualizzate istanze già valutate ma non notificate
	--and v.id is null









GO
