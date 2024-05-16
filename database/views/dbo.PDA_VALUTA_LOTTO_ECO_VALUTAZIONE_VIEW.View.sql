USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_VALUTA_LOTTO_ECO_VALUTAZIONE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[PDA_VALUTA_LOTTO_ECO_VALUTAZIONE_VIEW] as

-----------------------------------------------------------------
-- DATI BASE DEL DOCUMENTO ad  eccezione dei valori riparametrati se non annullato
-----------------------------------------------------------------
--select IdRow, IdHeader, DSE_ID, Row, DZT_Name, Value
--	from ctl_doc_value 
--	where dse_id = 'PDA_VALUTA_LOTTO_ECO'


select v.IdRow, v.IdHeader, v.DSE_ID, v.Row, v.DZT_Name, v.Value
	
	from ctl_doc d
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('FormulaEcoSDA' ) and c.dse_id = 'PDA_VALUTA_LOTTO_ECO'
		
		inner join ctl_doc_value v on v.idheader = d.id and v.DZT_Name not in ('GiudizioRiparametrato' , 'PunteggioRiparametrato' ) and v.dse_id = 'PDA_VALUTA_LOTTO_ECO'
										and c.row = v.Row and 
											( 
												v.DZT_Name not in (  'GiudizioTecnico' , 'Value' , 'GiudizioTecnicoHidden' , 'Coefficiente')
												or
												(
													v.DZT_Name in (  'GiudizioTecnico' , 'Value' , 'GiudizioTecnicoHidden' , 'Coefficiente')
													and
													(	
														c.Value = 'Valutazione soggettiva'  
														or 
														( c.Value <> 'Valutazione soggettiva'  and d.Statofunzionale = 'Annullato')
													)
												)
											)		

union all


select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_ECO' as DSE_ID, riga.Row, 'GiudizioTecnicoHidden' as  DZT_Name,   dbo.FormatFloat( Giudizio  ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto_ECO p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO' and riga.idheader = d.id
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('FormulaEcoSDA' ) and c.dse_id = 'PDA_VALUTA_LOTTO_ECO' and riga.row = c.row

	where  d.Statofunzionale <> 'Annullato' and  c.Value <> 'Valutazione soggettiva'

union all

select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_ECO' as DSE_ID, riga.Row, 'Value' as  DZT_Name,  dbo.FormatFloat( Punteggio ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto_ECO p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO' and riga.idheader = d.id
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('FormulaEcoSDA' ) and c.dse_id = 'PDA_VALUTA_LOTTO_ECO' and riga.row = c.row

	where  d.Statofunzionale <> 'Annullato' and  c.Value <> 'Valutazione soggettiva'

union all

select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_ECO' as DSE_ID, riga.Row, 'Coefficiente' as  DZT_Name,  dbo.FormatFloat( Giudizio ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto_ECO p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO' and riga.idheader = d.id
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('FormulaEcoSDA' ) and c.dse_id = 'PDA_VALUTA_LOTTO_ECO' and riga.row = c.row

	where  d.Statofunzionale <> 'Annullato' and  c.Value <> 'Valutazione soggettiva'


union all


-----------------------------------------------------------------
-- GiudizioRiparametrato se non annullato
-----------------------------------------------------------------
select riga.IdRow, d.id as IdHeader, 'PDA_VALUTA_LOTTO_ECO' as DSE_ID, riga.Row, 'GiudizioRiparametrato' as  DZT_Name, str( p.GiudizioRiparametrato ,20, 10 ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto_ECO p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO' and riga.idheader = d.id

union all

-----------------------------------------------------------------
-- PunteggioRiparametrato se non annullato
-----------------------------------------------------------------
select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_ECO' as DSE_ID, riga.Row, 'PunteggioRiparametrato' as  DZT_Name, str( p.PunteggioRiparametrato , 20 , 10 ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto_ECO p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO' and riga.idheader = d.id





GO
