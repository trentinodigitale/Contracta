USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SDA_Categorie_Merceologiche_SELECTED]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_SDA_Categorie_Merceologiche_SELECTED] as
 
	select C.DMV_COD ,V.idheader
		from Categorie_Merceologiche C
		inner join Categorie_Merceologiche M on  Left(M.dmv_father,len(C.dmv_father)) = C.DMV_Father 
		inner join ctl_doc_value V on DSE_ID = 'TESTATA_PRODOTTI' and dzt_name= 'Categorie_Merceologiche' and V.Value like  '%###' + M.DMV_Cod + '###%'

GO
