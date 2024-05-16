USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_VALUTAZIONE_ECO_CHIUDI_LOTTO_OFFERTA_PUNTEGGI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PDA_VALUTAZIONE_ECO_CHIUDI_LOTTO_OFFERTA_PUNTEGGI]( @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @Punteggio			float


	-- dai documenti di valutazione si riportano i punteggi sulla valutazione del lotto e poi si si sommano sulla colonna del punteggio economico

	update Document_Microlotto_PunteggioLotto_ECO 
			set Punteggio =  val.value , --totale/punteggio
				Note = nt.Value ,		 -- motivazione
				Giudizio = giu.Value	 --coefficiente
		from Document_Microlotto_PunteggioLotto_ECO  P
			inner join Document_Microlotto_Valutazione_ECO V on P.idRowValutazione = V.idRow and V.FormulaEcoSDA = 'Valutazione soggettiva'
			inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_ECO'
			inner join CTL_DOC d on d.id = riga.idHEader and d.TipoDoc = 'PDA_VALUTA_LOTTO_ECO' and d.StatoFunzionale in (  'Confermato' , 'InLavorazione' ) and d.deleted = 0
			inner join CTL_DOC_Value val on d.id = val.idHeader and riga.Row = val.Row and val.DZT_Name = 'Value' and val.DSE_ID = 'PDA_VALUTA_LOTTO_ECO'
			inner join CTL_DOC_Value nt on d.id = nt.idHeader and riga.Row = nt.Row and nt.DZT_Name = 'Note' and nt.DSE_ID = 'PDA_VALUTA_LOTTO_ECO'
			inner join CTL_DOC_Value giu on d.id = giu.idHeader and riga.Row = giu.Row and giu.DZT_Name = 'Coefficiente' and giu.DSE_ID = 'PDA_VALUTA_LOTTO_ECO'

		where p.idHeaderLottoOff = @idRowLottoOff 




end






GO
