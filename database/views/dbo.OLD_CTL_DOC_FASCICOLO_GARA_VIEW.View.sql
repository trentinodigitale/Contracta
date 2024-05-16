USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CTL_DOC_FASCICOLO_GARA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_CTL_DOC_FASCICOLO_GARA_VIEW] as

	select
		d.* ,
		ISNULL((select TOP 1 Valore from CTL_Parametri where contesto = 'certification' and Oggetto = 'certification_req_33215'),'0') as certification_req_33215
		from ctl_doc d

GO
