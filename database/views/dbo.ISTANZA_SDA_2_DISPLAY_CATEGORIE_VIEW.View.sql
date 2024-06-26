USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_SDA_2_DISPLAY_CATEGORIE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from CTL_DOC_Value where IdHeader=306237 and DSE_ID='DISPLAY_CATEGORIE'

CREATE VIEW [dbo].[ISTANZA_SDA_2_DISPLAY_CATEGORIE_VIEW] as
	
	select 
	 IdRow, 
	 IdHeader, 
	 DSE_ID, 
	 Row, 
	 DZT_Name, 
	 value
		from CTL_DOC_VALUE with(nolock)

	union

	select 
		cv.IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'elenco_categorie_sda' as DZT_Name,
		 ISNULL(cv.value,'') as value
		
	from ctl_doc c with(nolock)
		--SE NON E' STATO GIA' SALVATO SUL DOCUMENTO ISTANZA, SERVE SOLO LA PRIMA VOLTA
		left join CTL_DOC_Value ISt with(nolock)  on c.id=ISt.idHeader and ISt.DSE_ID='DISPLAY_CATEGORIE' and ISt.DZT_Name='Categorie_Merceologiche'
		inner join CTL_DOC_Value CV with(nolock) on c.linkedDoc=CV.idHeader and CV.DSE_ID='TESTATA_PRODOTTI' and CV.DZT_Name='Categorie_Merceologiche' and ISt.IdHeader IS NULL		
	where c.TipoDoc like 'ISTANZA_SDA%' and ISt.IdHeader IS NULL

	union

	select 
		cv2.IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'Elenco_Categorie_Merceologiche' as DZT_Name,
		 ISNULL(cv2.value,'') as value
		
	from ctl_doc c		with(nolock)
		--SE NON E' STATO GIA' SALVATO SUL DOCUMENTO ISTANZA, SERVE SOLO LA PRIMA VOLTA
		left join CTL_DOC_Value ISt with(nolock)  on c.id=ISt.idHeader and ISt.DSE_ID='DISPLAY_CATEGORIE' and ISt.DZT_Name='Elenco_Categorie_Merceologiche'
		inner join CTL_DOC_Value CV2 with(nolock) on c.linkedDoc=CV2.idHeader and CV2.DSE_ID='TESTATA_PRODOTTI' and CV2.DZT_Name='Elenco_Categorie_Merceologiche'	and ISt.IdHeader IS NULL	
	where c.TipoDoc like 'ISTANZA_SDA%' and ISt.IdHeader IS NULL

	union

	select 
		cv3.IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'Livello_Categorie_Merceologiche' as DZT_Name,
		 ISNULL(cv3.value,'') as value
		
	from ctl_doc c with(nolock)
		--SE NON E' STATO GIA' SALVATO SUL DOCUMENTO ISTANZA, SERVE SOLO LA PRIMA VOLTA
		left join CTL_DOC_Value ISt with(nolock)  on c.id=ISt.idHeader and ISt.DSE_ID='DISPLAY_CATEGORIE' and ISt.DZT_Name='Livello_Categorie_Merceologiche'
		inner join CTL_DOC_Value CV3 with(nolock) on c.linkedDoc=CV3.idHeader and CV3.DSE_ID='TESTATA_PRODOTTI' and CV3.DZT_Name='Livello_Categorie_Merceologiche' and ISt.IdHeader IS NULL
	where c.TipoDoc like 'ISTANZA_SDA%' and ISt.IdHeader IS NULL

	union

	select 
		CV.IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'Richiesta_Info' as DZT_Name,
		 ISNULL(CV.value,'') as value
		
	from ctl_doc c with(nolock)
		--SE NON E' STATO GIA' SALVATO SUL DOCUMENTO ISTANZA, SERVE SOLO LA PRIMA VOLTA
		left join CTL_DOC_Value ISt with(nolock)  on c.id=ISt.idHeader and ISt.DSE_ID='DISPLAY_CATEGORIE' and ISt.DZT_Name='Richiesta_Info'
		inner join CTL_DOC_Value CV with(nolock) on c.linkedDoc=CV.idHeader and CV.DSE_ID='TESTATA_PRODOTTI' and CV.DZT_Name='Richiesta_Info' and ISt.IdHeader IS NULL
	where c.TipoDoc like 'ISTANZA_SDA%' and ISt.IdHeader IS NULL
GO
