USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboOperaEco_qf_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[ISTANZA_AlboOperaEco_qf_TESTATA_VIEW] as

		select 
				IdRow, 
				IdHeader, 
				DSE_ID, 
				Row, 
				DZT_Name, 
				case when DZT_NAME='RagSoc' and c.StatoDoc='Saved' then aziragionesociale else Value end as value

			from CTL_DOC_VALUE
				inner join CTL_DOC  c on  idheader=id 
				inner join profiliUtente p on  p.idpfu=c.idpfu
				inner join aziende on  idazi=pfuidazi

	--union che recupera NumDetermina e DataDetemina dal  Bando
	union

			select 
					IdRow,
					c.id as IdHeader,
					'TESTATA' as DSE_ID,
					0 as Row,
					'NumDetermina' as DZT_Name,
					c2.titolo as value

				from ctl_doc c
					inner join Document_Bando on c.linkedDoc=idHeader 
					inner join ctl_doc c2 on c2.id=c.linkeddoc

		--union

		--	select 
		--		IdRow,
		--		id as IdHeader,
		--		'TESTATA' as DSE_ID,
		--		0 as Row,
		--		'DataDetermina' as DZT_Name,
		--		convert(varchar,Data_Pubblicazione_Gazzetta,121) as value
		
		--	from ctl_doc
		--	inner join Document_Bando on linkedDoc=idHeader 
	union 

			select 
					IdRow,
					IdHeader,
					'TESTATA' as DSE_ID,
					Row,
					'Email' as DZT_Name,
					value
		
				from ctl_doc_value 
					where DZT_Name='Email' and DSE_ID like 'TESTATA2'


GO
