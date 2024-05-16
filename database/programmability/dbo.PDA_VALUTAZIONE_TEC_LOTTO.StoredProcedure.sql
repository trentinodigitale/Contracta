USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_VALUTAZIONE_TEC_LOTTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[PDA_VALUTAZIONE_TEC_LOTTO]( @idPDA int , @NumeroLotto varchar (200) )
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
		select @idBando = LinkedDoc from CTL_DOC  with (nolock) where id = @idPDA

		--------------------------------------------------------------------------------------
		-- determino i criteri tecnici di valutazione del lotto e li associo per ogni offerta
		--------------------------------------------------------------------------------------
		if exists(select d.id from Document_MicroLotti_Dettagli d   with (nolock)
						inner join Document_Microlotto_Valutazione v  with (nolock) on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0)
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici personalizzati del lotto se presenti
			--------------------------------------------------------------------------------------

			insert into Document_Microlotto_PunteggioLotto ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  v.idRow as idRowValutazione , 0 as Punteggio 
						from Document_MicroLotti_Dettagli d  with (nolock)
						inner join Document_Microlotto_Valutazione v  with (nolock) on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o  with (nolock)
										inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto and Voce = 0
									where o.idHeader = @idPDA
						) as l
					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando and NumeroLotto = @NumeroLotto and Voce = 0
					order by l.id ,v.idRow
		end
		else
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici del Bando
			--------------------------------------------------------------------------------------
			insert into Document_Microlotto_PunteggioLotto ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  d.idRow as idRowValutazione , 0 as Punteggio 
						from Document_Microlotto_Valutazione d  with (nolock)

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o  with (nolock)
										inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
									where o.idHeader = @idPDA
						) as l
					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA', 'BANDO_CONCORSO' ) and d.idheader = @idBando 
					order by l.id ,d.idRow


		end



		--------------------------------------------------------------------------------------
		-- determino i criteri ECONOMICI di valutazione del lotto e li associo per ogni offerta
		--------------------------------------------------------------------------------------
		if exists(select d.id from Document_MicroLotti_Dettagli d  with (nolock)
						inner join Document_Microlotto_Valutazione_ECO v  with (nolock) on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0)
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici personalizzati del lotto se presenti
			--------------------------------------------------------------------------------------

			insert into Document_Microlotto_PunteggioLotto_ECO ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  v.idRow as idRowValutazione , 0 as Punteggio 
						from Document_MicroLotti_Dettagli d  with (nolock)
						inner join Document_Microlotto_Valutazione_ECO v  with (nolock) on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o  with (nolock)
										inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto and Voce = 0
									where o.idHeader = @idPDA
						) as l
					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando and NumeroLotto = @NumeroLotto and Voce = 0
					order by l.id ,v.idRow
		end
		else
		begin

			--------------------------------------------------------------------------------------
			-- associo i criteri tecnici del Bando
			--------------------------------------------------------------------------------------
			insert into Document_Microlotto_PunteggioLotto_ECO ( idHeaderLottoOff , idRowValutazione , Punteggio )

					select l.id as idHeaderLottoOff ,  d.idRow as idRowValutazione , 0 as Punteggio 
						from Document_Microlotto_Valutazione_ECO d  with (nolock)

						-- per ogni lotto dei fornitori
						cross join (
								select d.id 
									from Document_PDA_OFFERTE o  with (nolock)
										inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
									where o.idHeader = @idPDA
						) as l
					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando 
					order by l.id ,d.idRow


		end




		--------------------------------------------------------------------------------------
		-- eseguo la valutazione di ogni offerta per il lotto indicato
		--------------------------------------------------------------------------------------
		declare @NumOff int
		SET @NumOff = 0

		declare crsOf cursor static for 
			select d.id 
				from Document_PDA_OFFERTE o  with (nolock)
					inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
					--VEDIAMO SE LETTA LA BUSTA TEC SENZA LOTTI, SE NON E' LETTA NON SERVE INVOCARE IL CALCOLO
					left join CTL_DOC_Value cv with(nolock) on o.IdMsg=cv.IdHeader and cv.DSE_ID='OFFERTA_BUSTA_TEC' and cv.DZT_Name='LettaBusta' and cv.Value='1' and cv.Row=0
					left join Document_MicroLotti_Dettagli o_f  with (nolock) on o_f.IdHeader = o.IdMsg and o_f.TipoDoc = 'OFFERTA' and o_f.NumeroLotto = @NumeroLotto  and o_f.Voce = 0
					left join CTL_DOC_Value cv2 with(nolock) on o.IdMsg=cv2.IdHeader and cv2.DSE_ID='OFFERTA_BUSTA_TEC' and cv2.DZT_Name='LettaBusta' and cv2.Value='' and cv2.IdRow=o_f.id
				where o.idHeader = @idPDA and ( cv.IdRow is not null or cv2.IdRow is not null)

		open crsOf 
		fetch next from crsOf into @idRow 

		while @@fetch_status=0 
		begin 
			
			exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @idRow

			SET @NumOff = @NumOff + 1
			fetch next from crsOf into @idRow 
		end 
		close crsOf 
		deallocate crsOf

		-- SE IL LOTTO è ANDATO DESERTO		
		IF NOT EXISTS (select d.id 
							from Document_PDA_OFFERTE o  with (nolock)
								inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0
							where o.idHeader = @idPDA 
						)
		--IF @NumOff = 0
		begin
			update Document_MicroLotti_Dettagli set StatoRiga = 'Deserta' where TipoDoc = 'PDA_MICROLOTTI' and NumeroLotto = @NumeroLotto  and Voce = 0 and idHeader = @idPDA
		end


end






GO
