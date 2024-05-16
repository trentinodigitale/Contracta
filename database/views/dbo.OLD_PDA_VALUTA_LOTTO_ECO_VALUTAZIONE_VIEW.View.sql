USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_VALUTA_LOTTO_ECO_VALUTAZIONE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_PDA_VALUTA_LOTTO_ECO_VALUTAZIONE_VIEW] as

-----------------------------------------------------------------
-- DATI BASE DEL DOCUMENTO ad  eccezione dei valori riparametrati se non annullato
-----------------------------------------------------------------
select IdRow, IdHeader, DSE_ID, Row, DZT_Name, Value
	from ctl_doc_value 
	where dse_id = 'PDA_VALUTA_LOTTO_ECO'
		

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
