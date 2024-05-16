USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_XLSX_MODELLI_ESPORTA_LISTINI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_XLSX_MODELLI_ESPORTA_LISTINI_VIEW] AS
	select attrib.idheader, attrib.Value as Attributo, descs.Value as descrizione, attrib.row as riga, 
	   --case when dzt.id is null then 0 else 1 end as dominio,
	   case when DZT_Type not in (4,5,8) then 0 else 1 end as dominio,DZT_Type,
		  isnull(dzt_dec,'') as dzt_dec, isnull(DZT_Format ,'') as DZT_Format
		from ctl_doc_value attrib with(nolock)
				inner join ctl_doc_value descs with(nolock) ON attrib.DSE_ID = descs.DSE_ID and attrib.IdHeader = descs.idheader and attrib.row = descs.row and descs.DZT_Name = 'Descrizione'
				left join LIB_Dictionary dzt with(nolock) ON dzt.DZT_Name = attrib.value --and dzt.DZT_Type in (4,5,8) -- Se l'attributo è un dominio
		where attrib.DSE_ID = 'MODELLI' and attrib.DZT_Name = 'dzt_name' and isnull(attrib.value,'') <> '' --and attrib.idheader = 65216 
	


GO
