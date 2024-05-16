USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_Document_PDA_Sedute_view]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_Document_PDA_Sedute_view] as 


			select Document_PDA_Sedute.* 

				, idSeduta	 as SEDUTEGrid_ID_DOC
				, 'SEDUTA_PDA' as SEDUTEGrid_OPEN_DOC_NAME
				, StatoFunzionale as StatoFilter

			from Document_PDA_Sedute with (nolock)
				 inner join CTL_DOC with (nolock) on Id = idseduta 
GO
