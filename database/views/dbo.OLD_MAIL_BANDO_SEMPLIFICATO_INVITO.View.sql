USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_BANDO_SEMPLIFICATO_INVITO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[OLD_MAIL_BANDO_SEMPLIFICATO_INVITO] as
select 
     d.idRow as iddoc
	,lngSuffisso as LNG
	, isnull(convert( varchar , APS_DATE , 103 ),convert( varchar , getdate() , 103 )) as DataInvio
	, case when CT.TipoDoc='BANDO_GARA' then 'Invito' 
		when CT.TipoDoc='BANDO_ASTA' then 'Asta Elettronica' 
		else isnull( M.ML_Description , DOC_DescML ) end as TipoDoc
	, a.aziRagionesociale as RagioneSociale
	, CT.Body
	, CT.Protocollo
	, ba.ProtocolloBando
	, CT.Titolo	 
	, ba.CIG
	, convert( varchar , ba.DataScadenzaOfferta , 103 ) + ' ore ' +  convert( varchar , ba.DataScadenzaOfferta , 108 ) as  DataScadenzaOfferta
	, convert( varchar , ba.DataAperturaOfferte , 103 ) + ' ore ' +  convert( varchar , ba.DataAperturaOfferte , 108 ) as  DataAperturaOfferte
	, dbo.AF_FormatNumber( ba.ImportoBaseAsta , 3 ) as ImportoBaseAsta
	,ct.Note
	,isnull( M2.ML_Description , DMV_DescML ) as CriterioAggiudicazioneGara
	, convert( varchar , ba.DataTermineQuesiti , 103 ) + ' ore ' +  convert( varchar , ba.DataTermineQuesiti , 108 ) as  DataTermineQuesiti

	, case 
			when Ad.azivenditore <> 0 then 'Operatore Economico'
			when Ad.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario

	, case 
			when a.azivenditore <> 0 then 'Operatore Economico'
			when a.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaMittente
	  , '' as Attach_Grid

from 
CTL_DOC_DESTINATARI d
	cross join Lingue
	inner join CTL_DOC CT on d.idHeader=CT.id
	left join CTL_APPROVALSTEPS on APS_ID_DOC=CT.id and APS_DOC_TYPE= CT.Tipodoc /*'BANDO_SEMPLIFICATO'*/ and APS_STATE='Sent' and convert( nvarchar(1000) , APS_NOTE )='Creazione Inviti'
	inner join LIB_Documents on DOC_ID = CT.TipoDoc
	inner join aziende a on ct.azienda = a.idazi
	inner join document_bando ba on CT.id = ba.idheader

	--left join profiliutente p on pfuidazi = d.idpfu

	inner join aziende ad on d.idazi = ad.idazi

	left outer join LIB_Multilinguismo M on 'BANDO_SEMPLIFICATO_INVITO' = M.ML_KEY and M.ML_Context = 0 and M.ML_LNG = lngSuffisso
	left outer join LIB_DomainValues L  on 'Criterio2' = L.DMV_DM_ID and L.DMV_Cod=ba.CriterioAggiudicazioneGara
	left outer join LIB_Multilinguismo M2 on L.DMV_DescML = M2.ML_KEY and M2.ML_Context = 0 and M2.ML_LNG = lngSuffisso




GO
