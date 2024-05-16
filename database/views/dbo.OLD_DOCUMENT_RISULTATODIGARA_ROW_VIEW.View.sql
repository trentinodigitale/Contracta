USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_RISULTATODIGARA_ROW_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE VIEW [dbo].[OLD_DOCUMENT_RISULTATODIGARA_ROW_VIEW] as 

 select
	C.linkeddoc as leg,
	case when C.JumpCheck='DOC_GEN' then C.linkeddoc*-1 else C.linkeddoc end as ID_MSG_BANDO,
	tipodoc as OPEN_DOC_NAME, 
	1 as OPEN_DOC,
	ISNULL(c.id,0) as idRow,
    DR.idHeader, 
	CV.value as Precisazione, 
	CV2.value as Allegato, 
	DR.Versione, 
	ISNULL(DR.DataIns,C.datainvio) as  DataIns,
	DR.DescrizioneVer, 
	C.Idpfu, 
	CV3.value as TipoDocumentoEsito, 
	C.Protocollo,
	C.StatoFunzionale,
	DR.idRow as idRowPrincipale

from 
ctl_doc C
	left join CTL_DOC_Value CV on  CV.IdHeader=C.id and CV.DSE_ID='TESTATA' and CV.DZT_Name='Precisazione'
	left join CTL_DOC_Value CV2 on  CV2.IdHeader=C.id and CV2.DSE_ID='TESTATA' and CV2.DZT_Name='DocumentoAllegato'
	left join CTL_DOC_Value CV3 on  CV3.IdHeader=C.id and CV3.DSE_ID='TESTATA' and CV3.DZT_Name='TipoDocumentoEsito'
	left join DOCUMENT_RISULTATODIGARA D on -C.LinkedDoc=ID_MSG_BANDO
	Left join Document_RisultatoDiGara_Row DR on D.id=DR.idHeader and C.Protocollo=DR.Protocollo 
where C.Tipodoc='NEW_RISULTATODIGARA' 

union 
	
	
 select
	ID_MSG_BANDO*-1 as leg,
	ID_MSG_BANDO,
	'' as OPEN_DOC_NAME, 
	1 as OPEN_DOC,
	0 as idRow,
    DR.idHeader, 
	DR.Precisazione, 
	DR.Allegato, 
	DR.Versione, 
	DR.DataIns, 
	DR.DescrizioneVer, 
	NULL as Idpfu, 
	DR.TipoDocumentoEsito, 
	DR.Protocollo,
	case when dr.Deleted = 1 then 'Annullato' else 'Inviato' end as   StatoFunzionale,
	DR.idRow as idRowPrincipale

from DOCUMENT_RISULTATODIGARA
inner join Document_RisultatoDiGara_Row DR on id=DR.idHeader and ISNULL(DR.Protocollo ,'')=''




GO
