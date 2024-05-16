USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023_TESTATA_VIEW] as
select 
	doc.*,
	ts.Value as TipoSorteggio

	from ctl_doc doc with(nolock)
		left join  CTL_DOC_Value ts with(nolock) on ts.IdHeader = doc.id and ts.DSE_ID = 'CRITERI' and ts.DZT_Name = 'TipoSorteggio'

	where deleted = 0 and TipoDoc = 'CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023'


GO
