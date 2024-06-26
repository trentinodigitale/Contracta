USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc  [dbo].[OLD_PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE]( @IdDoc int  , @IdPFU as int , @PunteggioTecMin float , @PunteggioTEC_100 varchar(10)   , @Fase varchar(200) ,  @NuoveEsclusioni int output ) as
begin
-- @Fase
-- CriteriPrimaRiparametrazione
-- CriteriDopoRiparametrazione
-- TotalePrimaRiparametrazione
-- TotaleDopoRiparametrazione

	declare @IdLotto as Int 
	
	declare @Motivazione				as nvarchar(MAX)
	declare @PunteggioMin				as float
	declare @PunteggioRiparametrato		as float
	declare @PunteggioNonRiparametrato		as float
	declare @DescrizioneCriterio		as nvarchar(4000)
	declare @StatoRiga					as varchar(100)
	declare @Fascicolo					as varchar(100)
	declare @IdLottop					as Int 
	declare @IdPDA						as int
	declare @NumeroLotto as Varchar(255) 
	declare @IdAziPartecipante as int

	set @NuoveEsclusioni = 0 


	-- ciclo su ogni offerta per controllare che non abbia superato la soglia
	declare crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE cursor static for 
		
		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto , pda.Fascicolo,d.idAziPartecipante 
			from 
				Document_MicroLotti_Dettagli P with(nolock) 
					inner join Document_PDA_OFFERTE d with(nolock) on d.idheader = p.idheader
					inner join Document_MicroLotti_Dettagli O with(nolock) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' , 'inVerificaEco') and P.NumeroLotto = O.NumeroLotto
					inner join CTL_DOC pda on pda.id = p.idheader
			where  
				P.ID = @IdDoc 

	open crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE 
	
	fetch next from crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @Fascicolo, @IdAziPartecipante
	
	while @@fetch_status=0 
	begin 
			
		set @Motivazione=''


		-- verifico se la soglia sul totale è stata superata per escludere il lotto
		if exists( select id from Document_MicroLotti_Dettagli  with(nolock) where id  = @IdLotto and
					(
						( PunteggioTecnicoAssegnato < @PunteggioTecMin  and @PunteggioTEC_100 <> '2' and @Fase like '%TotalePrimaRiparametrazione%') -- se escludo prima della riparametrazione o non c'è riparametrazione prendo il totale assegnato dalla commissione senza alcuna riparaetrazione
						or
						( isnull( PunteggioTecnicoRiparTotale , PunteggioTecnico )  < @PunteggioTecMin  and @PunteggioTEC_100 = '2' and @Fase like '%TotaleDopoRiparametrazione%' ) -- se escludo dopo la riparametrazione prendo il totale completamente riparametrato
					)
				)
		begin

			set @Motivazione= 'Esclusa in automatico per mancato raggiungimento della soglia minima di punteggio tecnico, '

		end


		if @Fase in ( 'CriteriPrimaRiparametrazione','CriteriDopoRiparametrazione')
		begin
				
			----ciclo per verificare i punteggi dei singoli criteri se devo escludere
			declare crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3 cursor static for 
				
				select 
					idHeaderLottoOff,DP.PunteggioRiparametrato,DescrizioneCriterio,PunteggioMin , DP.Punteggio
					from 
						Document_Microlotto_PunteggioLotto DP  with(nolock)
							inner join Document_Microlotto_Valutazione DV  with(nolock) on DP.idRowValutazione=DV.idrow  
					where 
						idHeaderLottoOff=@IdLotto and ISNULL(PunteggioMin,0)>0
					
			open crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3

			fetch next from crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3 into @IdLottop , @PunteggioRiparametrato , @DescrizioneCriterio , @PunteggioMin , @PunteggioNonRiparametrato
			while @@fetch_status=0 
			begin

				---confronto punteggio e collezione i criteri per cui non soddisfa, successivamente faccio la insert per escludere come sopra
				IF  ( @PunteggioNonRiparametrato < @PunteggioMin  and @PunteggioTEC_100 <> '2' and @Fase like '%CriteriPrimaRiparametrazione%' ) -- se escludo prima della riparametrazione o non c'è riparametrazione prendo il criterio senza riparaetrazione
					or
					( isnull( @PunteggioRiparametrato , @PunteggioNonRiparametrato )  < @PunteggioMin  and @PunteggioTEC_100 = '2' and  @Fase like '%CriteriDopoRiparametrazione%' ) -- se escludo dopo la riparametrazione prendo il criterio riparametrato

				BEGIN
						
					set @Motivazione=@Motivazione + @DescrizioneCriterio + ' Soglia Minima:' + cast(@PunteggioMin as varchar(50)) +', '
						
				END
				fetch next from crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3 into @IdLottop , @PunteggioRiparametrato , @DescrizioneCriterio , @PunteggioMin , @PunteggioNonRiparametrato

			end
			close crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3 
			deallocate crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE3

		end

		--se ci sono dei criteri di punteggio min non soddisfatti escludo  il lotto
		if @Motivazione <> ''
		begin
			--rimuovo l'ultima virgola
			set @Motivazione=LEFT(@Motivazione,len(@Motivazione)-1)
			set @Motivazione='Esclusa in automatico per mancato raggiungimento dei seguenti criteri: ' + @Motivazione
			insert into CTL_DOC ( idPfu , TipoDoc , Body , StatoFunzionale , StatoDoc , dataInvio , Fascicolo , LinkedDoc , Protocollo , JumpCheck, Azienda, NumeroDocumento )
						values ( @IdPFU , 'ESITO_LOTTO_ESCLUSA' , @Motivazione ,'Confermato' , 'Sended' , getdate() , @Fascicolo , @IdLotto , '' , 'AUTO', @IdAziPartecipante, @NumeroLotto)
			Update Document_MicroLotti_Dettagli set StatoRiga = 'escluso' where id = @IdLotto 

			set @NuoveEsclusioni = 1

		end

		


		fetch next from crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @Fascicolo, @IdAziPartecipante
	end 
	
	close crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE 
	deallocate crsPDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE


end

GO
