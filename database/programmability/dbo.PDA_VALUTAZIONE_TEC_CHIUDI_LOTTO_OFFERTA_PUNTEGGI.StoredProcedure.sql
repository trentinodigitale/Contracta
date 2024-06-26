USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA_PUNTEGGI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA_PUNTEGGI]( @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @Punteggio			float
	declare @id as int


	-- dai documenti di valutazione si riportano i punteggi sulla valutazione del lotto e poi si si sommano sulla colonna del punteggio tecnico

	--update Document_Microlotto_PunteggioLotto 
	--		set Punteggio =  val.value , Note = nt.Value , Giudizio = giu.Value
	--		-- select p.* , val.value
	--	from Document_Microlotto_PunteggioLotto  P with(nolock)
	--		inner join Document_Microlotto_Valutazione V with(nolock) on P.idRowValutazione = V.idRow and V.CriterioValutazione = 'soggettivo'
	--		inner join CTL_DOC_Value riga with(nolock) on riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
	--		inner join CTL_DOC d with(nolock) on d.id = riga.idHEader and d.TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC','PDA_CONCORSO_VALUTA_LOTTO_TEC') and d.StatoFunzionale in (  'Confermato' , 'InLavorazione' ) and d.deleted = 0
	--		inner join CTL_DOC_Value val with(nolock) on d.id = val.idHeader and riga.Row = val.Row and val.DZT_Name = 'Value' and val.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
	--		inner join CTL_DOC_Value nt  with(nolock) on d.id = nt.idHeader and riga.Row = nt.Row and nt.DZT_Name = 'Note' and nt.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
	--		inner join CTL_DOC_Value giu with(nolock) on d.id = giu.idHeader and riga.Row = giu.Row and giu.DZT_Name = 'GiudizioTecnico' and giu.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'

	--	where p.idHeaderLottoOff = @idRowLottoOff -- 48012 --

	--recupero da @idRowLottoOff il documento di valutazione tecnica
 	select 
			@Id=d.id 
		from 
			CTL_DOC d with(nolock) 
		where d.TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC','PDA_CONCORSO_VALUTA_LOTTO_TEC') 
			and d.StatoFunzionale in (  'Confermato' , 'InLavorazione' ) and d.deleted = 0 and d.linkeddoc = @idRowLottoOff
	
	update Document_Microlotto_PunteggioLotto 
			set Punteggio =  val.value , Note = nt.Value , Giudizio = giu.Value
			-- select p.* , val.value
		from Document_Microlotto_PunteggioLotto  P with(nolock)
			inner join Document_Microlotto_Valutazione V with(nolock) on P.idRowValutazione = V.idRow and V.CriterioValutazione = 'soggettivo'
			
			--ho aggiunto nella condizione riga.idheader = @Id  che sfrutta l'indice e migliora la query
			inner join CTL_DOC_Value riga with(nolock) on riga.idheader = @Id and riga.value = p.idRow and riga.DZT_Name = 'idRow' and riga.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
			--non serve più perchè già recuperato fuori
			--inner join CTL_DOC d with(nolock) on d.id = riga.idHEader and d.TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC','PDA_CONCORSO_VALUTA_LOTTO_TEC') and d.StatoFunzionale in (  'Confermato' , 'InLavorazione' ) and d.deleted = 0
			inner join CTL_DOC_Value val with(nolock) on @Id = val.idHeader and riga.Row = val.Row and val.DZT_Name = 'Value' and val.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
			inner join CTL_DOC_Value nt  with(nolock) on @Id = nt.idHeader and riga.Row = nt.Row and nt.DZT_Name = 'Note' and nt.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'
			inner join CTL_DOC_Value giu with(nolock) on @Id = giu.idHeader and riga.Row = giu.Row and giu.DZT_Name = 'GiudizioTecnico' and giu.DSE_ID = 'PDA_VALUTA_LOTTO_TEC'

		where p.idHeaderLottoOff = @idRowLottoOff -- 48012 --



end



GO
