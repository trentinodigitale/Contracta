USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ISTANZA_AlboProf_3_XLS_ESTRACT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_ISTANZA_AlboProf_3_XLS_ESTRACT] AS
select 
	idheader as ID,
	idheader,
	tipodoc,
	dbo.[Get_Desc_TipologiaIncarico] (items,'I') as AttivitaProfessionaleIstanza
	from CTL_DOC_Value CV  with(nolock) 
		inner join CTL_DOC with(nolock)  on IdHeader=id		
	    cross apply dbo.Split (cv.value, '###') spl
	where DSE_ID='DICHIARAZIONI'  and DZT_Name='AttivitaProfessionaleIstanza' 
GO
