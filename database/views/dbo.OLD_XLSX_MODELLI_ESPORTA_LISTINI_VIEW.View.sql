USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_XLSX_MODELLI_ESPORTA_LISTINI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_XLSX_MODELLI_ESPORTA_LISTINI_VIEW] AS
	select 
		attrib.idheader, 
		--attrib.Value as Attributo, 
		case
			when extra1.value = attrib.Value then 'Qty'
			when extra2.value = attrib.Value then 'ValoreEconomico'
			when extra3.value = attrib.Value then 'ValoreAccessorioTecnico'
			else attrib.Value
		end as Attributo,
		descs.Value as descrizione, 
		attrib.row as riga, 
	   --case when dzt.id is null then 0 else 1 end as dominio,
	   case 
			when DZT_Type not in (4,5,8) then 0 
			else 1 
		end as dominio,DZT_Type,
		isnull(dzt_dec,'') as dzt_dec, 
		isnull(DZT_Format ,'') as DZT_Format
		
		from ctl_doc_value attrib with(nolock)
			inner join ctl_doc_value descs with(nolock) ON attrib.DSE_ID = descs.DSE_ID and attrib.IdHeader = descs.idheader and attrib.row = descs.row and descs.DZT_Name = 'Descrizione'
			left join LIB_Dictionary dzt with(nolock) ON dzt.DZT_Name = attrib.value --and dzt.DZT_Type in (4,5,8) -- Se l'attributo è un dominio

			left join ctl_doc_value extra1 with(nolock) on extra1.idheader = attrib.IdHeader and extra1.dse_id='EXTRA' and extra1.dzt_name='DZT_NAME_QTY'
			left join ctl_doc_value extra2 with(nolock) on extra2.idheader = attrib.IdHeader and extra2.dse_id='EXTRA' and extra2.dzt_name='DZT_NAME_PRZ'
			left join ctl_doc_value extra3 with(nolock) on extra3.idheader = attrib.IdHeader and extra3.dse_id='EXTRA' and extra3.dzt_name='DZT_NAME_VALACC'

		where attrib.DSE_ID = 'MODELLI' and attrib.DZT_Name = 'dzt_name' and isnull(attrib.value,'') <> '' --and attrib.idheader = 65216 
	

GO
