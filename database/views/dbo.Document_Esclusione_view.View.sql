USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Esclusione_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Esclusione_view] as
select * , idRow as DETTAGLIGrid_ID_DOC , 'COM_ESCLUSIONE' as DETTAGLIGrid_OPEN_DOC_NAME 
from Document_Esclusione , Document_Esclusione_Fornitori
where id = idheader
GO
