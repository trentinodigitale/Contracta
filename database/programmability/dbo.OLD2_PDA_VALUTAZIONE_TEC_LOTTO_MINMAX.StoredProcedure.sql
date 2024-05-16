USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VALUTAZIONE_TEC_LOTTO_MINMAX]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  proc  [dbo].[OLD2_PDA_VALUTAZIONE_TEC_LOTTO_MINMAX]( @idPDA int , @NumeroLotto varchar (200) )
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



		--------------------------------------------------------------------------------------
		-- Per eseguire il calcolo min max è necessario che tutte le offerte coinvolte nel calcolo siano state aperte
		--------------------------------------------------------------------------------------
		select @idRow = id from  Document_MicroLotti_Dettagli where TipoDoc = 'PDA_MICROLOTTI' and idheader = @idPDA and Numerolotto = @NumeroLotto and Voce = 0
		
		if not exists( select * from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where bReadDocumentazione = '1' and StatoRiga <> 'escluso'  and id = @idRow )
		begin

			--------------------------------------------------------------------------------------
			-- eseguo la valutazione di ogni offerta per il lotto indicato
			--------------------------------------------------------------------------------------
			declare @NumOff int
			SET @NumOff = 0

			declare crsOf_TEC_LOTTO_MINMAX cursor static for 
				select d.id 
					from Document_PDA_OFFERTE o
						inner join Document_MicroLotti_Dettagli d on o.IdRow = d.IdHeader and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto  and Voce = 0  and StatoRiga <> 'escluso'
					where o.idHeader = @idPDA

			open crsOf_TEC_LOTTO_MINMAX 
			fetch next from crsOf_TEC_LOTTO_MINMAX into @idRow 

			while @@fetch_status=0 
			begin 
			
				--print 'PDA_VALUTAZIONE_TEC_ELAB_LOTTO_MINMAX  ' + cast( @idRow as varchar(20))
				exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO_MINMAX  @idRow

				SET @NumOff = @NumOff + 1
				fetch next from crsOf_TEC_LOTTO_MINMAX into @idRow 
			end 

			close crsOf_TEC_LOTTO_MINMAX 
			deallocate crsOf_TEC_LOTTO_MINMAX

		end


end













GO
