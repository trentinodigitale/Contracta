USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LINKED_CONSULTAZIONE_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[LINKED_CONSULTAZIONE_BANDO] as


select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number , Fascicolo


from  
	LIB_Functions with (nolock)
	cross join profiliutente p with (nolock)
	left outer join 
		( 			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( 
				select 
						Fascicolo , 
						IdPfu as owner , 
						cast(bread as int) as Number ,
						DocType as tipo 
				from MSG_LINKED_CONSULTAZIONE_BANDO  with (nolock)
		   	)v
		group by Fascicolo , owner, tipo
	   )as a on p.idpfu = owner and LFN_id = tipo 
where LFN_GroupFunction = 'LINKED_CONSULTAZIONE_BANDO'		

GO
