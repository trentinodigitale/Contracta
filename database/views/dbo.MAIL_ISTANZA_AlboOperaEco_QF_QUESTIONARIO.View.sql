USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ISTANZA_AlboOperaEco_QF_QUESTIONARIO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW[dbo].[MAIL_ISTANZA_AlboOperaEco_QF_QUESTIONARIO] AS
SELECT a.Id AS IdDoc
     , lngSuffisso AS LNG
	, a.protocollo
    , a.titolo
    --, a.data

	,convert(varchar(10),a.data,103) + ' ' + convert(varchar(8),a.data,114) as data

    , a.tipodoc    
    ,case when ML_Description is null then dmv_descml else ML_Description end as AreaValutazioneDescr,
    aziragionesociale,
	x.body as NomeBando
  FROM dbo.ctl_doc a
        cross join Lingue
    	inner join  aziende on idazi=azienda
    	inner join document_istanza_albooperaeco_datiazi on idheader=a.id
    	inner join lib_domainvalues on dmv_dm_id='AreaValutazione' and dmv_cod=areavalutazione
    	left outer join dbo.LIB_Multilinguismo on ML_KEY=dmv_descml and ML_LNG=lngSuffisso
		left outer join ctl_doc x on a.linkeddoc=x.id
WHERE lngDeleted = 0
and a.deleted=0






GO
