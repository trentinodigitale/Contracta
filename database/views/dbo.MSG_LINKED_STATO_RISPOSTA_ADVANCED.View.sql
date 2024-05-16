USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_STATO_RISPOSTA_ADVANCED]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Versione=2&data=2013-10-29&Attivita=48328&Nominativo=Enrico
CREATE VIEW [dbo].[MSG_LINKED_STATO_RISPOSTA_ADVANCED] AS
select 
	--distinct LASTDOC.protocolbg as fascicolo
	distinct LASTDOC.IdDocSource as IdDocSource
	,case isnull(StatoCollegati,'')
		when '' then
			case LASTDOC.advancedstate
				when 2 then 'Rejected'
				else
					case LASTDOC.stato
						WHEN 1 THEN 'Saved'
						WHEN 4 THEN 'Invalidate'
					end
			end
		else StatoCollegati	
	  end as OpenOfferte
	,coalesce(IdPfu,umidpfu) as IdPfu

from 		
	
	(
--	SELECT distinct
--		idmsg
--		,ProtocolBg
--		,stato,advancedstate	
--		,'Sended' as StatoCollegati
--		,umIdPfu AS IdPfu
--
--	FROM 
--		TAB_MESSAGGI_FIELDS inner join TAB_UTENTI_MESSAGGI on	IdMsg = umIdMsg
--		
--	WHERE 
--		itype=55
--		and isubtype IN (27,54,70,38,186)
--		and stato=2 and (advancedstate='' or advancedstate='0')
--		and uminput=0

	SELECT distinct
		idmsg
		--,ProtocolBg
		,mffieldvalue as IdDocSource
		,stato,advancedstate	
		,'Sended' as StatoCollegati
		,umIdPfu AS IdPfu
		
--select * from documentfields where dfisubtype in (27,54,70,38,186)


	FROM 
		--TAB_MESSAGGI_FIELDS inner join TAB_UTENTI_MESSAGGI on	IdMsg = umIdMsg
		--inner join MESSAGEFIELDS on umIdMsg=mfidmsg
		TAB_MESSAGGI_FIELDS,TAB_UTENTI_MESSAGGI,MESSAGEFIELDS 
	WHERE 
		IdMsg = umIdMsg
		and umIdMsg=mfidmsg
		and itype=55
		and isubtype IN (27,54,70,38,186)
		and stato=2 and (advancedstate='' or advancedstate='0')
		and uminput=0
		--AND mfisubtype in (27,54,70,38,186) 
		--AND mffieldname in ('IdDoc_Bando','IdDoc_BG','IdDoc_BGLP','IdDoc_IN','IdDoc_PE')
		AND 
			mfitype=55
		AND 
			(	( mffieldname ='IdDoc_Bando' and mfisubtype='186')
			 or
				( mffieldname ='IdDoc_BG' and mfisubtype='27')
			 or
				( mffieldname in ('IdDoc_BGLP','IdDoc_IN') and mfisubtype='38')
			 or
				( mffieldname ='IdDoc_IN' and mfisubtype='54')
			 or
				( mffieldname ='IdDoc_PE' and mfisubtype='70')
			)

	) DOCINV
	RIGHT OUTER JOIN (
		select umidpfu,TMF.idmsg,TMF.ProtocolBg	,TMF.stato,TMF.advancedstate,V.IdDocSource from 
			tab_messaggi_fields TMF,
			(
--				select max( IdMsg ) as idmsg ,protocolbg,umidpfu
--				FROM TAB_MESSAGGI_FIELDS
--				, TAB_UTENTI_MESSAGGI
--				WHERE 
--					IdMsg = umIdMsg
--					AND Itype = 55
--					and isubtype IN (27,54,70,38,186)
--					AND umInput = 0
--					AND umstato=0
--				group by protocolbg,umidpfu
				
				select 
					max(mfidmsg) as idmsg, mffieldvalue as IdDocSource, umidpfu
				from 
					MESSAGEFIELDS with(nolock) 
					inner join TAB_UTENTI_MESSAGGI with(nolock) on umidmsg=mfidmsg
				where 
					 --mfitype=55 AND mfisubtype in (27,54,70,38,186) AND mffieldname in ('IdDoc_Bando','IdDoc_BG','IdDoc_BGLP','IdDoc_IN','IdDoc_PE')
					mfitype=55
					AND 
					(	( mffieldname ='IdDoc_Bando' and mfisubtype='186')
					 or
						( mffieldname ='IdDoc_BG' and mfisubtype='27')
					 or
						( mffieldname in ('IdDoc_BGLP','IdDoc_IN') and mfisubtype='38')
					 or
						( mffieldname ='IdDoc_IN' and mfisubtype='54')
					 or
						( mffieldname ='IdDoc_PE' and mfisubtype='70')
					)
					AND umInput = 0 AND umstato=0

				group by mffieldvalue,umidpfu
			
			) V where TMF.idmsg=V.idmsg 

		--) LASTDOC ON DOCINV.ProtocolBg = LASTDOC.ProtocolBg and DOCINV.IdPfu = LASTDOC.umidpfu
		  ) LASTDOC ON DOCINV.IdDocSource = LASTDOC.IdDocSource and DOCINV.IdPfu = LASTDOC.umidpfu



GO
