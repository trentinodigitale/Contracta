USE [AFLink_TND]
GO
/****** Object:  View [dbo].[dashboard_view_bando_conversazione]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[dashboard_view_bando_conversazione]
as
	
	-- questa query ritorna i figli diretti del bando (risposte alla consultazione)
	select b.id as idPDA, a.id, a.IdPfu , a.TipoDoc, a.data, a.Protocollo, a.Titolo, a.Azienda, a.DataInvio,a.Fascicolo,a.StatoFunzionale ,a.Destinatario_Azi,
			aziRagioneSociale ,a.id as iddoc, idazi as idAziEsecutrice,  a.tipodoc as OPEN_DOC_NAME, a.JumpCheck

			from ctl_doc a
		inner join ctl_doc b on b.Deleted = 0 and b.TipoDoc  = 'BANDO_CONSULTAZIONE' and a.LinkedDoc = b.id
		--inner join ctl_doc x on x.Deleted = 0 and x.TipoDoc  in ('PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_OFFERTA') and x.LinkedDoc = a.id 
		inner join aziende on idazi = a.azienda
		--left outer join LIB_DomainValues on DMV_DM_ID = 'TipologiaComunicaz' and isnull(DMV_Deleted,0) <> 1 and DMV_Cod = substring(x.JumpCheck,3,100) 

	where a.deleted=0 
			and a.tipodoc in ('RISPOSTA_CONSULTAZIONE')
			and a.StatoDoc <> 'Saved'
	
	union

	-- questa query ritorna i figli dei figli del bando (PDA_COMUNICAZIONE_GARA)
	select b.id as idPDA, x.id, x.IdPfu , x.TipoDoc, x.data, x.Protocollo, x.Titolo, x.Azienda, x.DataInvio,x.Fascicolo,x.StatoFunzionale ,x.Destinatario_Azi,
			aziRagioneSociale ,x.id as iddoc, idazi as idAziEsecutrice,  x.tipodoc as OPEN_DOC_NAME, x.JumpCheck

			from ctl_doc a
		inner join ctl_doc b on b.Deleted = 0 and b.TipoDoc  = 'BANDO_CONSULTAZIONE' and a.LinkedDoc = b.id
		inner join ctl_doc x on x.Deleted = 0 and x.TipoDoc  in ('PDA_COMUNICAZIONE_GARA') and x.LinkedDoc = a.id 
		inner join aziende on idazi = x.Destinatario_Azi 
		--left outer join LIB_DomainValues on DMV_DM_ID = 'TipologiaComunicaz' and isnull(DMV_Deleted,0) <> 1 and DMV_Cod = substring(x.JumpCheck,3,100) 

	where a.deleted=0 
			and a.tipodoc in ('PDA_COMUNICAZIONE_GENERICA','PDA_COMUNICAZIONE','RISPOSTA_CONSULTAZIONE')
			and a.StatoDoc <> 'Saved'

	
	union

	-- questa query ritorna le risposte alle comunicazioni (PDA_COMUNICAZIONE_RISP) con stato diverso da InLavorazione
	select b.id as idPDA, y.id, y.IdPfu , y.TipoDoc, y.data, y.Protocollo, y.Titolo, y.Azienda, y.DataInvio,y.Fascicolo,y.StatoFunzionale ,y.Destinatario_Azi,
			aziRagioneSociale ,  y.id as iddoc, idazi as idAziEsecutrice,  y.tipodoc as OPEN_DOC_NAME, y.JumpCheck
				 
			from ctl_doc a
		inner join ctl_doc b on b.Deleted = 0 and b.TipoDoc  = 'BANDO_CONSULTAZIONE' and a.LinkedDoc = b.id
		inner join ctl_doc x on x.Deleted = 0 and x.TipoDoc  in ('PDA_COMUNICAZIONE_GARA') and x.LinkedDoc = a.id
		inner join ctl_doc y on y.Deleted = 0 and y.TipoDoc  = 'PDA_COMUNICAZIONE_RISP' and y.LinkedDoc = x.id
		inner join aziende on idazi = y.azienda
		--left outer join LIB_DomainValues on DMV_DM_ID = 'TipologiaComunicaz' and isnull(DMV_Deleted,0) <> 1 and DMV_Cod = substring(y.JumpCheck,3,100) 

	where a.deleted=0 
			and a.tipodoc in ('PDA_COMUNICAZIONE_GENERICA','PDA_COMUNICAZIONE','RISPOSTA_CONSULTAZIONE')
			and a.StatoDoc <> 'Saved'
			and y.StatoDoc <> 'Saved'




GO
