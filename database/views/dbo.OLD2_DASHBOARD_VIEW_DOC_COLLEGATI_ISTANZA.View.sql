USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_DOC_COLLEGATI_ISTANZA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_DOC_COLLEGATI_ISTANZA] as
select 
		d.IdPfu
		,d.Titolo
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
		,a.idazi as idAziPartecipante
		, isnull(b.JumpCheck,'') as JumpCheck
		,B.id as ListaAlbi
		,I.Id as LinkedDoc
		,d.TipoDoc
FROM CTL_DOC d with(nolock) 
		inner join ctl_doc I on I.id=d.LinkedDoc 
		inner join ctl_doc B on B.id=I.LinkedDoc and b.tipodoc in ('BANDO','BANDO_SDA')
		inner join aziende a  with(nolock) on d.Destinatario_Azi = a.idazi
		left outer join dm_attributi f  with(nolock) on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
where d.deleted=0 and ( d.tipoDoc like 'CONFERMA_ISCRIZIONE%'  or d.tipoDoc like 'SCARTO_ISCRIZIONE%' or d.tipoDoc like 'INTEGRA_ISCRIZIONE%' )





GO
