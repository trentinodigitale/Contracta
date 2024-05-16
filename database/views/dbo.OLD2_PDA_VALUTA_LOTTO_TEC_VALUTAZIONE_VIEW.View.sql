USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_VIEW] as
	----select d.idHeader , Value , d.idRow, v.CriterioValutazione, v.DescrizioneCriterio, v.PunteggioMax, v.Formula, v.AttributoCriterio
	----	from CTL_DOC_Value d
	----		inner join Document_Microlotto_PunteggioLotto p on p.idRow = d.Row
	----		inner join Document_Microlotto_Valutazione v on p.idRowValutazione = v.idRow

	----	where DSE_ID = 'PDA_VALUTA_LOTTO_TEC'



	----select IdRow, IdHeader, DSE_ID, Row, DZT_Name, Value
	----	from ctl_doc_value 
	----	where DZT_Name not in ('GiudizioRiparametrato' , 'PunteggioRiparametrato' )
	----	--where idheader = 71376 and dse_id = 'PDA_VALUTA_LOTTO_TEC'

	----union

	----select riga.IdRow, d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'GiudizioRiparametrato' as  DZT_Name, str( GiudizioRiparametrato ,20, 10 ) as Value
	----	from ctl_doc d  
	----		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
	----		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id


	----	--where d.id = 71376 
	----union

	----select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'PunteggioRiparametrato' as  DZT_Name, str( PunteggioRiparametrato , 20 , 10 ) as Value
	----	from ctl_doc d  
	----		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
	----		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id


	----	--where d.id = 71376 




-----------------------------------------------------------------
-- DATI BASE DEL DOCUMENTO ad  eccezione dei valori riparametrati se non annullato
-----------------------------------------------------------------
select v.IdRow, v.IdHeader, v.DSE_ID, v.Row, v.DZT_Name, v.Value
	
	from ctl_doc d
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('CriterioValutazione' ) and c.dse_id = 'PDA_VALUTA_LOTTO_TEC'
		
		inner join ctl_doc_value v on v.idheader = d.id and v.DZT_Name not in ('GiudizioRiparametrato' , 'PunteggioRiparametrato' ) and v.dse_id = 'PDA_VALUTA_LOTTO_TEC'
										and c.row = v.Row and 
											( 
												v.DZT_Name not in (  'GiudizioTecnico' , 'Value' )
												or
												(
													v.DZT_Name in (  'GiudizioTecnico' , 'Value' )
													and
													(	
														c.Value = 'soggettivo'  
														or 
														( c.Value = 'quiz' and d.Statofunzionale = 'Annullato')
													)
												)
											)

-----------------------------------------------------------------
-- recupero il punteggio dinamicamente per gli oggettivi -- GiudizioTecnico e punteggio
-----------------------------------------------------------------
union all

select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'GiudizioTecnico' as  DZT_Name,   dbo.FormatFloat( Giudizio  ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('CriterioValutazione' ) and c.dse_id = 'PDA_VALUTA_LOTTO_TEC' and riga.row = c.row

	where  d.Statofunzionale <> 'Annullato' and c.Value = 'quiz' 

union all
select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'Value' as  DZT_Name,  dbo.FormatFloat( Punteggio ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id
		inner join ctl_doc_value c on c.idheader = d.id and c.DZT_Name in ('CriterioValutazione' ) and c.dse_id = 'PDA_VALUTA_LOTTO_TEC' and riga.row = c.row

	where  d.Statofunzionale <> 'Annullato' and c.Value = 'quiz' 


union all

-----------------------------------------------------------------
-- GiudizioRiparametrato se non annullato
-----------------------------------------------------------------
select riga.IdRow, d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'GiudizioRiparametrato' as  DZT_Name, str( GiudizioRiparametrato ,20, 10 ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id

union all

-----------------------------------------------------------------
-- PunteggioRiparametrato se non annullato
-----------------------------------------------------------------
select  riga.IdRow , d.id as IdHeader, 'PDA_VALUTA_LOTTO_TEC' as DSE_ID, riga.Row, 'PunteggioRiparametrato' as  DZT_Name, str( PunteggioRiparametrato , 20 , 10 ) as Value
	from ctl_doc d  
		inner join Document_Microlotto_PunteggioLotto p on d.linkeddoc = p.idHeaderLottoOff 
		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC' and riga.idheader = d.id


GO
