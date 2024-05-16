USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_AlboOperaEco_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD_ISTANZA_AlboOperaEco_TESTATA_VIEW] as
select 
	 IdRow, 
	 IdHeader, 
	 DSE_ID, 
	 Row, 
	 DZT_Name, 
	 case when DZT_NAME='RagSoc' and c.StatoDoc='Saved' then aziragionesociale else Value end as value

from CTL_DOC_VALUE
		inner join CTL_DOC  c with (nolock) on  idheader=id 
		inner join profiliUtente p  with (nolock) on  p.idpfu=c.idpfu
		inner join aziende  with (nolock) on  idazi=pfuidazi

--union che recupera NumDetermina e DataDetemina dal  Bando
union
	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'NumDetermina' as DZT_Name,
		c2.titolo as value
	from ctl_doc c with (nolock)
	inner join Document_Bando with (nolock) on c.linkedDoc=idHeader 
	inner join ctl_doc c2 with (nolock) on c2.id=c.linkeddoc

union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA2' as DSE_ID,
		0 as Row,
		'NomeBando' as DZT_Name,
		c2.titolo as value
	from ctl_doc c with (nolock)
	inner join Document_Bando with (nolock) on c.linkedDoc=idHeader 
	inner join ctl_doc c2 with (nolock) on c2.id=c.linkeddoc

union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'NomeBando' as DZT_Name,
		c2.titolo as value
	from ctl_doc c with (nolock)
	inner join Document_Bando with (nolock) on c.linkedDoc=idHeader 
	inner join ctl_doc c2 with (nolock) on c2.id=c.linkeddoc
	
union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'CampoTesto_10' as DZT_Name,
		c2.titolo as value
	from ctl_doc c with (nolock)
		inner join Document_Bando with (nolock) on c.linkedDoc=idHeader 
		inner join ctl_doc c2 with (nolock) on c2.id=c.linkeddoc

union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA2' as DSE_ID,
		0 as Row,
		'CampoTesto_11' as DZT_Name,
		c2.titolo as value
	from ctl_doc c with (nolock)
		inner join Document_Bando with (nolock) on c.linkedDoc=idHeader 
		inner join ctl_doc c2 with (nolock) on c2.id=c.linkeddoc



union

	select 
		IdRow,
		id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'DataDetermina' as DZT_Name,
		convert(varchar,Data_Pubblicazione_Gazzetta,121) as value
		
	from ctl_doc with (nolock)
		inner join Document_Bando with (nolock) on linkedDoc=idHeader 
union 

	select 
		IdRow,
		IdHeader,
		'TESTATA' as DSE_ID,
		 Row,
		'Email' as DZT_Name,
		 value
		
	from ctl_doc_value with (nolock)
		where DZT_Name='Email' and DSE_ID = 'TESTATA2'
union
select 
		c.id as IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'DataInvioGara' as DZT_Name,
		convert(varchar,c2.DataInvio,121) as value
		
	from ctl_doc c with (nolock)
		inner join ctl_doc c2 with (nolock) on c.linkedDoc=c2.id
union
select 
		c.id as IdRow,
		c.id as IdHeader,
		'TESTATA2' as DSE_ID,
		0 as Row,
		'DataInvioGara' as DZT_Name,
		convert(varchar,c2.DataInvio,121) as value
		
	from ctl_doc c with (nolock)
		inner join ctl_doc c2 with (nolock) on c.linkedDoc=c2.id

union

select 
	IdRow, 
	IdHeader, 
	DSE_ID, 
	Row, 
	'CF_iscrizione' as DZT_Name, 
	value

from 
	CTL_DOC_VALUE with (nolock) where dse_id='TESTATA' and dzt_name='codicefiscale' 

union

	select 
		IdRow, 
		IdHeader, 
		DSE_ID, 
		Row, 
		'IVA_iscrizione' as DZT_Name, 
		value

from CTL_DOC_VALUE with (nolock) where dse_id='TESTATA' and dzt_name='PIVA' 

union

	select 
		IdRow, 
		IdHeader, 
		DSE_ID, 
		Row, 
		'numero_iscrizione' as DZT_Name, 
		value

from CTL_DOC_VALUE with (nolock) where dse_id='TESTATA' and dzt_name='IscrCCIAA' 

--agg aziIdDscFormaSoc anche in TESTATA2 per LAzio
union

select 
		IdRow, 
		IdHeader, 
		'TESTATA2' as DSE_ID, 
		Row, 
		'aziIdDscFormaSoc' as DZT_Name, 
		value

from CTL_DOC_VALUE with (nolock) where dse_id='TESTATA' and dzt_name='NaGi' 

--agg Email anche in TESTATA3 per LAzio
union 
select 
	
		IdRow,
		IdHeader,
		'TESTATA3' as DSE_ID,
		 Row,
		'Email' as DZT_Name,
		 value
		
	from ctl_doc_value  with (nolock)
	where DZT_Name='Email' and DSE_ID in ('TESTATA2','TESTATA')




GO
