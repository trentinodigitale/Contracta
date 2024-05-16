USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BOZZA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[MAIL_BOZZA] as 
select document_bozza.id as iddoc , lngSuffisso as LNG , document_bozza.*,  Document_Convenzione.DOC_Name as Oggetto
  from document_bozza , lingue, Document_Convenzione, Document_Odc
 where id_odc = rda_id
   and Document_Odc.id_convenzione = Document_Convenzione.id



GO
