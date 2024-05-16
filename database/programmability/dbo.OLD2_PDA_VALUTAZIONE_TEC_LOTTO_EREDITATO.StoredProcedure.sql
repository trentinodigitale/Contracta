USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VALUTAZIONE_TEC_LOTTO_EREDITATO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--Nella stored dei calcoli, cercare l'uso dei campi PunteggioTecMaxEredit e PunteggioTecMinEredit e commentarli




CREATE  proc [dbo].[OLD2_PDA_VALUTAZIONE_TEC_LOTTO_EREDITATO]( @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @i					int 

	declare @Formula			nvarchar(max)
	declare @ValoreOfferta		nvarchar(max)
	declare @AttributoCriterio	nvarchar(max)
	declare @Valori				nvarchar(max)
	declare @ValDom				nvarchar(max)
	declare @minimo				nvarchar(max)
	declare @massimo			nvarchar(max)
	declare @punteggio			nvarchar(255)
	declare @CriterioQuiz		varchar(50)
	declare @statmentSQL		varchar(max)


	declare @NumeroLotto			varchar(50)
	declare @idHeaderLotto			int
	declare @VociMultiple			int
	declare @VociMultipleBase		int
	declare @idRowLottoOffVoce		int
	declare @fetch_status_voce		int
	declare @idBando				int
	declare @TipoDocBando			varchar(2000)
	declare @idRowVoce				int
	declare @idHeaderOff			int
	declare @PesoVoce				float
	declare @PunteggioParziale		float
	declare @PunteggioMax			float
	declare @TipoGiudizioTecnico	varchar(50)
	declare @idPDA					int
	declare @divisione_lotti		varchar(50)
	declare @CriterioValutazione	varchar(100)

	declare @idHeaderLottoBando int
	declare @idRowLottoOffAQ int
	

	declare @idAziOE	int
	declare @idPDA_AQ	int
	declare @idDocRC	int
	declare @IdDocAQ	int

	declare @IdDocEreditCriteri int
	declare @TipoDocEreditCriteri varchar( 100)

	declare @PunteggioTecMinEredit	float
	declare @PunteggioTecMaxEredit	float
	declare @PunteggioTecPercEredit float
	
	
	select @NumeroLotto = o.NumeroLotto , @idHeaderLotto = o.idHeaderLotto , @idBando = d.linkedDoc 
			, @TipoDocBando = b.TipoDoc , @idHeaderOff = o.idHeader , @TipoGiudizioTecnico = isnull( TipoGiudizioTecnico , 'edit' )
			, @idPDA = p.idheader
			, @divisione_lotti = divisione_lotti
			, @idAziOE = p.idAziPartecipante

			from Document_MicroLotti_Dettagli o with(nolock) 
				inner join Document_PDA_OFFERTE p with(nolock)  on p.IdRow = o.idheader 
				inner join ctl_doc d with(nolock) on d.id = p.idheader
				inner join Ctl_Doc b with(nolock) on d.linkedDoc = b.id
				inner join Document_Bando ba with(nolock) on ba.idheader = b.id
				where o.Id = @idRowLottoOff

	select @IdDocAQ = b.LinkedDoc , @idPDA_AQ = p.id , @idDocRC = b.Id , @idHeaderLottoBando = d.id 
		from CTL_DOC b with(nolock) 
			left Outer join CTL_DOC AQ with(nolock) on AQ.id = b.LinkedDoc
			left outer join CTL_DOC P with(nolock) on P.linkeddoc = AQ.id and p.Deleted = 0 and p.TipoDoc = 'PDA_MICROLOTTI'
			left outer join Document_MicroLotti_Dettagli d with(nolock) on d.idheader = b.id and d.TipoDoc = 'BANDO_GARA' and d.voce = 0 and d.NumeroLotto = @NumeroLotto
		where b.id = @idBando

	-- RECUPERO IL LOTTO OFFERTO IN AQ
	select @idRowLottoOffAQ = o.Id
			from Document_PDA_OFFERTE p with(nolock)  
				inner join Document_MicroLotti_Dettagli o with(nolock) on p.IdRow = o.idheader and o.TipoDoc = 'PDA_OFFERTE' and o.Voce = 0 and o.NumeroLotto = @NumeroLotto
				where p.IdHeader = @idPDA_AQ and p.idAziPartecipante = @idAziOE



	-- recuperiamo dal Rilancio competitivo i valori di min max e percentuale da ereditare
	select @PunteggioTecMinEredit  = Value from CtL_DOC_VALUE  with(nolock) where idheader = @idDocRC and DZT_Name = 'PunteggioTecMinEredit' and DSE_ID = 'AQ_EREDITA_TEC'
	select @PunteggioTecMaxEredit  = Value from CtL_DOC_VALUE  with(nolock) where idheader = @idDocRC and DZT_Name = 'PunteggioTecMaxEredit' and DSE_ID = 'AQ_EREDITA_TEC'
	select @PunteggioTecPercEredit = Value from CtL_DOC_VALUE  with(nolock) where idheader = @idDocRC and DZT_Name = 'PunteggioTecPercEredit' and DSE_ID = 'AQ_EREDITA_TEC'

	set @IdDocEreditCriteri = @idDocRC
	set @TipoDocEreditCriteri = 'BANDO_CRITERI_AQ_EREDITA_TEC'

	-- verifichiamo se sono stati specializzati sul lotto del rilancio
	if exists (select value from Document_Microlotti_DOC_Value where dse_id='CRITERI_AGGIUDICAZIONE' and dzt_name='CriterioAggiudicazioneGara' and idheader=@idHeaderLottoBando)
	begin

		select @PunteggioTecMinEredit  = Value from Document_Microlotti_DOC_Value  with(nolock) where idheader = @idHeaderLottoBando and DZT_Name = 'PunteggioTecMinEredit' and DSE_ID = 'AQ_EREDITA_TEC'
		select @PunteggioTecMaxEredit  = Value from Document_Microlotti_DOC_Value  with(nolock) where idheader = @idHeaderLottoBando and DZT_Name = 'PunteggioTecMaxEredit' and DSE_ID = 'AQ_EREDITA_TEC'
		select @PunteggioTecPercEredit = Value from Document_Microlotti_DOC_Value  with(nolock) where idheader = @idHeaderLottoBando and DZT_Name = 'PunteggioTecPercEredit' and DSE_ID = 'AQ_EREDITA_TEC'

		set @IdDocEreditCriteri = @idHeaderLottoBando
		set @TipoDocEreditCriteri = 'LOTTO_CRITERI_AQ_EREDITA_TEC'
		
	end



	declare @IdDocEreditCriteriAQ int
	declare @TipoDocEreditCriteriAQ varchar(100)

	set @IdDocEreditCriteriAQ = @idDocAQ
	set @TipoDocEreditCriteriAQ = 'BANDO_GARA'

	declare @idLottoBandoAQ int
	select @idLottoBandoAQ = id from Document_MicroLotti_Dettagli  with(nolock) where idheader = @IdDocAQ and TipoDoc = 'BANDO_GARA' and Voce = 0 and NumeroLotto = @NumeroLotto

	-- verifichiamo se sono stati specializzati sul lotto dell' AQ
	if exists (select value from Document_Microlotti_DOC_Value where dse_id='CRITERI_AGGIUDICAZIONE' and dzt_name='CriterioAggiudicazioneGara' and idheader=@idLottoBandoAQ)
	begin

		set @IdDocEreditCriteriAQ = @idLottoBandoAQ
		set @TipoDocEreditCriteriAQ = 'LOTTO'

	end


	--recupero i punteggi ottenuti sui criteri spuntati
	select @PunteggioParziale = sum( isnull( p.PunteggioRiparametrato , p.Punteggio ) )
		from Document_Microlotto_Valutazione RC with(nolock)
			inner join Document_Microlotto_Valutazione AQ with(nolock) on AQ.idHeader = @IdDocEreditCriteriAQ and AQ.TipoDoc = @TipoDocEreditCriteriAQ
																		and RC.CriterioValutazione = AQ.CriterioValutazione
																		and RC.DescrizioneCriterio = AQ.DescrizioneCriterio
																		and RC.PunteggioMax = AQ.PunteggioMax
																		and RC.AttributoCriterio = AQ.AttributoCriterio
																		and RC.Formula = AQ.Formula
			
			-- punteggio ottenbuto sull'offerta dal criterio
			inner join Document_Microlotto_PunteggioLotto P with(nolock) on  p.idHeaderLottoOff = @idRowLottoOffAQ and p.idRowValutazione = AQ.idRow

		where RC.idHeader = @IdDocEreditCriteri and RC.TipoDoc = @TipoDocEreditCriteri
			and rc.Eredita = '1'



	set  @PunteggioParziale = ( @PunteggioParziale / 100.0 ) * @PunteggioTecPercEredit

	--if @PunteggioParziale > @PunteggioTecMaxEredit
	--	set @PunteggioParziale = @PunteggioTecMaxEredit

	--if @PunteggioParziale < @PunteggioTecMinEredit
	--	set @PunteggioParziale = @PunteggioTecMinEredit



	set @PunteggioParziale = dbo.AFS_ROUND( @PunteggioParziale , 2 ) 

	--per ogni punteggio oggettivo determina il valore in funzione dei dati inseriti
	declare CrsLt cursor static for 
		select p.idRow , Formula , AttributoCriterio , PunteggioMax , CriterioValutazione
			from Document_Microlotto_PunteggioLotto p
				inner join Document_Microlotto_Valutazione v on v.idRow = idRowValutazione and CriterioValutazione in (  'ereditato' )
			where idHeaderLottoOff = @idRowLottoOff 
			order by v.idRow

	open CrsLt 
	fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax , @CriterioValutazione

	while @@fetch_status=0 
	begin 


		update Document_Microlotto_PunteggioLotto 
			set Punteggio = cast( @PunteggioParziale as float ) , 
				PunteggioOriginale = cast( @PunteggioParziale as float ) , 
				--Giudizio = dbo.FormatFloat( @PunteggioParziale / @PunteggioTecMaxEredit  ) 
				Giudizio = dbo.FormatFloat( @PunteggioParziale / @PunteggioMax  ) 
			where idRow = @idRow


		fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax , @CriterioValutazione
	end 
	close CrsLt 
	deallocate CrsLt




end












GO
