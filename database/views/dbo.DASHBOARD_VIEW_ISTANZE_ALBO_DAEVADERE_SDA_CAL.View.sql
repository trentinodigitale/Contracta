USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL] as
select 
		--p.idPfu -- utenti dell'azienda destinataria
		p.idPfu -- utenti tra i riferimenti delle istanze
		,d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,ba.Protocollo as ProtocolloRiferimento
		,d.Protocollo
		,d.tipoDoc as OPEN_DOC_NAME
		,isnull( v.tipoDoc  , d.tipoDoc ) as tipoDoc 
		,d.id
		,d.StatoFunzionale
		,d.StatoDoc
		,a.aziPartitaIVA
		,a.idazi
		,a.idazi as idAziPartecipante

		, isnull( convert( datetime , sp.Value , 126 )  , d.DataScadenza ) as DataScadenza
		, isnull( convert( datetime , sp.Value , 126 )  , d.DataScadenza ) as DataScadenzaA
		, isnull( convert( datetime , sp.Value , 126 )  , d.DataScadenza ) as DataRiferimento

		--, ba.Protocollo as ProtocolloBando
		, bando.ProtocolloBando
		, ba.titolo as TitoloSDA

		, case when isnull( v.id , 0 ) = 0 then 0 else 1 end as Valutato 

		, convert( datetime , convert( varchar(10) , isnull( convert( datetime , sp.Value , 126 )  , d.DataScadenza ) , 126 )+ 'T00:00:00.000' , 126 ) as DataRiferimento2
		, 1 as bRead
		, '' as FNZ_OPEN
		,f.vatvalore_ft as CodiceFiscale
FROM CTL_DOC d
	inner join CTL_DOC_Destinatari des on d.id = des.idheader
	inner join CTL_DOC ba on ba.id = d.linkeddoc
	inner join document_bando bando on ba.id = bando.idheader
	inner join profiliutente p on p.pfuidazi = des.IdAzi
	inner join  Document_Bando_Riferimenti RIF on RIF.idHeader=ba.id and RIF.RuoloRiferimenti='Istanze' and RIF.idPfu=p.idpfu
	inner join aziende a on d.azienda = a.idazi
	left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
	left outer join CTL_DOC_Value sp on sp.IdHeader = d.id and DSE_ID = 'SCADENZA' and DZT_Name = 'DataScadenzaPerentoria'

	-- verifico la presenza di un documento di valutazione già valutato
	left outer join  CTL_DOC v on v.linkedDoc =  d.id
							and v.TipoDoc in ( 'SCARTO_ISCRIZIONE_SDA' ,'INTEGRA_ISCRIZIONE_SDA' , 'CONFERMA_ISCRIZIONE_SDA' ) 
							and v.StatoFunzionale = 'Valutato' --'InLavorazione'
							and v.deleted = 0

where d.StatoDoc <> 'Saved'
	and left ( d.tipoDoc , 11 ) = 'ISTANZA_SDA'

	and d.StatoFunzionale -- = 'InValutazione'
		in ( 'InValutazione' , 'AttesaIntegrazione' ,'Integrato')

	and d.deleted = 0

--union
--select 
--
--		idPfu
--		,Titolo
--		,aziRagioneSociale
--		,DataInvio
--		,ProtocolloRiferimento
--		,Protocollo
--		,CancellatoDiUfficio
--		,CarBelongTo
--		,OPEN_DOC_NAME
--		,id
--		,bRead 
--		,StatoFunzionale
--		,StatoDoc
--		,aziPartitaIVA
--		,CodiceFiscale
--		,idazi
--		,idAziPartecipante
--		,DataScadenzaPerentoria as DataScadenza
--		,DataScadenzaPerentoriaA as DataScadenzaA
--
--		,ProtocolloBando
--		,TitoloSDA
--		, DataScadenzaPerentoria as DataRiferimento
--from DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA
--	where DataScadenzaPerentoria is not null
--		and StatoFunzionale = 'InValutazione'
--GO
--
--SET ANSI_NULLS OFF
--GO
--SET QUOTED_IDENTIFIER OFF
--GO



GO
