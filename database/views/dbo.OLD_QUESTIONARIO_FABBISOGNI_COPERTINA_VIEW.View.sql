USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_QUESTIONARIO_FABBISOGNI_COPERTINA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_QUESTIONARIO_FABBISOGNI_COPERTINA_VIEW] as
select
	C1.id,
	C2.Body,
	DB.IdentificativoIniziativa,
	DB.DataRiferimentoFine,
	DB.TipoBando,
	DB.DataPresentazioneRisposte,
	C1.Azienda

from ctl_doc C1 
	inner join CTL_DOC C2 on c1.LinkedDoc=C2.id --and C2.tipodoc='BANDO_FABBISOGNI'
	inner join Document_Bando DB on DB.idheader=C2.id



GO
