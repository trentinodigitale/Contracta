USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_GRADUATORIA_LOTTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[PDA_GRADUATORIA_LOTTO]( @idPDA int , @NumeroLotto varchar (200) )
as
begin

	declare @idDoc int
	declare @i int
	declare @idBando int
	declare @idRow int
	declare @Last float
	declare @Graduatoria float
	declare @Posizione varchar(50)
	declare @Exequo int
	declare @RegoleAggiudicatari as varchar(100)
	declare @TipoAggiudicazione as varchar(100)
		
	declare @ValorePosizione as varchar(100)
	declare @numOfferteAmmesse INT
	declare @bloccoAnomalia int
		
	declare @idpfu INT = NULL
	declare @divisioneLotti varchar(100)
	declare @Conformita as varchar(100)
	declare @TipoDocPDA as varchar(500)
	declare @NumPremi as int
	declare @NumRigheEsaminate as int
	declare @IdRowGrad as int

	set @idDoc = @idPDA
		

	
	--------------------------------------------------------
	-- ripristino il valore del lotto nel caso in cui sia stato sovrascritto 
	-- dalla regola del secondo prezzo del calcolo anomalia
	--------------------------------------------------------
	update Document_MicroLotti_Dettagli 
		set  ValoreImportoLotto = ValoreImportoLottoOriginario, ValoreSconto = ValoreScontoOriginario
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc  and NumeroLotto = @NumeroLotto and Voce = 0
			and ValoreImportoLottoOriginario is not null

	update Document_MicroLotti_Dettagli 
		set   ValoreImportoLottoOriginario = null, ValoreScontoOriginario = null
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc  and NumeroLotto = @NumeroLotto and Voce = 0
			and ValoreImportoLottoOriginario is not null

	------------------------------------------------------
	------------------------------------------------------




	set @RegoleAggiudicatari=''
	set @ValorePosizione='Aggiudicatario provvisorio'
	set @bloccoAnomalia = 0

	select @numOfferteAmmesse = count(*)
		from Document_MicroLotti_Dettagli with(nolock)
		where IdHeader in 
					(
						select  IdRow 
							from Document_PDA_OFFERTE with(nolock)
							where idheader = @IdDoc 
									and StatoPDA in ( '2' ,'22' , '222') --ammessa=2 ammessa con riserva=22
					)
				and TipoDoc = 'PDA_OFFERTE'
				and NumeroLotto = @NumeroLotto
				--and isnull(Posizione ,'') = ''
				and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme') -- <> 'escluso'
				and Voce = 0


	--------------------------------------------------------
	-- svuoto le colonne utilizzate per le graduatorie
	--------------------------------------------------------
	update Document_MicroLotti_Dettagli 
		set  Aggiudicata = 0 , Exequo = 0, Graduatoria=null
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc  and NumeroLotto = @NumeroLotto and Voce = 0

	update Document_MicroLotti_Dettagli 
		set  Posizione = '' 
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc and isnull(Posizione,'') not in ( 'escluso' ,  'esclusoEco'  ) and NumeroLotto = @NumeroLotto and Voce = 0


	update 	Document_MicroLotti_Dettagli 
		set Statoriga = '' , Posizione = '' , Aggiudicata = 0
		where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
					
	

	declare @Indice  as int
	declare @ColonnaSort as float
	declare @ColonnaSortCur as float
	declare @Criterio as varchar(100)
	declare @CriterioAggiudicazioneGara as varchar(100)
	declare @CalcoloAnomalia as varchar(100)
	declare @OffAnomale as varchar(100)
	declare @dataInvio datetime

	set @Indice = 1
	set @ColonnaSort = 0
	set @Graduatoria = 1
	set @Exequo = 0
	set @CalcoloAnomalia = '0'


	-- determino il criterio di aggiudicazione della gara
	if exists( select id from ctl_doc where isnull( jumpcheck , '' ) <> '' and id = @idPDA)
	begin

		select	@idBando = pda.LinkedDoc,  
				@Criterio = criterioformulazioneofferte , 
				@CriterioAggiudicazioneGara = CriterioAggiudicazioneGara , 
				@CalcoloAnomalia = CalcoloAnomalia , 
				@OffAnomale = OffAnomale, 
				@RegoleAggiudicatari=isnull(RegoleAggiudicatari,''),
				--@TipoAggiudicazione=isnull(TipoAggiudicazione,''),
				@dataInvio = gara.DataInvio,
				@Conformita = Conformita,
				@idpfu = gara.IdPfu,
				@divisioneLotti = Divisione_lotti
				from Document_Bando with(nolock)
					inner join CTL_DOC pda with(nolock) on LinkedDoc = idheader
					inner join ctl_doc gara with(nolock) on gara.id = idHeader
				where pda.id = @IdDoc

	end
	else
	begin

		select	@idBando = LinkedDoc, 
				@Criterio = criterioformulazioneofferte , 
				@CriterioAggiudicazioneGara = CriterioAggiudicazioneGara,
				@dataInvio = a.ReceivedDataMsg 
				from TAB_MESSAGGI_FIELDS a
					inner join CTL_DOC on LinkedDoc = idMsg
				where id = @IdDoc
	end


	-- recupero se effettuare il calcolo dell'anomalia dalla scelta fatta per il lotto se presente
		
	select  @CalcoloAnomalia = CalcoloAnomalia ,@CriterioAggiudicazioneGara=CriterioAggiudicazioneGara,@Conformita=Conformita ,@TipoAggiudicazione=isnull(TipoAggiudicazione,'')
		from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO 
		where  @idBando =  idBando and ( @NumeroLotto = N_Lotto or N_Lotto is null )


	if @TipoAggiudicazione = '' 
		set @TipoAggiudicazione = 'MonoFornitore'


	-- si determina la graduatoria
	declare crs2 cursor static for 
		select Id , 
				--case when   @CriterioAggiudicazioneGara = '15532' or @Criterio =  '15537' -- percentuale : '15536' -- prezzo : 
				--	then -cast( ValoreOfferta as float ) --TotaleOffertaUnitario
				--	else cast( ValoreOfferta as float )-- -ScontoOffertoUnitario 
				--end
				cast( ValoreOfferta as float )
				as ColonnaSort

			from Document_MicroLotti_Dettagli 
			where IdHeader in 
						(
							select  IdRow 
								from Document_PDA_OFFERTE 
								where idheader = @IdDoc 
										and StatoPDA in ( '2' ,'22' ,'222') --ammessa=2 ammessa con riserva=22
						)
					and TipoDoc = 'PDA_OFFERTE'
					and NumeroLotto = @NumeroLotto
					and StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) --<> 'escluso'
					and Voce = 0
			order by ColonnaSort desc


	open crs2 
	fetch next from crs2 into @idRow , @ColonnaSort 
	if @@fetch_status=0 
		set @ColonnaSortCur = @ColonnaSort
	while @@fetch_status=0 
	begin 


		--if round( @ColonnaSort , 10 ) <> round( @ColonnaSortCur , 10 ) 
		if  @ColonnaSort  <>  @ColonnaSortCur 
		begin
			set @Graduatoria = @Indice
		end
			
		
		update Document_MicroLotti_Dettagli set Graduatoria = @Graduatoria where id = @idRow
		set @Indice = @Indice + 1 

		
		set @ColonnaSortCur = @ColonnaSort

		fetch next from crs2 into  @idRow , @ColonnaSort 
	end 
	close crs2 
	deallocate crs2



	--------------------------------------------------------
	-- si determina la graduatoria e si evince il primo e secondo classificato
	--------------------------------------------------------
	declare crs2 cursor static for 
		select Id  , round( cast( Graduatoria as float ) + ( isnull( Sorteggio , 0 ) / 100 ) , 5 )
			from Document_MicroLotti_Dettagli 
			where IdHeader in 
						(
							select  IdRow 
								from Document_PDA_OFFERTE 
								where idheader = @IdDoc 
										and StatoPDA in ( '2' ,'22','222') --ammessa=2 ammessa con riserva=22
						)
					and TipoDoc = 'PDA_OFFERTE'
					and NumeroLotto = @NumeroLotto
					and isnull(Posizione ,'') = ''
					and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme') -- <> 'escluso'
					and Voce = 0
			order by Graduatoria , isnull( Sorteggio , 0 )

	open crs2 

	--------------------------------------------------------
	--se non esite la regola per gli accordi QUADRI come prima
	--if @RegoleAggiudicatari=''
	--------------------------------------------------------
	if @TipoAggiudicazione = 'MonoFornitore'
	begin



		set @i = 1
		set @Last = 0
				
		fetch next from crs2 into @idRow , @Graduatoria 
		if @@fetch_status=0 
		begin

			set @Last = @Graduatoria
			--set @Posizione = 'Aggiudicatario provvisorio'
			set @Posizione = @ValorePosizione

			update Document_MicroLotti_Dettagli
				set Posizione = @Posizione
				where id = @idRow
			

			fetch next from crs2 into @idRow , @Graduatoria 

			while @@fetch_status=0 and @Posizione <> ''
			begin 

				
				if @Last <> @Graduatoria 
				begin 
					--if @Posizione = 'Aggiudicatario provvisorio' and @i < 2
					if @Posizione = @ValorePosizione and @i < 2
						set @Posizione = 'II Classificato'
					else
						set @Posizione = ''
				end

				-- aggiorno la posizione sugli exequo o al più sul secondo aggiudicatario
--				if @Posizione = 'Aggiudicatario provvisorio' or @i < 2
					update Document_MicroLotti_Dettagli
						set Posizione = @Posizione
						where id = @idRow


				set @Last = @Graduatoria
				set @i = @i + 1 

				fetch next from crs2 into  @idRow , @Graduatoria 
			end 

		end

		select @TipoDocPDA = TipoDoc  from CTL_DOC with (nolock) where id= @idDoc and TipoDoc <>'PDA_CONCORSO'

		if @TipoDocPDA <> 'PDA_CONCORSO'
		begin

			-- verifico la presenza dell'exequo
			if exists( select count(*)
							from Document_MicroLotti_Dettagli  m with (nolock)
								inner join dbo.Document_PDA_OFFERTE o with (nolock) on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
							where	NumeroLotto = @NumeroLotto
									and o.IdHeader = @idDoc
									--and Posizione = 'Aggiudicatario provvisorio'
									and Posizione = @ValorePosizione
									and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) -- <> 'escluso'
									and Voce = 0
									group by Posizione 
									having count(*) > 1
					)
				set @Exequo = 1
			else
				set @Exequo = 0
		end
		else
		begin
			
			set @NumPremi=0

			--recupero numero premi dal concorso
			select @NumPremi = COUNT(*) --into #Premi
				from ctl_Doc_value  C  with (nolock)
					inner join ctl_Doc_value  P  with (nolock) on P.IdHeader = C.IdHeader and P.row = C.row and P.DZT_Name ='ImportiVari'
				where 
					C.idheadeR = @idBando and C.DSE_ID = 'InfoTec_DefinizionePremi_griglia' and C.dzt_name='classifica'
			

			declare @GraduatoriaCurr as int
			declare @SorteggioCurr as int
			declare @Graduatoria_Con as int
			declare @Sorteggio_Con as int

			set @NumRigheEsaminate = 0
			set @GraduatoriaCurr = 0
			set @SorteggioCurr =0

			--cursore ordinato per order by m.Graduatoria , ISNULL(Sorteggio , 0)
			DECLARE crsGradCon CURSOR STATIC FOR 
				
				select 
					Graduatoria,ISNULL(Sorteggio , 0) as Sorteggio 
						from Document_MicroLotti_Dettagli  m with (nolock)
							inner join dbo.Document_PDA_OFFERTE o with (nolock) on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
						where	NumeroLotto = @NumeroLotto and o.IdHeader = @idDoc
								and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) -- <> 'escluso'
								and Voce = 0
						order by Graduatoria , ISNULL(Sorteggio , 0)

			OPEN crsGradCon

			FETCH NEXT FROM crsGradCon INTO @Graduatoria_Con, @Sorteggio_Con
			WHILE @@FETCH_STATUS = 0  and  @NumRigheEsaminate < @NumPremi + 1
			BEGIN
				
				set @NumRigheEsaminate = @NumRigheEsaminate +1

				--controllo se ho un ex-equo
				--cerco gli ex-equo fino a tante righe quanti sono i premi
				if @Graduatoria_Con = @GraduatoriaCurr and @Sorteggio_Con = @SorteggioCurr
				begin

					--setto ex-quo sulle righe con stessa graduotoria e stesso sorteggio 
					update 
						M
						set 
							M.Exequo = 1, M.Aggiudicata = idAziPartecipante 
						from 
							Document_MicroLotti_Dettagli M
								inner join dbo.Document_PDA_OFFERTE o with (nolock) on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE'
						where 
							NumeroLotto = @NumeroLotto and o.IdHeader = @idDoc
							and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )
							and Voce = 0
							and M.Graduatoria = @GraduatoriaCurr and ISNULL(Sorteggio,0) = @SorteggioCurr
					
				end
				
				--aggiorno i valori correnti
				set @GraduatoriaCurr = @Graduatoria_Con
				set @SorteggioCurr = @Sorteggio_Con 

				FETCH NEXT FROM crsGradCon INTO @Graduatoria_Con, @Sorteggio_Con
			END

			CLOSE crsGradCon 
			DEALLOCATE crsGradCon 
			
			--controllo se ho ex-quo
			if exists (
				
					select Id from 
						Document_MicroLotti_Dettagli M with (nolock) 
								inner join dbo.Document_PDA_OFFERTE o with (nolock) on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE'
						where 
							NumeroLotto = @NumeroLotto and o.IdHeader = @idDoc
							and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )
							and Voce = 0 and Exequo = 1
							
				)
			begin
				set @Exequo = 1
			end
			else
			begin
				set @Exequo = 0
			end


		end
	end


	--se esiste la regola per gli aggiudicatari accordi quadri =tutti setto tutti ad aggiudicatorio provvisorio
	if @RegoleAggiudicatari  = 'tutti'
	begin
			
		set @ValorePosizione='Idoneo provvisorio'


		fetch next from crs2 into  @idRow , @Graduatoria 
		while @@fetch_status=0 
		begin 

				update Document_MicroLotti_Dettagli
					set Posizione = @ValorePosizione
					where id = @idRow

			fetch next from crs2 into  @idRow , @Graduatoria 

		end 


	end
	else
	begin
		-- in alternativa nel caso di multi fornitore vanno riproposti gli idonei non esclsui precedentemente inseriti nella % di assegnazione
		--deve esistere il documento confermato  di graduatoria aggiudicazione	
		if @TipoAggiudicazione = 'MultiFornitore' 
			and exists( select id from ctl_doc where deleted = 0 and TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and statofunzionale in ( 'Confermato' )
													and linkedDoc in (select id from Document_MicroLotti_Dettagli 
																				where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' ) 
							)
		begin 
			set @ValorePosizione='Idoneo provvisorio'


			fetch next from crs2 into  @idRow , @Graduatoria 
			while @@fetch_status=0 
			begin 

					update Document_MicroLotti_Dettagli
						set Posizione = @ValorePosizione
						where id = @idRow and ISNULL( percAgg , 0 ) <> 0

				fetch next from crs2 into  @idRow , @Graduatoria 

			end 
		end						

	end


	close crs2 
	deallocate crs2




	--DA FARE SOLO PER PDA DIVERSO PDA_CONCORSO  ??
	if @TipoDocPDA <> 'PDA_CONCORSO'
	begin
		-- assegno l'aggiudicatario provvisorio con l'exequo
		update Document_MicroLotti_Dettagli  
				set   Aggiudicata = idAziPartecipante , Exequo = @Exequo
			from 
				Document_MicroLotti_Dettagli  m
					inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
			where   NumeroLotto = @NumeroLotto
					--and Graduatoria = 1
					and o.IdHeader = @idDoc
					--and Posizione = 'Aggiudicatario provvisorio'
					and Posizione = @ValorePosizione
					and Voce = 0
	end
	else
	begin
			--CASO CONCORSI se non ci sono EX-EQUO aggiorno l'aggiudicataria provv
			if @Exequo = 0
			begin
				--aggiorno l'aggiudicatario sul lotto offerto
				update Document_MicroLotti_Dettagli  
					set   Aggiudicata = idAziPartecipante , Exequo = 0
				from 
					Document_MicroLotti_Dettagli  m
						inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
				where   NumeroLotto = @NumeroLotto
						--and Graduatoria = 1
						and o.IdHeader = @idDoc
						--and Posizione = 'Aggiudicatario provvisorio'
						and Posizione = @ValorePosizione
						and Voce = 0
			end
	end


	-- azzera la l'aggiudicatario sulla PDA 
	update m set Exequo = 0 , m.Aggiudicata = 0 
		from Document_MicroLotti_Dettagli m 
			inner join (
				select NumeroLotto as NumLot
						, id as idMsg
						from Document_MicroLotti_Dettagli
						where IdHeader in ( select idrow from Document_PDA_OFFERTE  where IdHeader = @idDoc ) 
							and Aggiudicata > 0
							and TipoDoc = 'PDA_OFFERTE'
							and Voce = 0
				) as  a on  NumeroLotto = NumLot
		where IdHeader = @idDoc   and TipoDoc = 'PDA_MICROLOTTI' and NumeroLotto = @NumeroLotto and Voce = 0


	-- riporto sulla PDA i dati del aggiudicatario
	-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
	declare @SQL varchar(4000)
	set @SQL = '
		select idMsg , m.id 
		from Document_MicroLotti_Dettagli m 
			inner join (
				select NumeroLotto as NumLot
						, id as idMsg
						from Document_MicroLotti_Dettagli
						where IdHeader in ( select idrow from Document_PDA_OFFERTE  where IdHeader = ' + cast ( @idDoc as varchar ) + ' ) 
							and Aggiudicata > 0
							and TipoDoc = ''PDA_OFFERTE''
				) as  a on  NumeroLotto = NumLot
		where IdHeader = ' + cast( @idDoc  as varchar ) + ' and TipoDoc = ''PDA_MICROLOTTI'' and NumeroLotto = ''' + @NumeroLotto + ''' and Voce = 0
	'
	
		
	exec COPY_DETTAGLI_MICROLOTTI @sql , ',ValoreImportoLotto,Cig,Descrizione'


	-- aggiorno lo stato del lotto
	update 	Document_MicroLotti_Dettagli 
		set Statoriga = case when Exequo = 1 then 'Exequo' else 'AggiudicazioneProvv' end
		where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	
	--nel caso dei concorsi posso avere ex-equo a qualsiasi livello allora lo riaggiorno
	--la riga della PDA
	if @TipoDocPDA = 'PDA_CONCORSO'  
	begin
		
		if @Exequo = 1
		begin

			update 	
				Document_MicroLotti_Dettagli 
					set Statoriga =  'Exequo'
				where 
					idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
		end
		else
		begin
		
			--aggiorno la riga della PDA MICROLOTTI
			update 	Document_MicroLotti_Dettagli 
				set Statoriga = 'AggiudicazioneProvv' 
				where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
		end
	end
	
	

	-- nel caso in cui ci siano più aggiudicatari tolgo il riferimento
	--if @RegoleAggiudicatari <> ''
	if @TipoAggiudicazione = 'MultiFornitore'
	begin
		update 	Document_MicroLotti_Dettagli 
			set  Aggiudicata=0
			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	end

	--if @RegoleAggiudicatari=''
	--begin
	--	-- aggiorno lo stato del lotto
	--	update 	Document_MicroLotti_Dettagli 
	--		set Statoriga = case when Exequo = 1 then 'Exequo' else 'AggiudicazioneProvv' end
	--		where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	--end
	--else
	--begin
	--	if @RegoleAggiudicatari='tutti'
	--	begin
	--		update 	Document_MicroLotti_Dettagli 
	--			set Statoriga = case when Exequo = 1 then 'Exequo' else 'AggiudicazioneProvv' end , Aggiudicata=0
	--			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	--	end
	--end

		
	---- se alla fine nessun fornitore si è aggiudicato il lotto lo stato del lotto viene posto a NonAggiudicabile
	if not exists( select m.id
						from Document_MicroLotti_Dettagli  m
							inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
						where	NumeroLotto = @NumeroLotto
								and o.IdHeader = @idDoc
								--and ( Posizione <> '' or ( Posizione = '' and @RegoleAggiudicatari <> '' ) ) -- è stato messo un aggiudicatario
								and StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) -- <> 'escluso'
								and Voce = 0
				)

	begin

		update 	Document_MicroLotti_Dettagli 
			set Statoriga = 'NonAggiudicabile' , Posizione = '' , Aggiudicata = null , Exequo = null
			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
			
		IF dbo.OCP_isActive( @idBando, @idpfu ) = 1
		BEGIN

			IF isnull(@divisioneLotti,'') = '0'
			BEGIN

				EXEC OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO @IdBando, @idpfu, 0, 17, NULL, NULL, 'NonAggiudicabile'
				exec DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI @IdBando,@idpfu, NULL

			END
			ELSE
			BEGIN

				EXEC OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO @IdBando, @idpfu, 0, 17, @numeroLotto, NULL, 'NonAggiudicabile'
				exec DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI @IdBando,@idpfu, @numeroLotto

			END

			exec OCP_ISTANZIA_ESITO_CREATE_FROM_ESITO @IdBando , @idpfu

		END


		
		--INVIO DELLA SCHEDA NAG PER GARE SOTTOSOGLIA
		--SE INTEROPERABILITà è ATTIVA
		--IF dbo.attivo_INTEROP_Gara( @idBando ) = 1
		--BEGIN
		--	DECLARE @CIG VARCHAR(MAX)
		--	DECLARE @TipoSoglia VARCHAR(MAX)

		--	--RECUPERO LE INFO DELLA GARA
		--	SELECT @TipoSoglia=TipoSoglia, @CIG=CIG
		--		FROM Document_Bando WITH(NOLOCK)			
		--			WHERE idHeader = @idBando

		--	IF isnull(@divisioneLotti,'') = '0'
		--	BEGIN
		--		--CHIAMO LA STORED PER LE SCHEDE DI NON AGG
		--		EXEC PCP_NON_AGGIUDICAZIONE_LOTTI @idPfu, @CIG, 'TERMINE_VAL_ECO', @idBando, @idDoc, @TipoSoglia
		--	END
		--	ELSE
		--	BEGIN
		--		SET @CIG = '';

		--		--RECUPERO IL CIG DEL LOTTO
		--		select @CIG = CIG from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idDoc AND NumeroLotto = @NumeroLotto;

		--		IF NOT (@CIG = '')
		--		BEGIN					
		--				EXEC PCP_NON_AGGIUDICAZIONE_LOTTI @idPfu, @CIG, 'TERMINE_VAL_ECO', @idBando, @idDoc, @TipoSoglia
		--		END

		--	END

		--END
			
	end


	--Evito l'innesco del calcolo anomalia nel caso in cui le offerte ammesse sono < 5 , la gara è al prezzo e la data invio bando è >= 20-05-2017
	IF ( convert( varchar(10) , @dataInvio , 121 ) >= '2017-05-20' and @numOfferteAmmesse < 5 and @CriterioAggiudicazioneGara = 15531 )
		or
		-- dal 18 aprile 2019 le OEV non prevedono il calcolo anomalia in presenza di un numero di offerte inferiori a 3
		( convert( varchar(10) , @dataInvio , 121 ) >= '2019-04-19' and @numOfferteAmmesse < 3 and @CriterioAggiudicazioneGara = 15532 )
	BEGIN
		set @bloccoAnomalia = 1
	END
	ELSE
	BEGIN

		-- aggiorno lo stato del lotto
		-- se il lotto puo essere aggiudicato ma è necessario effettuare la verifica dell'anomalia
		if @CalcoloAnomalia = '1' 
				and exists( select id from Document_MicroLotti_Dettagli where Statoriga = 'AggiudicazioneProvv' and idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' )
				--non deve esistere il documento di verifica anomalia
				and not exists( select id from ctl_doc where deleted = 0 and TipoDoc = 'VERIFICA_ANOMALIA' and statofunzionale not in ( 'Annullato' )
														and linkedDoc in (select id from Document_MicroLotti_Dettagli 
																					where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' ) 
																					)
		begin
			update 	Document_MicroLotti_Dettagli 
				set Statoriga = 'VerificaAnomalia' 
				where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
		end

	END



	---------------------------------------------------------------
	-- cambiato il diagramma degli stati chiedendo prima la percentuale di aggiudicazione e poi la giustificazione dei prezzi
	---------------------------------------------------------------

	-- Nel caso in cui ci sia la regola del fornitore multiplo si deve definire o l'idonetà oppure la percentuale di assegnazione
	if @TipoAggiudicazione = 'MultiFornitore' 
			and exists( select id from Document_MicroLotti_Dettagli where Statoriga = 'AggiudicazioneProvv' and idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' )
			--non deve esistere il documento confermato 
			and not exists( select id from ctl_doc where deleted = 0 and TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and statofunzionale IN ( 'Confermato' ) --  not in ( 'Annullato' )
													and linkedDoc in (select id from Document_MicroLotti_Dettagli 
																				where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' ) 
																				)
	begin
		update 	Document_MicroLotti_Dettagli 
			set Statoriga = 'PercAggiudicazione' 
			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	end

					
	-- se il lotto è in aggiudicazione provvisoria oppure in  Exequo e l'aggiudicatario è sospetto anomalo occorre giustificare il prezzo
	if exists( select id from Document_MicroLotti_Dettagli where Statoriga in ( 'Exequo', 'AggiudicazioneProvv') and idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' )
		and exists( 
				
				--per le gare con aggiudicazione singola
				select id 
					from Document_MicroLotti_Dettagli d with(nolock)
						inner join Document_PDA_OFFERTE o with(nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
					where o.IdHeader = @idPDA  and NumeroLotto = @NumeroLotto and Voce = 0 
							and StatoRiga = 'SospettoAnomalo' 
							and 
								
							( 
								--monofornitore deve assere agg. provvisorio	
								( 
								Posizione = @ValorePosizione --and Posizione = 'Aggiudicatario provvisorio' 
								and @TipoAggiudicazione='MonoFornitore'
								)
								or 
								--multifornitore basta che esiste un sospetto anomalo
								(  @TipoAggiudicazione='MultiFornitore' and isnull( d.percagg , 0 ) <> 0  )

							)

				--union all
				
				----per le gara con aggiudicazione multipla tutti i fornitori aggiudicatari non devono stare sospetto anomalo per quel lotto
				--select OD.id 
				--	from Document_MicroLotti_Dettagli PDALOTTI with(nolock)
				--			inner join CTL_DOC PGA with(nolock) on PGA.LinkedDoc = PDALOTTI.Id and PGA.TipoDoc='PDA_GRADUATORIA_AGGIUDICAZIONE' and PGA.Deleted=0 and PGA.StatoFunzionale='Confermato'
				--			inner join Document_MicroLotti_Dettagli PGADETT with(nolock) on PGADETT.IdHeader = PGA.Id and PGADETT.TipoDoc = PGA.tipodoc
				--			inner join Document_PDA_OFFERTE O with(nolock)on O.idheader = PDALOTTI.IdHeader  and O.idAziPartecipante = PGADETT.aggiudicata and ISNULL(PGADETT.PercAgg,0)>0 
				--			inner join Document_MicroLotti_Dettagli OD with(nolock) on OD.idheader = O.idrow and  OD.TipoDoc = 'PDA_OFFERTE' and OD.NumeroLotto = PDALOTTI.NumeroLotto
				--	where PDALOTTI.IdHeader=@idPDA and PDALOTTI.NumeroLotto=@NumeroLotto and PDALOTTI.Voce = 0 
				--			and OD.StatoRiga = 'SospettoAnomalo' 
				--			and @TipoAggiudicazione = 'MultiFornitore'

					)	
	begin
		update 	Document_MicroLotti_Dettagli 
			set Statoriga = 'GiustificazionePrezzi' 
			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	end


	---- Nel caso in cui ci sia la regola del fornitore multiplo si deve definire o l'idonetà oppure la percentuale di assegnazione
	--if @TipoAggiudicazione = 'MultiFornitore' 
	--		and exists( select id from Document_MicroLotti_Dettagli where Statoriga = 'AggiudicazioneProvv' and idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' )
	--		--non deve esistere il documento confermato 
	--		and not exists( select id from ctl_doc where deleted = 0 and TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and statofunzionale IN ( 'Confermato' ) --  not in ( 'Annullato' )
	--												and linkedDoc in (select id from Document_MicroLotti_Dettagli 
	--																			where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' ) 
	--																			)
	--begin
	--	update 	Document_MicroLotti_Dettagli 
	--		set Statoriga = 'PercAggiudicazione' 
	--		where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI'
	--end
		

	--ENRPAN se la conformità è ex-post ed è stata conclusa la fase di conformità sul lotto setto lo stato del lotto  a "Controllato"
	if @Conformita = 'Ex-Post'
	begin
		if
			
			exists( select id from Document_MicroLotti_Dettagli where Statoriga = 'AggiudicazioneProvv' and idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' )
			and
			exists (
	
				select  c.id
					from CTL_DOC c with (nolock)
						inner join Document_MicroLotti_Dettagli righe with (nolock) ON righe.idheader = c.id and righe.tipodoc = 'CONFORMITA_MICROLOTTI' 
															and righe.numerolotto = @NumeroLotto and StatoRiga = 'Controllato'
					where c.linkeddoc = @idPDA and c.TipoDoc = 'CONFORMITA_MICROLOTTI' and c.Deleted = 0 and c.StatoFunzionale ='CONCLUSA'
			)

		begin
			update 	Document_MicroLotti_Dettagli 
				set Statoriga = 'Controllato' 
				where idheader = @idPDA and NumeroLotto = @NumeroLotto and Voce = 0 and TipoDoc = 'PDA_MICROLOTTI' and Statoriga = 'AggiudicazioneProvv'

		end
	end


	-- CALCOLO DELL'ANOMALIA SUL METODO B TRAMITE ESCLUSIONE AUTOMATICA (SECONDO PREZZO)

	EXEC [PDA_CALCOLO_DEL_SECONDO_PREZZO]  @idBando , @idDoc, @NumeroLotto


end































GO
