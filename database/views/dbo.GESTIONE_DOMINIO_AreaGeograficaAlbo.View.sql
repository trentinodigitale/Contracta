USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GESTIONE_DOMINIO_AreaGeograficaAlbo]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GESTIONE_DOMINIO_AreaGeograficaAlbo] as
--"Zone Geografica di Operatività" utilizzando il dominio GEO fino al livello regione per l'italia e stato per le altre nazioni
select  
	15 as DMV_DM_ID  ,  
	DMV_Cod , 
	DMV_Father ,   
	DMV_Level ,
    --cast ( isnull( m1.ML_Description,DMV_DescML)  as nvarchar(max)) as DMV_DescML,
    DMV_DescML,
	case when charindex('folder.gif',DMV_Image)>0 then 'folder.gif'
	else 'node.gif' end as     DMV_Image ,  
    DMV_Sort ,   
	DMV_CodExt
   from LIB_DomainValues
		--left outer join LIB_Multilinguismo m1 on DMV_DescML=m1.ML_KEY and m1.ML_LNG ='#LNG#'
      where DMV_DM_ID='GEO' and ( ( DMV_Level <=5 and left(DMV_Father,11) = 'M-1-11-ITA-' ) or ( DMV_Level <=3 and left(DMV_Father,11) <> 'M-1-11-ITA-' ) )
   --order by DMV_Father

GO
