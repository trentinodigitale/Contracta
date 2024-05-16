USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SUB_QUESTIONARIO_FABBISOGNI_COPERTINA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SUB_QUESTIONARIO_FABBISOGNI_COPERTINA_VIEW] as
select
	C1.id,
	C2.Body,
	DB.IdentificativoIniziativa,
	CONVERT(nvarchar(30), value, 126) as DataPresentazioneRisposte,
	DB.TipoBando,
	C1.azienda

from ctl_doc C1 
	inner join CTL_DOC CQ on c1.LinkedDoc=CQ.id and CQ.tipodoc='QUESTIONARIO_FABBISOGNI'
	inner join ctl_doc_value CV on CV.idheader=CQ.id and DSE_ID='TESTATA_SUB_QUESTIONARI' and Dzt_name='DataScadenzaIstanza'
	inner join CTL_DOC C2 on cQ.LinkedDoc=C2.id and C2.tipodoc='BANDO_FABBISOGNI'
	inner join Document_Bando DB on DB.idheader=C2.id

GO
