USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LINKED_DOCUMENTI_INDIRETTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[LINKED_DOCUMENTI_INDIRETTI] as
--Versione=2&data=2013-12-10&Attivita=50481&Nominativo=Enrico

select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number , Fascicolo


from  
	LIB_Functions
	cross join profiliutente p
	left outer join 
		( 
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
				( 
					select Fascicolo , IdPfu as owner , cast(bread as int) as Number ,
						case cast(msgisubtype as varchar) when '-1' then '_1' else cast(msgisubtype as varchar) end as tipo 
					from MSG_LINKED_DOCUMENTI_INDIRETTI
                                        --where fascicolo='PROVV01210'
							
				) v
			group by Fascicolo , owner, tipo
			
	) as a on p.idpfu = owner and LFN_id = tipo 
	

where LFN_GroupFunction = 'LINKED_DOCUMENTI_INDIRETTI'
GO
