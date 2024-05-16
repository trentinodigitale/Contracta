USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_SDA_FARMACI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_ISTANZA_SDA_FARMACI_TESTATA_VIEW] as
select 
	 IdRow, 
	 IdHeader, 
	 DSE_ID, 
	 Row, 
	 DZT_Name, 
	 value

from CTL_DOC_VALUE
--union che recupera nomebando
union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'nomebando' as DZT_Name,
		c2.titolo as value
	from ctl_doc c
	inner join Document_Bando on c.linkedDoc=idHeader 
	inner join ctl_doc c2 on c2.id=c.linkeddoc

union

select 
		IdRow,
		c.id as IdHeader,
		'DISPLAY_DOCUMENTAZIONE' as DSE_ID,
		0 as Row,
		'nomebando' as DZT_Name,
		c2.titolo as value
	from ctl_doc c
	inner join Document_Bando on c.linkedDoc=idHeader 
	inner join ctl_doc c2 on c2.id=c.linkeddoc


--union che recupera NumDetermina e DataDetemina dal  Bando
union

	select 
		IdRow,
		c.id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'Riferimento_Gazzetta' as DZT_Name,
		c2.titolo as value
	from ctl_doc c
	inner join Document_Bando on c.linkedDoc=idHeader 
	inner join ctl_doc c2 on c2.id=c.linkeddoc

union

	select 
		IdRow,
		id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'Data_Pubblicazione_Gazzetta' as DZT_Name,
		convert(varchar,Data_Pubblicazione_Gazzetta,121) as value
		
	from ctl_doc
	inner join Document_Bando on linkedDoc=idHeader 


union

	select 
		IdRow,
		IdHeader,
		'DISPLAY_ABILITAZIONI' as DSE_ID,
		0 as Row,
		'Email' as DZT_Name,
		 value
		
	from ctl_doc_value 
	where DZT_Name='Email' and DSE_ID='TESTATA'
	
union

	select 
		IdRow,
		id as IdHeader,
		'TESTATA' as DSE_ID,
		0 as Row,
		'RichiediProdotti' as DZT_Name,
		cast(RichiediProdotti as varchar(10)) as value
		
	from ctl_doc
	inner join Document_Bando on linkedDoc=idHeader 
	
	union

	select 
		 IdRow, 
		 IdHeader, 
		 DSE_ID, 
		 Row, 
		 'CF_iscrizione' as DZT_Name, 
		 value

	from CTL_DOC_VALUE where dse_id='TESTATA' and dzt_name='codicefiscale' 

	union

		select 
		 IdRow, 
		 IdHeader, 
		 DSE_ID, 
		 Row, 
		 'IVA_iscrizione' as DZT_Name, 
		 value

	from CTL_DOC_VALUE where dse_id='TESTATA' and dzt_name='PIVA' 

	union

		select 
		 IdRow, 
		 IdHeader, 
		 DSE_ID, 
		 Row, 
		 'numero_iscrizione' as DZT_Name, 
		 value

	from CTL_DOC_VALUE where dse_id='TESTATA' and dzt_name='IscrCCIAA' 
	
	union 

	select 
		IdRow,
		IdHeader,
		'TESTATA2' as DSE_ID,
		 Row,
		'emailriferimentoazienda' as DZT_Name,
		 value
		
	from ctl_doc_value 
	where DZT_Name='Email' and DSE_ID='TESTATA'





GO
