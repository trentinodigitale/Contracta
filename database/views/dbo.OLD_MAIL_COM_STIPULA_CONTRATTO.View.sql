USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_COM_STIPULA_CONTRATTO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_MAIL_COM_STIPULA_CONTRATTO] AS
select 
    idrow as iddoc
	, lngSuffisso as LNG
	, a.aziRagionesociale as RagioneSocialeDest
	, isnull(AC.aziRagionesociale,'') as RagioneSociale
	, convert( varchar , DF.DataInvioStipula , 103 ) as DataInvio
	, convert( varchar , DF.DataInvioStipula , 108 ) as OraInvio
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	, 'COM_STIPULA_CONTRATTO' as TipoDocumento
    , D.TitoloStipula as Titolo
    , DF.ProtocolloStipula as Protocollo
    , D.Oggetto as body
    , PC.pfunome
    , PC.pfue_mail
    , AC.aziragionesociale as RagioneSocialeMitt
    , p.pfunome as pfuNomeDest
	, p.pfue_mail as pfue_mailDest
	, D.Protocol

	, case 
			when A.azivenditore <> 0 then 'Operatore Economico'
			when A.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario

	, case 
			when AC.azivenditore <> 0 then 'Operatore Economico'
			when AC.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaMittente
	, '' as Attach_Grid


 from 
	
	Document_EsitoGara D inner join 
	Document_EsitoGara_Fornitori DF on D.id=DF.idheader
	cross join Lingue
	left join aziende a on a.idazi = DF.fornitore
	left join profiliutente p on p.pfuidazi = DF.fornitore
	inner join LIB_Documents on DOC_ID = 'COM_STIPULA_CONTRATTO'
	left outer join LIB_Multilinguismo on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	left join profiliutente PC on D.Idpfu=PC.idpfu
	left join aziende AC on AC.idazi=PC.pfuidazi
	

GO
