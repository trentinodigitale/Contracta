USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_domain_codici_ipa]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_domain_codici_ipa]
AS
	SELECT  
				'CODICI_IPA' AS DMV_DM_ID, 
				cod_uni_ou as DMV_Cod, 
				idazi AS DMV_Father, 
				1 AS DMV_Level, 
				des_ou as DMV_DescML,
				'node.gif' AS DMV_Image, 
				0 AS DMV_Sort, 
				cod_uni_ou as DMV_CodExt
		FROM         AZIENDE_CODICI_IPA
	


GO
