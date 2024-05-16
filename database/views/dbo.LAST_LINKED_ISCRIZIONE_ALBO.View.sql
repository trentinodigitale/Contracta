USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LAST_LINKED_ISCRIZIONE_ALBO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[LAST_LINKED_ISCRIZIONE_ALBO] as
select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number , Fascicolo


from  
	LIB_Functions
	cross join profiliutente p
	left outer join 
		( 
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '11' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 11) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '12_177' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 12,177)) v
			group by Fascicolo , owner, tipo

			union all
			--select Fascicolo , IdPfu as owner , count(*) as Number , '15' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype in ( 15) group by IdPfu ,Fascicolo
			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '17' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype in ( 17) group by IdPfu ,Fascicolo
			--union 
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '31_40_90_93' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 31,40,90,93,15,17)) v
			group by Fascicolo , owner, tipo

			union all
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '25' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 25) v
			group by Fascicolo , owner, tipo
			union all

			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			(		select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '_1' as tipo 
					from MSG_LINKED_ISCRIZIONE_ALBO 
					where msgisubtype = -1
			
					union all
			
					select Fascicolo , idpfu as owner , cast(bread as int) as Number , '_1' as tipo 
					from MSG_LINKED_ISCRIZIONE_ALBO
					where DocType='DETAIL_CHIARIMENTI'
			
				
			) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '3' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 3) v
			group by Fascicolo , owner, tipo

			union all

			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '27' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 27) v
			group by Fascicolo , owner, tipo			

			union all 
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '138_143_145_147_148' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 138,143,145,147,148)) v
			group by Fascicolo , owner, tipo
			
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '153_154_157_158' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 153, 154,157,158 )) v
			group by Fascicolo , owner, tipo

			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '154' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 154 group by IdPfu ,Fascicolo
			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '157' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 157 group by IdPfu ,Fascicolo
			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '158' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 158 group by IdPfu ,Fascicolo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '176' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 176) v
			group by Fascicolo , owner, tipo

			union all
			

			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '37' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 37) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '44_122' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 44,122 )) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '47_125' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 47,125)) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '22' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 22) v
			group by Fascicolo , owner, tipo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '21' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 21) v
			group by Fascicolo , owner, tipo
			
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '109_110_117_119_129_130_121_182' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 109,110,117,119,129,130,121,182 )) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '38' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 38) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '113_114_134_135' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 113,114,134,135 )) v
			group by Fascicolo , owner, tipo

			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '114' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 114 group by IdPfu ,Fascicolo
			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '134' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 134 group by IdPfu ,Fascicolo
			--union 
			--select Fascicolo , IdPfu as owner , count(*) as Number , '135' as tipo from MSG_LINKED_ISCRIZIONE_ALBO where msgisubtype = 135 group by IdPfu ,Fascicolo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '162' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 162) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '64' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 64) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '165' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 165) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '49' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 49) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '50' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 50) v
			group by Fascicolo , owner, tipo

			union all 
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '53' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 53) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '54' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 54) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '97_84_99_184' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype in ( 97,84,99,184)) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '79' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 79) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '80' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 80) v
			group by Fascicolo , owner, tipo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '103' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 103) v
			group by Fascicolo , owner, tipo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '87' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 87) v
			group by Fascicolo , owner, tipo
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '88' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 88) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '82' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 82) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '69' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 69) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '70' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 70) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '73' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 73) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '75' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 75) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '105' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 105) v
			group by Fascicolo , owner, tipo

			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '164' as tipo 
			from MSG_LINKED_ISCRIZIONE_ALBO 
			where msgisubtype = 164) v
			group by Fascicolo , owner, tipo

		
			


	) as a on p.idpfu = owner and LFN_id = tipo 
	

where LFN_GroupFunction = 'LINKED_ISCRIZIONE_ALBO'
GO
