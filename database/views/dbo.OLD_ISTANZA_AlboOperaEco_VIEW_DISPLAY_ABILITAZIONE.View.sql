USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW_DISPLAY_ABILITAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW_DISPLAY_ABILITAZIONE] as
	select 
		 CT.IdRow, 
		 CT.IdHeader, 
		 DSE_ID, 
		 Row, 
		 DZT_Name,
		 value
	

	from 
		CTL_DOC_VALUE CT with (nolock)
	where DSE_ID='DISPLAY_ABILITAZIONI'

union

	Select 
		IdRow,
		IdHeader,
		'DISPLAY_ABILITAZIONI' as DSE_ID,
		0 as row,
		'F2_SIGN_ATTACH' as DZT_Name,
		ISNULL(F2_SIGN_ATTACH,'') as value
	from 
		CTL_DOC_SIGN with (nolock)

union

	Select 
		DB.IdRow,
		id as idheader,
		'DISPLAY_ABILITAZIONI' as DSE_ID,
		0 as row,
		'ClasseIscriz_Bando' as DZT_Name,
		--ClasseIscriz as value
		case
			when ISNULL(value,ClasseIscriz) = '###' + C.DMV_Cod + '###' then ''
			else ISNULL(value,ClasseIscriz) 
		end as value
	from
		ctl_doc with (nolock)
			inner join document_bando DB with (nolock) on DB.idheader=LinkedDoc
			left join CTL_DOC_Value CV with (nolock)on CV.idHeader=LinkedDoc and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz_MENO_Revocate'
			cross  join (select top 1 * from ClasseIscriz with (nolock) where DMV_Deleted=0 order by len (dmv_father) ) C
	where tipodoc like 'ISTANZA_Albo%' 




GO
