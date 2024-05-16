USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PUBB_BANDO_CONSULTAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_PUBB_BANDO_CONSULTAZIONE] as
select 

		id,
		IdPfu,
		-1 as msgIType,
		-1 as msgIsubType,
		titolo as Name,
		'' as bread,
		ProtocolloGenerale ,
		Protocollo as ProtocolloBando,
		Protocollo as ProtocolloOfferta,
		DataScadenzaOfferta as ReceidevDataMsg,
			case
				 when statofunzionale = 'revocato' then '<strong>Bando Revocato - </strong> ' + cast(Body as nvarchar (2000)) 
				 when statofunzionale = 'InRettifica' then '<strong>Bando In Rettifica - </strong> ' + cast(Body as nvarchar (2000)) 
			else
				case when isnull(v.linkeddoc,0) > 0
					 then '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end				
			end as Oggetto,		
		DataScadenzaOfferta AS ExpiryDate,		
		Fascicolo,		
		'1' as OpenDettaglio
		,CASE 
			WHEN DataScadenzaOfferta is null THEN '0'
			WHEN isnull(DataScadenzaOfferta,convert(varchar(19), GETDATE(),126)) > convert(varchar(19), GETDATE(),126) THEN '0'
			ELSE '1'
		  END AS Scaduto		
		,'BANDO_CONSULTAZIONE' as OPEN_DOC_NAME 
		,StatoFunzionale
		,az.AziRagioneSociale AS EnteAppaltante 
		,	CASE 
				WHEN Dr.leg IS NULL THEN 0 
				ELSE 1 
			END AS Precisazioni
		,CASE WHEN DR.leg IS NULL THEN 0 
				ELSE DR.leg 
			END AS IDDOCR 
	from CTL_DOC
		inner join dbo.Document_Bando on id = idheader
		left  join (Select distinct(linkedDoc) from ctl_doc where tipodoc IN ('RETTIFICA_CONSULTAZIONE','PROROGA_CONSULTAZIONE') and statofunzionale = 'Approved' ) V on V.LinkedDoc=CTL_DOC.id
		inner join aziende az  WITH(NOLOCK) on az.idazi=Azienda   ---per recuperare l'enteAppaltante
		left outer join
			(
				select distinct leg
					from
						DOCUMENT_RISULTATODIGARA_ROW_VIEW
						where 
						  StatoFunzionale='Inviato' and TipoDoc_src not in ('DOC_GEN','')			
									
			) DR on DR.leg=id 
	where TipoDoc='BANDO_CONSULTAZIONE' 
		and StatoFunzionale in ( 'Pubblicato' , 'InRettifica' ,'Chiuso','Revocato')
		and deleted=0







GO
