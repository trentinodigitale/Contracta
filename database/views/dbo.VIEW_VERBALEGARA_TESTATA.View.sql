USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VERBALEGARA_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[VIEW_VERBALEGARA_TESTATA] as 

	select

		V.*,

		case 
			when ISNULL(Caption,'') <> '' then Caption
			else ML_Description 
		end as NomeDocumento

		from
			CTL_DOC  V with (nolock)
				inner join LIB_Documents with (nolock) on TipoDoc=DOC_ID
				left join LIB_Multilinguismo with (nolock) on ML_KEY = DOC_DescML and ML_LNG='I'
		where TipoDoc ='VERBALEGARA'
GO
