USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREVENTIVO_FORN_FROM_PREVENTIVO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[PREVENTIVO_FORN_FROM_PREVENTIVO]  as
SELECT  IdHeader as ID_FROM 
		,IdHeader
		,DSE_ID
		,DZT_Name
		,Value
		,IdHeader as LinkedDoc
FROM   dbo.CTL_DOC_Value where DSE_ID = 'TESTATA' and DZT_Name not in ( 'pfuNome' , 'pfuRuoloAziendale' )
union all
SELECT  distinct Id as ID_FROM 
		,Id as IdHeader
		,'DOCUMENT' as DSE_ID
		,'LinkedDoc' as DZT_Name
		,cast( Id as varchar ) as Value
		,Id as LinkedDoc
FROM   dbo.CTL_DOC

union all
SELECT  distinct Id  as ID_FROM 
		,id as IdHeader
		,'DOCUMENT' as DSE_ID
		,'Destinatario_User' as DZT_Name
		,cast( idPfu as varchar ) as Value
		,Id  as LinkedDoc
FROM   dbo.CTL_DOC


GO
