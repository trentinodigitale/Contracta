USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CAMBIA_OFFERTA_CREATE_FROM_CRITERIO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE   PROCEDURE [dbo].[OLD2_CAMBIA_OFFERTA_CREATE_FROM_CRITERIO] 
	( @idDoc int -- rappresenta l'id dela riga del criterio , legato al punteggio ,legato all'offerta della PDA, sul quale si fa la valutazione
	, @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @IdDocVal as INT
	declare @AttDZT_NAME  as varchar(200)
	declare @ModelloBase  as varchar(200)
	declare @NumeroLotto  as varchar(200)
	declare @idHeaderLottoOfferto int
	

	declare @idDocRL as int
	declare @Divisione_lotti varchar(20)

	-- riporto i dati dell'offerta per consentirne di cambiare i valori
	declare @CriterioValutazione varchar(20)
	declare @DescrizioneCriterio nvarchar(255)
	declare @Modello nvarchar(255)
	declare @PunteggioMax varchar(50)
	declare @Punteggio varchar(50)
	declare @Formula  nvarchar(4000)
	declare @AttributoCriterio nvarchar(255)
	declare @DZT_Type nvarchar(255)


	declare @idRow int 
	declare @Row int 

	declare @Numeroriga int
	declare @Voce int
	declare @statmentSQL		varchar(4000)
	declare @idRiga int

	declare @ValoreOffertaNum float
	declare @ValoreOffertaTxt nvarchar(max)



	-- risalgo alla riga del lotto offerto dove è inperneata la valutazione del criterio
	select @idDocRL = idHeaderLottoOff from Document_Microlotto_PunteggioLotto with(nolock) where idRow = @IdDoc

	set @Errore = ''
	-- cerco una versione precedente del documento confermato
	set @id = null
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CAMBIA_OFFERTA' ) and statofunzionale in (  'Confermato' )


	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and bReadDocumentazione = '1' )
	--begin
	--	set @Errore = 'Per effettuare la valutazione tecnica è necessario prima aprire la relativa busta tecnica' 
	--end

	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga = 'escluso' )
	--begin

	--	if @id is null
	--	begin
	--		set @Errore = 'Non è possibile la valutazione tecnica se il lotto e'' stato escluso' 
	--	end

	--end

	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga not in ( 'inVerifica' , 'daValutare' , 'Valutato') )
	--begin
	
	--	if @id is null
	--	begin
	--		set @Errore = 'Lo stato del lotto non consente la valutazione' 
	--	end
	--end

	set @IdDocVal = null
	
	if not exists( select id from CTL_DOC with(nolock) where LinkedDoc = @idDocRL and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'Confermato' , 'InLavorazione' ))
	begin

		set @Errore = 'Non e'' possibile Modificare i valori di una offerta se non esiste il documento di valutazione tecnica' 

	end


	set @IdDocVal = null
	set @id = null

	-- Se il documento di valutazione è confermato non si puo creare il documento al più si puo aprire quello di cambia offerta confermato
	select @IdDocVal = id from CTL_DOC with(nolock) where LinkedDoc = @idDocRL and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'Confermato' ) --, 'InLavorazione' )
		
	-- se il documento di valutazione è confermato posso solo aprire un documento esistente
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CAMBIA_OFFERTA' ) and statofunzionale in (  'Confermato' )

	if @IdDocVal is not null and @id is null
	begin
		set @Errore = 'Non e'' presente un documento di Cambio valori per il criterio selezionato e non puo'' essere creato per valutazioni confermate' 
	end


	if @IdDocVal is not null  and  @id is not null -- se la valutazione è confermata posso solo aprire il confermato
		set @id = @id
	else
	begin
		if @Errore = ''  --and @id is  null
		begin

			-- recupera l'ultimo documento in lavorazione se esiste
			set @id = null
			select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CAMBIA_OFFERTA' ) and statofunzionale in (  'InLavorazione' )

			if @id is null
			begin

					select @IdDocVal = id from CTL_DOC with(nolock) where LinkedDoc = @idDocRL and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'InLavorazione' )


					-- recupero la colonna oggetto del cambiamento ed i criteri per la compilazione
					select   @CriterioValutazione = CriterioValutazione, @DescrizioneCriterio = DescrizioneCriterio, @AttributoCriterio  = AttributoCriterio 
							, @DZT_Type = DZT_Type , @Divisione_lotti = Divisione_lotti ,  @Modello = 'MODELLI_LOTTI_' + TipoBando  + '_MOD_OffertaINPUT'
							, @NumeroLotto = lo.NumeroLotto , @idHeaderLottoOfferto = lo.IdHeader
					from Document_Microlotto_PunteggioLotto p  with(nolock)
						inner join Document_Microlotto_Valutazione v with(nolock) on p.idRowValutazione = v.idRow
						inner join LIB_Dictionary d with(nolock) on d.DZT_Name = dbo.GetPos(AttributoCriterio, '.', 2 )
						inner join Document_MicroLotti_Dettagli lo with(nolock) on lo.id = p.idheaderlottooff
						inner join Document_PDA_OFFERTE o with(nolock) on o.IdRow = lo.idHeader
						inner join CTL_DOC pda with(nolock) on o.idHeader = pda.id
						inner join Document_Bando ba with(nolock) on ba.idHeader = pda.LinkedDoc
						where p.idRow = @idDoc
				
					-- recupera il campo oggetto della modifica
					set @AttDZT_NAME = dbo.GetPos(@AttributoCriterio, '.', 2 )


				   -- altrimenti lo creo
					INSERT into CTL_DOC (
								IdPfu,  TipoDoc, 
								Titolo, Body, Azienda,  
								ProtocolloRiferimento, Fascicolo, LinkedDoc , JumpCheck , idDoc )
						select 
							@IdUser as idpfu , 'CAMBIA_OFFERTA' as TipoDoc ,  
							left( 'Modifica dati offerti: ' + aziRagioneSociale + ' - Lotto ' + @NumeroLotto  , 150 )  as Titolo, '' Body, idAziPartecipante as  Azienda,  
							ProtocolloRiferimento, Fascicolo, @idDoc as LinkedDoc , @AttDZT_NAME , isnull( @IdDocVal , 0 ) 
							from Document_MicroLotti_Dettagli d with(nolock) 
								inner join Document_PDA_OFFERTE o with(nolock) on o.IdRow = d.idHeader
								inner join Document_PDA_TESTATA t with(nolock) on o.idHeader = t.idHeader
								inner join CTL_DOC b with(nolock) on o.idHeader = b.id
								where d.id = @idDocRL


					set @id = @@identity



					-- creo il modello dinamico se non esiste per consentire la compilazione dei valori
					declare @NomeModello varchar(100)
					set @NomeModello = 'CAMBIA_OFFERTA_VALORI_PRODOTTI_' + cast( @idDoc as varchar(20))

					if not exists( select MOD_ID from CTL_Models with(nolock) where MOD_ID = @NomeModello  ) 
					begin

						-- determina che modello usare come base
						-- apertura lotti Lotto voce o numero riga
						-- numerico o testo?
						set @ModelloBase = 'CAMBIA_OFFERTA_VALORI_PRODOTTI_BASE'
						if @DZT_Type = 2 -- campo numerico
							set @ModelloBase = @ModelloBase + '_NUMERICO'
						else
							set @ModelloBase = @ModelloBase + '_ALFABETICO'

						if @Divisione_lotti = '0' -- campo numerico
							set @ModelloBase = @ModelloBase + '_MONOLOTTO'
						else
							set @ModelloBase = @ModelloBase + '_LOTTI'

						-- crea un modello partendo dalla base
						exec CopiaModello  @NomeModello  , @ModelloBase , 'CAMBIA_OFFERTA'

						-- ci si aggiunge la colonna definita dal criterio
						insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
							select @NomeModello ,@AttDZT_NAME , MA_DescML ,  100 as MA_Pos ,  MA_Len, 100 as MA_Order, 'CAMBIA_OFFERTA'
								from CTL_ModelAttributes with(nolock)	
								where MA_MOD_ID = @Modello and  @AttDZT_NAME = MA_DZT_Name

					end


					-- associo il modello alla sezione per la compilazione
					insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
						values ( @id , 'VALORI_PRODOTTI' , @NomeModello )




					-- cerco una versione precedente se esiste
					declare @idPrev int
					set @idPrev = null
					select @idPrev = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CAMBIA_OFFERTA' ) and statofunzionale in (  'Confermato' )

					if @idPrev is not null
					begin
						
						-- recupero le note precedenti
						declare @Note nvarchar(max) 
						select @Note = Note from CTL_Doc with(nolock) where id = @idPrev
						update CTL_DOC set Note = @Note where id = @id

						-- se esiste una versione precedente ricopiamo tutti i dati per la compilazione
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
								from CTL_DOC_Value with(nolock)
								where idheader = @idPrev

					end
					else
					begin




						set @Row = 0



						-- riporto i dati dell'offerta sul documento
						declare crsOf cursor static for 
							select  
								 id , NumeroRiga ,  voce
							from Document_MicroLotti_Dettagli d  with(nolock)
								where d.IdHeader =  @idHeaderLottoOfferto  and d.NumeroLotto = @NumeroLotto
								order by d.id

					

						open crsOf 
						fetch next from crsOf into  @idRiga , @Numeroriga  , @Voce

						while @@fetch_status=0 
						begin 
					
				
							insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'VALORI_PRODOTTI' , @Row, 'idHeaderLotto' , @idRiga )

							insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'VALORI_PRODOTTI' , @Row, 'NumeroLotto' , @NumeroLotto )

							insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'VALORI_PRODOTTI' , @Row, 'Voce' , @Voce )

							insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'VALORI_PRODOTTI' , @Row, 'NumeroRiga' , @Numeroriga )


							-- recupera il valore imputato da variare -- DA MIGLIORARE
							if @DZT_Type = 2 -- campo numerico
							begin

								select cast( 0.0 as float) as ValoreTemporaneo into #Temp
								set @statmentSQL = ' update #Temp set ValoreTemporaneo = ' + @AttDZT_NAME + ' from #Temp ,Document_MicroLotti_Dettagli where Id = ' + cast(  @idRiga as varchar(20) )
								exec( @statmentSQL  )
								select @ValoreOffertaNum =  isnull(ValoreTemporaneo ,'') from #Temp
								drop table #Temp


								insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
									values(  @id , 'VALORI_PRODOTTI' , @Row, 'CampoNumerico' , str( @ValoreOffertaNum , 30 , 10 ) )

								insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
									values(  @id , 'VALORI_PRODOTTI' , @Row, @AttDZT_NAME , str( @ValoreOffertaNum , 30 , 10 ) )

							END
							else
							begin -- campo testo

								select cast( '' as nvarchar( max)) as ValoreTemporaneo into #Temp2
								set @statmentSQL = ' update #Temp2 set ValoreTemporaneo = ' + @AttDZT_NAME + ' from #Temp2 ,Document_MicroLotti_Dettagli where Id = ' + cast(  @idRiga as varchar(20) )
								exec( @statmentSQL  )
								select @ValoreOffertaTxt =  isnull(ValoreTemporaneo ,'') from #Temp2
								drop table #Temp2


								insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
									values(  @id , 'VALORI_PRODOTTI' , @Row, 'CampoTesto' , @ValoreOffertaTxt )

								insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
									values(  @id , 'VALORI_PRODOTTI' , @Row, @AttDZT_NAME , @ValoreOffertaTxt )

							end


							set @Row = @Row + 1 

							fetch next from crsOf into  @idRiga , @Numeroriga  , @Voce
						end 
						close crsOf 
						deallocate crsOf

					end





			end
		end
	end		
	



	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END







GO
