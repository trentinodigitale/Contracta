USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ASTA_VALUTAZIONE_RILANCIO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD_ASTA_VALUTAZIONE_RILANCIO]( @idDoc int  )
as
begin

		declare @idBando int
		declare @idRow int
		declare @Last float
		declare @Graduatoria float
		declare @Posizione varchar(50)
		declare @TipoAsta varchar(50)
		declare @Exequo int
		declare  @idMD int


		-- prendo il riferimento all'offerta dalla microlotti dettagli
		select @idMD= min(id )
			from  Document_MicroLotti_Dettagli 
			where idHeader = @idDoc and TipoDoc = 'OFFERTA_ASTA'

		select @idBando = linkeddoc from CTL_DOC where id = @idDoc

		--------------------------------------------------------------------------------------
		-- determino i criteri tecnici di valutazione del lotto e li associo per ogni offerta se mancano
		-- associo i criteri tecnici del Bando
		--------------------------------------------------------------------------------------
		if not exists( select * from Document_Microlotto_PunteggioLotto where idHeaderLottoOff = @idMD )
		begin
			insert into Document_Microlotto_PunteggioLotto ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select @idMD as idHeaderLottoOff ,  d.idRow as idRowValutazione , 0 as Punteggio 
						from Document_Microlotto_Valutazione d 
					where d.TipoDoc in (  'BANDO_ASTA' ) and d.idheader = @idBando 
					order by d.idRow
		end


		select @TipoAsta = TipoAsta from Document_ASTA where [idHeader] = @idBando
		--------------------------------------------------------------------------------------
		-- eseguo la valutazione dell' offerta 
		--------------------------------------------------------------------------------------



		-- calcolo il valore economico
		--exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO @idLotto , -1
		exec OFFERTA_VALORE_ECONOMICO @idDoc
		
		delete from CTL_DOC_VALUE where idheader = @idDoc and dzt_name in ( 'ValoreOfferta' ) and [DSE_ID] = 'TESTATA_PRODOTTI'
	
		-- se la gara è allo sconto
		if @TipoAsta = 'TA_Sconto' 
		begin
			insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value )
				select @idDoc , 'TESTATA_PRODOTTI' , 0  , 'ValoreOfferta', Value
					from  CTL_DOC_VALUE 
					where idheader = @idDoc and DSE_ID = 'TOTALI' and  dzt_name = 'ValoreSconto'
			
		end

		-- se la gara è al prezzo
		if @TipoAsta = 'TA_Prezzo' 
		begin
			insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value )
				select @idDoc , 'TESTATA_PRODOTTI' , 0  , 'ValoreOfferta', Value
					from  CTL_DOC_VALUE 
					where idheader = @idDoc and DSE_ID = 'TOTALI' and  dzt_name = 'ValoreEconomico'
			
		end
		
		-- se la gara è ecovantaggiosa calcolo il punteggio totaleconomico
		if @TipoAsta = 'TA_OEV' 
		begin
			-- se la gara prevede il punteggio tecnico	
			exec ASTA_VALUTAZIONE_ECONOMICA_ECO_VANTAGGIOSA  @idDoc 
			exec ASTA_VALUTAZIONE_RILANCIO_TEC  @idDoc  , @idBando   , @idMD

			insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value )
				select @idDoc , 'TESTATA_PRODOTTI' , 0  , 'ValoreOfferta', cast( isnull(v1.Value,'0.0') as float) + cast( isnull(v2.value,'0.0') as float ) 
					from  CTL_DOC_VALUE v1
						inner join CTL_DOC_VALUE v2 on v2.idheader = @idDoc and v2.DSE_ID = 'TOTALI' and  v2.dzt_name = 'PunteggioTecnico'
					where v1.idheader = @idDoc and v1.DSE_ID = 'TOTALI' and  v1.dzt_name = 'PunteggioEconomico'
			
		end

end










GO
