USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_ANOMALIE_PRODOTTI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OFFERTA_ANOMALIE_PRODOTTI_TESTATA_VIEW]  AS
select 
	C.* ,
	ISNULL(CV.Value,'') as EsitoRiga
	from ctl_doc C with(nolock) 
			left join CTL_DOC_Value CV with(nolock) on CV.IdHeader=C.Id and CV.DSE_ID='TESTATA' and CV.DZT_Name='EsitoRiga' and CV.Row=0
		where C.TipoDoc='OFFERTA_ANOMALIE_PRODOTTI'
GO
