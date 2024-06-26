USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_SDA_2_DISPLAY_CATEGORIE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_ISTANZA_SDA_2_DISPLAY_CATEGORIE_VIEW] as
	
	select 
	 IdRow, 
	 IdHeader, 
	 DSE_ID, 
	 Row, 
	 DZT_Name, 
	 value
		from CTL_DOC_VALUE

	union

	select 
		IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'elenco_categorie_sda' as DZT_Name,
		 ISNULL(value,'') as value
		
	from ctl_doc c
		left join CTL_DOC_Value CV on c.linkedDoc=CV.idHeader and CV.DSE_ID='TESTATA_PRODOTTI' and CV.DZT_Name='Categorie_Merceologiche'
	where c.TipoDoc like 'ISTANZA_SDA%'

	union

	select 
		IdRow,
		C.id as idheader,
		'DISPLAY_CATEGORIE' as DSE_ID,
		0 as Row,
		'Richiesta_Info' as DZT_Name,
		 ISNULL(value,'') as value
		
	from ctl_doc c
		left join CTL_DOC_Value CV on c.linkedDoc=CV.idHeader and CV.DSE_ID='TESTATA_PRODOTTI' and CV.DZT_Name='Richiesta_Info'
	where c.TipoDoc like 'ISTANZA_SDA%'

GO
