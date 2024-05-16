USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_PORTALE_BANDO_COLLEGATI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CHIARIMENTI_PORTALE_BANDO_COLLEGATI]  AS
	SELECT  b.id_origin,b.oggetto,b.name,b.protocollobando,b.expirydate,
	a.id,a.domanda,a.aziragionesociale,a.azitelefono1,a.azifax,
	a.azie_mail,a.protocol,a.datacreazione,a.datacreazione as datacreazione1 ,a.chiarimentoevaso,
	a.ChiarimentoPubblico,a.Notificato,a.UtenteDomanda,a.UtenteRisposta,
	
	case when a.chiarimentoevaso = 0 or a.StatoFunzionale = 'InProtocollazione' then ''
		 when a.chiarimentoevaso = 1 then a.risposta
		else a.risposta
	end  as risposta,

	case  when a.chiarimentoevaso = 0 or a.StatoFunzionale = 'InProtocollazione' then ''
		 when  a.chiarimentoevaso = 1 then a.allegato
		else a.allegato
	end  as allegato,
	case when a.StatoFunzionale = 'InProtocollazione' then NULL else a.protocolrispostaquesito end as protocolrispostaquesito,
	case when a.StatoFunzionale = 'InProtocollazione' then NULL else a.datarisposta end as datarisposta,
	--a.protocolrispostaquesito,a.datarisposta,
	a.fascicolo,a.domandaoriginale
	from document_chiarimenti a 
		right outer join CHIARIMENTI_PORTALE_FROM_BANDI b
	on a.id_origin=b.ID_ORIGIN 

	union all

	SELECT 
	a.id_origin,cast(body as nvarchar(4000)),cast(body as nvarchar(4000)) as name,Protocollo as protocollobando,datascadenza as expirydate,
	a.id,a.domanda,a.aziragionesociale,a.azitelefono1,a.azifax,
	a.azie_mail,a.protocol,a.datacreazione , a.datacreazione as datacreazione1,a.chiarimentoevaso,
	a.ChiarimentoPubblico,a.Notificato,a.UtenteDomanda,a.UtenteRisposta,
	case when a.chiarimentoevaso = 0 or a.StatoFunzionale = 'InProtocollazione' then ''
		 when a.chiarimentoevaso = 1 then a.risposta
		else a.risposta
	end  as risposta,

	case  when a.chiarimentoevaso = 0 or a.StatoFunzionale = 'InProtocollazione' then ''
		 when  a.chiarimentoevaso = 1 then a.allegato
		else a.allegato
	end  as allegato,
	case when a.StatoFunzionale = 'InProtocollazione' then NULL else a.protocolrispostaquesito end as protocolrispostaquesito,
	case when a.StatoFunzionale = 'InProtocollazione' then NULL else a.datarisposta end as datarisposta,
	--a.protocolrispostaquesito,a.datarisposta,	
	a.fascicolo,a.domandaoriginale
	from CTL_DOC b
			left join document_chiarimenti a ON a.id_origin=b.id and ISNULL(Document,'')<>''

GO
