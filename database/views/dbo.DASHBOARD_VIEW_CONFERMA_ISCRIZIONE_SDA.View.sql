USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONFERMA_ISCRIZIONE_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_CONFERMA_ISCRIZIONE_SDA] as
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
		,convert( varchar(10) , D.DataInvio , 121 )   as DataDA 
		,convert( varchar(10) , D.DataInvio , 121 )   as DataA 
		,case when istanza.JumpCheck='conferma' then 1 else 0 end as Conferma_Automatica
FROM CTL_DOC d
	inner join aziende a on d.Destinatario_Azi = a.idazi
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
	left join CTL_DOC istanza ON d.linkeddoc = istanza.id
	left join CTL_DOC bando ON istanza.linkeddoc = bando.id
	left join Document_Bando_Riferimenti RIF on RIF.idHeader=bando.id and RIF.RuoloRiferimenti='Istanze' 
	--left join profiliutente p on p.idpfu = RIF.idPfu

where d.tipoDoc = 'CONFERMA_ISCRIZIONE_SDA' and d.deleted=0




GO
