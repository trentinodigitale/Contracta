USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[OLD_PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA]( @idRowLottoOff int , @Riparametrato int )
as
begin

	declare @idRow				int 
	declare @Punteggio			float
	declare @PunteggioAssegnato			float
	declare @PunteggioRiparametrato			float


	---- dai documenti di valutazione si riportano i punteggi sulla valutazione del lotto e poi si si sommano sulla colonna del punteggio tecnico

	--update Document_Microlotto_PunteggioLotto set Punteggio =  val.value 
	--	-- select p.* , val.value
	--	from Document_Microlotto_PunteggioLotto  P
	--		inner join Document_Microlotto_Valutazione V on P.idRowValutazione = V.idRow and V.CriterioValutazione = 'soggettivo'
	--		inner join CTL_DOC_Value riga on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
	--		inner join CTL_DOC d on d.id = riga.idHEader and d.TipoDoc = 'PDA_VALUTA_LOTTO_TEC' and d.StatoFunzionale = 'Confermato'
	--		inner join CTL_DOC_Value val on d.id = val.idHeader and riga.Row = val.Row and val.DZT_Name = 'Value' and val.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'

	--	where p.idHeaderLottoOff = @idRowLottoOff -- 48012 --


	select @PunteggioRiparametrato = sum( isnull( PunteggioRiparametrato , 0 ) ) from Document_Microlotto_PunteggioLotto where idHeaderLottoOff = @idRowLottoOff
	select @PunteggioAssegnato = sum( isnull( Punteggio , 0 ) ) from Document_Microlotto_PunteggioLotto where idHeaderLottoOff = @idRowLottoOff


	-- sommo i vari punteggi
	set @Punteggio = 0
	if @Riparametrato = 1 
	begin
		--select @Punteggio = sum( isnull( PunteggioRiparametrato , 0 ) ) from Document_Microlotto_PunteggioLotto where idHeaderLottoOff = @idRowLottoOff
		set @Punteggio =  @PunteggioRiparametrato

	end
	else
	begin
		--select @Punteggio = sum( isnull( Punteggio , 0 ) ) from Document_Microlotto_PunteggioLotto where idHeaderLottoOff = @idRowLottoOff
		set @Punteggio =  @PunteggioAssegnato
	end
	
	update Document_MicroLotti_Dettagli set PunteggioTecnico = @Punteggio , PunteggioTecnicoAssegnato = @PunteggioAssegnato , PunteggioTecnicoRiparCriterio = @PunteggioRiparametrato where Id = @idRowLottoOff


end



GO
