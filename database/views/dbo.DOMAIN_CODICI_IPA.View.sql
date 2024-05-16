USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMAIN_CODICI_IPA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[DOMAIN_CODICI_IPA]
AS
	SELECT  
				'CODICI_IPA' AS DMV_DM_ID, 
				cod_uni_ou as DMV_Cod, 
				idazi AS DMV_Father, 
				1 AS DMV_Level, 
				des_ou as DMV_DescML,
				'node.gif' AS DMV_Image, 
				0 AS DMV_Sort, 
				cod_uni_ou as DMV_CodExt,
				isnull(deleted,0) as DMV_DELETED
		FROM         AZIENDE_CODICI_IPA

		where deleted=0

	


GO
