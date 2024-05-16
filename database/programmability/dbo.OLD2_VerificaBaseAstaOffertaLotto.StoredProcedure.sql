USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_VerificaBaseAstaOffertaLotto]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROC [dbo].[OLD2_VerificaBaseAstaOffertaLotto]( @idpfu as int , @idPDA AS VARCHAR(20), @IdLotto AS int, @IdDoc AS VARCHAR(20) )
AS 
begin

	declare @TipoDoc					as varchar(100)
	declare @idBando					INT

	--declare @idDoc int
	declare @Criterio					as varchar(100)
	declare @ListaModelliMicrolotti		as varchar(500)
	declare @FormulaEconomica			as nvarchar (4000)
	declare @FieldBaseAsta				as nvarchar (4000)
	declare @Modello					as varchar(500)
	declare @NumeroLotto				as varchar(500)
	declare @Fascicolo					as varchar(200)
	
	declare @Divisione_Lotti			varchar(20)
	
	declare @strSql						as nvarchar (4000)
	declare @idRow						int
	declare @ValoreImportoLotto			float
	declare @BaseAsta					float
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @concessione				varchar(2)
	declare @TipoProceduraCaratteristica				varchar(200)
	

	insert into ctl_log_utente ( idpfu, datalog, paginaDiArrivo,  querystring ) 
		values ( @idpfu , getdate() ,  'VerificaBaseAstaOffertaLotto' , ' exec VerificaBaseAstaOffertaLotto  ' + cast( @idpfu as varchar(20)) + ' , ' + @idPDA + ' , ' + cast ( @IdLotto AS varchar(20)) + ' , ' + @IdDoc   )
	
	--set @idDoc = <ID_DOC>

	select  @idBando = LinkedDoc , @Fascicolo = Fascicolo 
		from ctl_doc with (nolock) where id = @idDoc 

	set @TipoDoc = 'PDA_OFFERTE'
	

	--recupero modello selezionato
	-- determino il criterio di aggiudicazione della gara
	select	@Modello = b.TipoBando ,
			@Criterio = b.criterioformulazioneofferte  , 
			@Divisione_Lotti = Divisione_Lotti , 
			@CriterioAggiudicazioneGara = CriterioAggiudicazioneGara ,
			@concessione=isnull(b.concessione,'no'),
			@TipoProceduraCaratteristica=isnull(TipoProceduraCaratteristica ,'')
		from Document_Bando b with (nolock)
			   inner join CTL_DOC d with (nolock) on b.idHeader = d.LinkedDoc
		where d.id = @iddoc


	-- DALLA PDA SI RISALE  alle righe del lotto interessato per le monolotto tutta l'offerta
	if @IdLotto > 0 
	begin
		select 
			@NumeroLotto = Numerolotto
			from 
				Document_MicroLotti_Dettagli o with (nolock)
			where id = @IdLotto
	end
	else
		set @Numerolotto = '1'
	
	
	
	if upper(@TipoProceduraCaratteristica) = 'RFQ'
	begin
		exec PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE   @IdPDA , @NumeroLotto  , @idDoc 
	end
	else
	begin

		---------------------------------------------
		-- recupera il modello selezionato sul bando
		---------------------------------------------
		declare @IdDocModello int
		---- per il bando semplificato il modello si trova collegato allo SDA
		--if exists( select * from ctl_doc where tipodoc = 'BANDO_SEMPLIFICATO' and id = @idBando )
		--	select @IdDocModello = m.id from ctl_doc sem inner join ctl_doc m on m.linkedDoc = sem.linkedDoc and m.tipodoc = 'CONFIG_MODELLI_LOTTI' and m.deleted = 0 where sem.id = @idBando
		--else
			select @IdDocModello = id 
				from ctl_doc with (nolock) 
				where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando



		select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta
			from 
				Document_Modelli_MicroLotti_Formula  with (nolock)
			where @Criterio = CriterioFormulazioneOfferte
					and @modello = Codice and deleted = 0 


	


		-- recupero il riferimento nella PDA  dei valori offerti dal fornitore
		select @idRow = idRow from Document_PDA_OFFERTE with (nolock) where IdMsg = @idDoc and idheader = @idPDA


		-- calcolo il valore del lotto offerto 
		exec PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE   @IdPDA , @NumeroLotto  , @idDoc 

		--recupero il valore economico calcolato
		select @ValoreImportoLotto = ValoreImportoLotto 
			from  Document_MicroLotti_Dettagli d with (nolock)
			where d.IdHeader = @idRow and d.TipoDoc = 'PDA_OFFERTE' and NumeroLotto = @NumeroLotto and Voce = 0

		--recupero la base asta
		select @BaseAsta = ValoreImportoLotto 
			from  Document_MicroLotti_Dettagli d with (nolock)
			where d.IdHeader = @idPDA and d.TipoDoc = 'PDA_MICROLOTTI' and NumeroLotto = @NumeroLotto and Voce = 0
	



		-- per le gare al costo fisso non è necessario effettuare i controlli del valore offerto
		-- e per il prezzo più alto non si controlla il valore inserito
		-- e per le concessioni
		if @CriterioAggiudicazioneGara <> '25532' and @CriterioAggiudicazioneGara <> '16291' and @concessione <> 'si'
		begin

			if round( @ValoreImportoLotto , 2 ) <= 0
			begin

				Update Document_MicroLotti_Dettagli
					set StatoRiga = 'SuperataBaseAsta',EsitoRiga =  'Il valore dell''offerta non puo essere minore o uguale a zero'
					where tipodoc =  @TipoDoc 
						and idheader = @idRow and NumeroLotto = @NumeroLotto and Voce = 0
			end

			IF EXISTS ( select REL_idRow from CTL_Relations with(nolock) where REL_Type = 'VerificaBaseAstaOffertaLotto' and REL_ValueInput = 'Esclusione_Superamento_BaseAsta' and REL_ValueOutput = '>=' )
			BEGIN
				if round( @ValoreImportoLotto , 2 )  >= round( @BaseAsta , 2 ) 
				begin

					Update Document_MicroLotti_Dettagli
						set StatoRiga = 'SuperataBaseAsta'
							,EsitoRiga =  'Valore offerto maggiore o uguale alla base asta'
						where tipodoc =  @TipoDoc 
							and idheader = @idRow and NumeroLotto = @NumeroLotto and Voce = 0
				end
			END
			ELSE
			BEGIN
				if round( @ValoreImportoLotto , 2 )  > round( @BaseAsta , 2 ) 
				begin

					Update Document_MicroLotti_Dettagli
						set StatoRiga = 'SuperataBaseAsta'
							,EsitoRiga =  'Valore offerto superiore alla base asta'
						where tipodoc =  @TipoDoc 
							and idheader = @idRow and NumeroLotto = @NumeroLotto and Voce = 0
				end
			END

		end

		---- per le offerte in Percentuale
		--if @Criterio = '15537' 
		--begin
	
		--	-- il controllo che il valore offerto sia minore o uguale a zero deve essere sempre fatto
		--	set @strSql =  'Update 
		--		Document_MicroLotti_Dettagli
		--		set StatoRiga = ''SuperataBaseAsta''
		--			,EsitoRiga =  ''Il valore dell''''offerta non puo essere minore di zero''
		--		where tipodoc = ''' + @TipoDoc + ''' and cast( ' + @FormulaEconomica + ' as float ) < 0
		--			and idheader = ' + cast( @idRow as varchar(20)) + ' and NumeroLotto = ''' + @NumeroLotto + '''  '

		--	-- applica la restrizione coerente con la richiesta di edit del campo definito sul modello
		--	set @strSql = @strSql + dbo.ConditionLottoVoceModello( @IdDocModello , @FieldBaseAsta , @Divisione_Lotti) 



		--	--print @strSql
		--	exec ( @strSql )
		
		--	set @strSql =  'Update 
		--		Document_MicroLotti_Dettagli
		--		set StatoRiga = ''SuperataBaseAsta''
		--			,EsitoRiga = ''Il valore dell''''offerta non puo essere maggiore o uguale a 100''
		--		where tipodoc = ''' + @TipoDoc + ''' and cast( ' + @FormulaEconomica + ' as float ) >= 100
		--			and idheader = ' + cast( @idRow as varchar(20))  + ' and NumeroLotto = ''' + @NumeroLotto + '''  '

		--	-- applica la restrizione coerente con la richiesta di edit del campo definito sul modello
		--	set @strSql = @strSql + dbo.ConditionLottoVoceModello( @IdDocModello , @FieldBaseAsta , @Divisione_Lotti) 


		--	--print @strSql
		--	exec ( @strSql )
	
		--end
	
		---- offerte al prezzo
		--if @Criterio = '15536' 
		--begin
	
		--	set @strSql =  'Update 
		--		Document_MicroLotti_Dettagli
		--		set StatoRiga = ''SuperataBaseAsta''
		--			, EsitoRiga = ''Il valore dell''''offerta non puo essere minore o uguale a zero''
		--		where tipodoc = ''' + @TipoDoc + ''' and cast( ' + @FormulaEconomica + ' as float ) <= 0
		--			and idheader = ' + cast( @idRow as varchar(20)) + ' and NumeroLotto = ''' + @NumeroLotto + '''  '



		--	set @strSql = @strSql + dbo.ConditionLottoVoceModello( @IdDocModello , @FieldBaseAsta , @Divisione_Lotti) 

		--	--print @strSql
		--	exec ( @strSql )

	
		--	set @strSql =  'Update 
		--		Document_MicroLotti_Dettagli
		--		set StatoRiga = ''SuperataBaseAsta''
		--			,EsitoRiga = ''Valore offerto superiore alla base asta''
		--		where tipodoc = ''' + @TipoDoc + ''' and cast( ' + @FormulaEconomica + ' as float ) > cast( ' + @FieldBaseAsta + ' as float )
		--			and idheader = ' + cast( @idRow as varchar(20)) + ' and NumeroLotto = ''' + @NumeroLotto + '''  '


		--	set @strSql = @strSql + dbo.ConditionLottoVoceModello( @IdDocModello , @FieldBaseAsta , @Divisione_Lotti) 


		--	--print @strSql
		--	exec ( @strSql )
		
	
		--end


		-- nel caso in cui ci sono righe in SuperataBaseAsta si crea il documento di esclusione lotto relativo e si passa lo stato del lotto in esclusoEco
		IF EXISTS( select id from Document_MicroLotti_Dettagli with (nolock) where  idheader = @idRow  and NumeroLotto = @NumeroLotto  and  tipodoc = @TipoDoc and StatoRiga = 'SuperataBaseAsta' )
		begin
			declare @idRigaLotto int 
			select @idRigaLotto = id from Document_MicroLotti_Dettagli with (nolock) where  idheader = @idRow  and NumeroLotto = @NumeroLotto  and  tipodoc = @TipoDoc and StatoRiga = 'SuperataBaseAsta' and Voce = 0
		
		
			update Document_MicroLotti_Dettagli set StatoRiga = 'esclusoEco'   where id = @idRigaLotto

			insert into CTL_DOC ( idPfu , TipoDoc , Body , StatoFunzionale , StatoDoc , dataInvio , Fascicolo , LinkedDoc , Protocollo)
						values ( @IdPFU , 'ESITO_ECO_LOTTO_ESCLUSA' , 'Esclusa in automatico per offerta economica non valida'  , 'Confermato' , 'Sended' , getdate() , @Fascicolo , @idRigaLotto , '' )


		end


	end
	


end











GO
