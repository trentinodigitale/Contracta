USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_VALUTAZIONE_TEC_LOTTO_RIAMMESSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[PDA_VALUTAZIONE_TEC_LOTTO_RIAMMESSO]( @idPDA int , @NumeroLotto varchar (200), @idrowOffertaDaRiammettere int )
as
begin

		declare @idDoc int
		declare @idBando int
		declare @i int
		declare @idRow int
		declare @Last float
		declare @Graduatoria float
		declare @Posizione varchar(50)
		declare @Exequo int


		set @idDoc = @idPDA
		select @idBando = LinkedDoc from CTL_DOC with(nolock) where id = @idPDA

		--------------------------------------------------------------------------------------
		-- determino i criteri tecnici di valutazione del lotto e li associo per ogni offerta
		--------------------------------------------------------------------------------------
		IF EXISTS(select d.id from Document_MicroLotti_Dettagli d with(nolock)
						inner join Document_Microlotto_Valutazione v with(nolock) on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0)
		BEGIN

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici personalizzati del lotto se presenti
			--------------------------------------------------------------------------------------

			insert into Document_Microlotto_PunteggioLotto ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select distinct l.id as idHeaderLottoOff ,  v.idRow as idRowValutazione , 0 as Punteggio 
						from Document_MicroLotti_Dettagli d 
							inner join Document_Microlotto_Valutazione v on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

							-- per ogni lotto dei fornitori
							cross join (
									select d.id 
										from Document_PDA_OFFERTE o
											inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto and Voce = 0
										where o.idHeader = @idPDA and o.idrow = @idrowOffertaDaRiammettere
							) as l

							left join Document_Microlotto_PunteggioLotto pl ON l.id = pl.idHeaderLottoOff and v.idRow = pl.idRowValutazione 

						where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando and NumeroLotto = @NumeroLotto and Voce = 0 and pl.idRow is null
						order by l.id ,v.idRow

		END
		ELSE
		BEGIN

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici del Bando
			--------------------------------------------------------------------------------------
			insert into Document_Microlotto_PunteggioLotto ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  d.idRow as idRowValutazione , 0 as Punteggio 
						from Document_Microlotto_Valutazione d 

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o
										inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
									where o.idHeader = @idPDA and o.idrow = @idrowOffertaDaRiammettere
						) as l

						left join Document_Microlotto_PunteggioLotto pl ON l.id = pl.idHeaderLottoOff and d.idrow = pl.idRowValutazione

					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando   and pl.idRow is null
					order by l.id ,d.idRow


		end



		--------------------------------------------------------------------------------------
		-- determino i criteri ECONOMICI di valutazione del lotto e li associo per ogni offerta
		--------------------------------------------------------------------------------------
		if exists(select d.id from Document_MicroLotti_Dettagli d 
						inner join Document_Microlotto_Valutazione_ECO v on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0)
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici personalizzati del lotto se presenti
			--------------------------------------------------------------------------------------

			insert into Document_Microlotto_PunteggioLotto_ECO ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  v.idRow as idRowValutazione , 0 as Punteggio from Document_MicroLotti_Dettagli d 
						inner join Document_Microlotto_Valutazione_ECO v on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o
										inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto and Voce = 0
									where o.idHeader = @idPDA AND o.IdRow = @idrowOffertaDaRiammettere
						) as l

						left join Document_Microlotto_PunteggioLotto_ECO pl ON l.id = pl.idHeaderLottoOff and v.idrow = pl.idRowValutazione 

					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando and NumeroLotto = @NumeroLotto and Voce = 0 and pl.idRow is null
					order by l.id ,v.idRow
		end
		else
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici del Bando
			--------------------------------------------------------------------------------------
			insert into Document_Microlotto_PunteggioLotto_ECO ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  d.idRow as idRowValutazione , 0 as Punteggio 
						from Document_Microlotto_Valutazione_ECO d 

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o
										inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
									where o.idHeader = @idPDA AND o.IdRow = @idrowOffertaDaRiammettere
						) as l

						left join Document_Microlotto_PunteggioLotto_ECO pl ON l.id = pl.idHeaderLottoOff and d.idrow = pl.idRowValutazione 

					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and pl.idRow is null
					order by l.id ,d.idRow


		end

		-- riporto lo stato del lotto di gara nella fase iniziale
		update Document_MicroLotti_Dettagli  
			set StatoRiga = case when   CriterioAggiudicazioneGara <> '15532' and CriterioAggiudicazioneGara <> '25532'  and isnull( Conformita , 'No' ) <> 'Ex-Ante' then 'Valutato'  else  'daValutare' end
			from Document_MicroLotti_Dettagli  
				inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO on idBando =  @IdBando and N_Lotto = NumeroLotto 
			where IdHeader = @idPDA  and TipoDoc = 'PDA_MICROLOTTI' and Numerolotto = @NumeroLotto and voce = 0

		--------------------------------------------------------------------------------------
		-- eseguo la valutazione di ogni offerta per il lotto indicato
		--------------------------------------------------------------------------------------
		declare crsOf cursor static for 
			select d.id 
				from Document_PDA_OFFERTE o
					inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
				where o.idHeader = @idPDA AND o.IdRow = @idrowOffertaDaRiammettere

		open crsOf 
		fetch next from crsOf into @idRow 

		while @@fetch_status=0 
		begin 
		
			exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @idRow

			fetch next from crsOf into @idRow

		end 

		close crsOf 
		deallocate crsOf


END




GO
