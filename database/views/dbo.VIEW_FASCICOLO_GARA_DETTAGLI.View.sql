USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_FASCICOLO_GARA_DETTAGLI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[VIEW_FASCICOLO_GARA_DETTAGLI] as

	select 
		DF.*
		, DF.Tipodoc as OPEN_DOC_NAME
		, path
		, DF.Tipodoc as TipoDocBando
		from
			Document_Fascicolo_Gara_Documenti DF with (nolock)
			--andiamo in jioin sui path degli allegati dei documenti (max path)
			inner join
						(	
							select 
								idheader,iddoc,MAX(path) as path 
									from 
										Document_Fascicolo_Gara_Allegati with (nolock)  
										group by idheader,iddoc 
						) Doc_Order_Path on Doc_Order_Path.IdHeader = DF.IdHeader and DF.IdDoc = 	Doc_Order_Path.iddoc
GO
