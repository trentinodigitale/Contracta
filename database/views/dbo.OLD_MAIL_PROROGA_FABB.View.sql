USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_PROROGA_FABB]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_MAIL_PROROGA_FABB] AS
	SELECT 
		  C.id as iddoc,
		  'I' as LNG,
		  case when isnull(C1.Protocollo,'')='' then c2.Protocollo else c1.Protocollo end as protocollo,
	  	  C1.Body,
    	  CONVERT(VARCHAR(10), cast(CV.value as datetime),103) + ' ' + CONVERT(VARCHAR(10), cast(CV.value as datetime),108) as DataPresentazioneRisposte,
		  CV2.value as Motivazione
	from CTL_DOC C
		inner join CTL_DOC_Value CV on c.id=IdHeader and DSE_ID='TESTATA' and DZT_Name='DataPresentazioneRisposte'
		inner join CTL_DOC_Value CV2 on C.id=CV2.IdHeader and CV2.DSE_ID='TESTATA' and CV2.DZT_Name='Body'
		left join ctl_doc C1 on C1.id=C.linkeddoc 
		left join ctl_doc C2 on C2.id=C1.linkeddoc 
	where C.TipoDoc='PROROGA_FABB'

GO
