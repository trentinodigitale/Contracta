USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_dashboard_view_pda_elenco_comunicazioni]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_dashboard_view_pda_elenco_comunicazioni]
as
	
	-- questa query ritorna le comunicazioni (PDA_COMUNICAZIONE_GARA) inviate e non inviate 
	select 
		b.id as idPDA, x.id, x.IdPfu , 
		x.TipoDoc, x.data, x.Protocollo, 
		x.Titolo, x.Azienda, x.DataInvio,
		x.Fascicolo,x.JumpCheck,x.StatoFunzionale ,
		x.Destinatario_Azi,	aziRagioneSociale , 
		DMV_Cod as TipologiaComunicazione, x.id as iddoc,
		idazi as idAziEsecutrice,  x.tipodoc as OPEN_DOC_NAME

		from ctl_doc a with(nolock)
			inner join ctl_doc b with(nolock) on b.Deleted = 0 and b.TipoDoc   in ( 'PDA_MICROLOTTI','BANDO_GARA','BANDO_SEMPLIFICATO') and a.LinkedDoc = b.id
			inner join ctl_doc x with(nolock) on x.Deleted = 0 and x.TipoDoc  in ('PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_OFFERTA') and x.LinkedDoc = a.id 
			inner join aziende with(nolock) on idazi = x.Destinatario_Azi 
			left outer join LIB_DomainValues with(nolock) on DMV_DM_ID = 'TipologiaComunicaz' and isnull(DMV_Deleted,0) <> 1 and DMV_Cod = substring(x.JumpCheck,3,100) 
	where a.deleted=0 and a.tipodoc in ('PDA_COMUNICAZIONE_GENERICA','PDA_COMUNICAZIONE') and x.JumpCheck not in ('0-SOSPENSIONE_ALBO')
	
	union

	-- questa query ritorna le risposte alle comunicazioni (PDA_COMUNICAZIONE_RISP) con stato diverso da InLavorazione
	select 
		b.id as idPDA, y.id, y.IdPfu , 
		y.TipoDoc, y.data, y.Protocollo, 
		y.Titolo, y.Azienda, y.DataInvio,
		y.Fascicolo,y.JumpCheck,y.StatoFunzionale ,y.Destinatario_Azi,
		aziRagioneSociale , DMV_Cod as TipologiaComunicazione, 
		y.id as iddoc, idazi as idAziEsecutrice,  y.tipodoc as OPEN_DOC_NAME
				 
		from ctl_doc a
			inner join ctl_doc b on b.Deleted = 0 and b.TipoDoc  in ( 'PDA_MICROLOTTI','BANDO_GARA','BANDO_SEMPLIFICATO') and a.LinkedDoc = b.id
			inner join ctl_doc x on x.Deleted = 0 and x.TipoDoc  in ('PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_OFFERTA') and x.LinkedDoc = a.id
			inner join ctl_doc y on y.Deleted = 0 and y.TipoDoc  = 'PDA_COMUNICAZIONE_RISP' and y.LinkedDoc = x.id
			inner join aziende on idazi = y.azienda
			left outer join LIB_DomainValues on DMV_DM_ID = 'TipologiaComunicaz' and isnull(DMV_Deleted,0) <> 1 and DMV_Cod = substring(y.JumpCheck,3,100) 

	where a.deleted=0 
			and a.tipodoc in ('PDA_COMUNICAZIONE_GENERICA','PDA_COMUNICAZIONE') and x.JumpCheck not in ('0-SOSPENSIONE_ALBO')
			and y.StatoFunzionale <> 'InLavorazione'



			



GO
