USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_GRIGLIA_CATEGORIE_FROMADD_CATEGORIE_MERCEOLOGICHE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_GRIGLIA_CATEGORIE_FROMADD_CATEGORIE_MERCEOLOGICHE] as
select 

	id as indRow,
	CLASS.items as Categoria_Merceologica
		
from
ctl_doc C
inner join ctl_doc_value cv on cv.IdHeader=C.Id and DSE_ID='DISPLAY_CATEGORIE' and DZT_Name='Categorie_Merceologiche'
cross apply ( select items from dbo.Split(cv.value,'###') ) as CLASS
where C.TipoDoc like 'ISTANZA_SDA%'

GO
