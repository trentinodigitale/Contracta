USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_DGUE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[BANDO_DGUE_VIEW] as

select 
	
	IdRow, 
	IdHeader, 
	DSE_ID, 
	Row, 
	DZT_Name, 
	Value 

from ctl_doc_value  with (nolock)

	union 
	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'idTemplate' as DZT_Name,
	cast(t.id as varchar) as Value 
	
from ctl_doc b with (nolock)
	inner join ctl_doc t  with (nolock) on t.linkeddoc = b.id and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 and t.JumpCheck in ('DGUE','DGUE_MANDATARIA')
where b.tipodoc like  'BANDO%' 

	union 
	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'idTemplate_Mandanti' as DZT_Name,
	cast(t.id as varchar) as Value 
	
from ctl_doc b  with (nolock)
	inner join ctl_doc t  with (nolock) on t.linkeddoc = b.id and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 and t.JumpCheck in ('DGUE_RTI')
where b.tipodoc like  'BANDO%' 

	union 
	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'idTemplate_Ausiliarie' as DZT_Name,
	cast(t.id as varchar) as Value 
	
from ctl_doc b  with (nolock)
	inner join ctl_doc t  with (nolock) on t.linkeddoc = b.id and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 and t.JumpCheck in ('DGUE_AUSILIARIE')
where b.tipodoc like  'BANDO%' 

	union 
	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'idTemplate_Subappaltarici' as DZT_Name,
	cast(t.id as varchar) as Value 
	
from ctl_doc b  with (nolock)
	inner join ctl_doc t  with (nolock) on t.linkeddoc = b.id and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 and t.JumpCheck in ('DGUE_ESECUTRICI')
where b.tipodoc like  'BANDO%' 

	union 

	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'DGUEAttivo' as DZT_Name,
	case 
		--when EXISTS (Select * from LIB_Dictionary where DZT_Name='SYS_MODULI_RESULT' and SUBSTRING(DZT_ValueDef,115,1)='1' ) then 'si'
		when 
			SUBSTRING(isnull( DZT_ValueDef , '' ) ,115,1)='1' -- è attivo il modulo DGUE
			
			and isnull( v.Value ,'') <> 'no' -- non è statao escluso sul documento la compilazione del DGUE
			
			--and ISNULL( ba.TipoBandoGara ,'' ) not in ( '1','4','5')   -- non è un avviso , avviso aperto oppure avviso con destinatari
			
			and ISNULL( ba.TipoBandoGara ,'' ) not in ( '4','5')
			
			--se avviso per passare deve essere attivo INTEROP
			--altrimenti passa se non avviso 
			and ( ( ISNULL( ba.TipoBandoGara ,'') = '1' and dbo.attivo_INTEROP_Gara(b.id)=1 ) or ISNULL( ba.TipoBandoGara ,'') <> '1' )

			and  
				(
					b.tipodoc not in ( 'BANDO' ) 
					or
					( b.TipoDoc = 'BANDO' and isnull( JumpCheck , '' ) = '' )  -- Albo ME
					or
					( b.TipoDoc = 'BANDO' and isnull( JumpCheck , '' ) = 'BANDO_ALBO_FORNITORI'  and dbo.PARAMETRI ('DGUEAttivo-BANDO','BANDO_ALBO_FORNITORI','ATTIVO','NO',-1)= 'YES' )  
					or
					( b.TipoDoc = 'BANDO' and isnull( JumpCheck , '' ) = 'BANDO_ALBO_PROFESSIONISTI' and  dbo.PARAMETRI ('DGUEAttivo-BANDO','BANDO_ALBO_PROFESSIONISTI','ATTIVO','NO',-1)= 'YES') 
					or
					( b.TipoDoc = 'BANDO' and isnull( JumpCheck , '' ) = 'BANDO_ALBO_LAVORI' and  dbo.PARAMETRI ('DGUEAttivo-BANDO','BANDO_ALBO_LAVORI','ATTIVO','NO',-1)= 'YES' )  
					
				)
		then 'si'
		else 'no'
	end as Value
	
from ctl_doc b  with (nolock)
	left outer join Document_Bando ba  with (nolock) on ba.idheader = b.id 
	left outer join CTL_DOC_Value v  with (nolock) on v.idheader = b.id and v.DSE_ID = 'DGUE' and v.DZT_Name = 'DGUEAttivo'
	left outer join LIB_Dictionary l  with (nolock) on l.DZT_Name='SYS_MODULI_RESULT' 
where b.tipodoc like  'BANDO%' or b.tipodoc='TEMPLATE_GARA'


	union 


	
select 

	0 as IdRow, 
	b.id aS IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'SYS_OFFERTA_PRESENZA_ESECUTRICI' as DZT_Name,
	ISNULL(DZT_ValueDef,'NO') as Value
	
from ctl_doc b  with (nolock)
	left join LIB_Dictionary  with (nolock) on DZT_Name='SYS_OFFERTA_PRESENZA_ESECUTRICI' 
where b.tipodoc like  'BANDO%' 



	union 


	
select 

	0 as IdRow, 
	IdHeader,
	'DGUE' as DSE_ID,
	0 as Row,
	'NotEditable2' as DZT_Name,
	case 
		when 
			pcp_TipoScheda in ('AD3','AD5','AD2_25','P7_2','P7_1_2','P7_1_3','A3_6') then '' 
		else ' PresenzaDGUE '
	end as Value
		from Document_PCP_Appalto






GO
