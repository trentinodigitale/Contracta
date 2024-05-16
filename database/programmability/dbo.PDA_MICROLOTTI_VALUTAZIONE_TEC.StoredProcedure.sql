USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_VALUTAZIONE_TEC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  Proc  [dbo].[PDA_MICROLOTTI_VALUTAZIONE_TEC]( @IdDoc int  , @IdPFU as int , @InCorsodiVAlutazione int = 1) as
BEGIN

	SET NOCOUNT ON --aggiunto per far risalire correttamente l'errore al processo chiamante

	declare @CriterioAggiudicazioneGara varchar(20)

	declare @IdLotto as Int 
	declare @idEsclusione as Int 
	
	--declare @IdPFU as Int 
	declare @IdPDA as Int 
	declare @IdCom as Int 
	declare @pfuIdLng as Int 
	declare @Allegato as Varchar(255) 
	declare @StatoRiga as Varchar(255) 
	declare @NumeroLotto as Varchar(255) 
	declare @idBando int

	--declare @idDoc int
	declare @Criterio as varchar(100)
	declare @TipoDoc as varchar(100)
	declare @Fascicolo as varchar(100)

	declare @ListaModelliMicrolotti as varchar(500)
	declare @FormulaEconomica as nvarchar (4000)
	declare @strSql as nvarchar (4000)

	declare @FormulaEcoSDA as nvarchar (4000)
	declare @MAX_PunteggioTecnico		float
	declare @MAX_PunteggioEconomico		float
	declare @ValoreEconomico			float
	declare @OffertaMigliore			float
	declare @PunteggioTecMin			float
	declare @Coefficiente_X				float
	declare @NumeroDecimali				float


	declare @Valore_Offerta				float
	declare @Media_Valori_Offerti		float
	declare @Massimo_Valore_Offerta		float
	declare @Minimo_Valore_Offerta		float
	declare @PunteggioTEC_100			varchar(10)
	declare @PunteggioTEC_TipoRip		varchar(10)


	declare @PunteggioTecnico			float
	declare @PunteggioTecnicoMax		float
	declare @RiparametroCriterio		int
	declare @PunteggioCriterioMax		float
	declare @GiudizioCriterioMax		float
	
	declare @idRowValutazione			int
	declare @Conformita					varchar(20)

	set @PunteggioTecnicoMax = 0
	set @RiparametroCriterio = 0

	declare @IdLottop					as Int 
	declare @PunteggioOriginale			as float
	declare @DescrizioneCriterio		as nvarchar(4000)
	declare @PunteggioMin				as float
	declare @PunteggioRiparametrato		as float
	declare @PunteggioNonRiparametrato		as float
	
	declare @Motivazione				as nvarchar(MAX)
	declare @ModAttribPunteggio			as varchar(50)
	
	declare @bGaraAlotti INT

	set @bGaraAlotti = 0

	declare @RicalcoloSeCiSonoEsclusioni  as varchar(50)
	--set @IdDoc=<ID_DOC> 
	--set @IdPFU=<ID_USER>


	set @RicalcoloSeCiSonoEsclusioni = '1'

	-- determino il criterio di calcolo economico definito sulla gara
	select  @TipoDoc = o.TipoDoc , @Criterio = b.criterioformulazioneofferte , @ListaModelliMicrolotti = b.TipoBando
			, @MAX_PunteggioEconomico = v1.Value
			, @MAX_PunteggioTecnico   = v2.Value
			, @FormulaEcoSDA          = v3.Value
			, @PunteggioTecMin		  = v4.Value
			, @Coefficiente_X		  = v5.Value
			, @NumeroDecimali		  = isnull( b.NumDec , 5 )
			, @PunteggioTEC_100		  = isnull( v6.Value , '0' ) 
			, @PunteggioTEC_TipoRip   = isnull( v7.Value , '0' ) 
			, @Conformita			  = b.Conformita
			, @CriterioAggiudicazioneGara = b.CriterioAggiudicazioneGara
			, @idPDA				  = o.id
			, @NumeroLotto			  = P.NumeroLotto
			, @idBando = o.LinkedDoc
			, @Fascicolo = o.Fascicolo  
			, @bGaraAlotti = case when b.Divisione_lotti = '0' then 0 else 1 end
		FROM Document_MicroLotti_Dettagli P WITH(NOLOCK)
				inner join ctl_doc o WITH(NOLOCK) on p.idheader = o.id
				inner join dbo.Document_Bando b WITH(NOLOCK) on o.LinkedDoc = b.idHeader
				inner join CTL_DOC_VALUE  v1 WITH(NOLOCK) on v1.idheader = b.idHeader and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioEconomico'
				inner join CTL_DOC_VALUE  v2 WITH(NOLOCK) on v2.idheader = b.idHeader and v2.DSE_ID = 'CRITERI_ECO' and  v2.DZT_Name = 'PunteggioTecnico'
				inner join CTL_DOC_VALUE  v3 WITH(NOLOCK) on v3.idheader = b.idHeader and v3.DSE_ID = 'CRITERI_ECO' and  v3.DZT_Name = 'FormulaEcoSDA'
				inner join CTL_DOC_VALUE  v4 WITH(NOLOCK) on v4.idheader = b.idHeader and v4.DSE_ID = 'CRITERI_ECO' and  v4.DZT_Name = 'PunteggioTecMin'
				inner join CTL_DOC_VALUE  v5 WITH(NOLOCK) on v5.idheader = b.idHeader and v5.DSE_ID = 'CRITERI_ECO' and  v5.DZT_Name = 'Coefficiente_X'
				left outer join CTL_DOC_VALUE v6 WITH(NOLOCK) on v6.idheader = b.idHeader and v6.DSE_ID = 'CRITERI_ECO' and  v6.DZT_Name = 'PunteggioTEC_100'
				left outer join CTL_DOC_VALUE v7 WITH(NOLOCK) on v7.idheader = b.idHeader and v7.DSE_ID = 'CRITERI_ECO' and  v7.DZT_Name = 'PunteggioTEC_TipoRip'
			where P.id= @IdDoc

	   
    select @FormulaEconomica = FormulaEconomica 
	   from Document_Modelli_MicroLotti_Formula WITH(NOLOCK) 
	   where @Criterio = CriterioFormulazioneOfferte and @ListaModelliMicrolotti = Codice

    -- prova ad applicare i criteri si valutazione specifici del lotto se presenti
    Select 
		  @MAX_PunteggioEconomico = PunteggioEconomico
		  , @MAX_PunteggioTecnico   = PunteggioTecnico
		  , @FormulaEcoSDA          = FormulaEcoSDA
		  , @PunteggioTecMin		  = PunteggioTecMin
		  , @Coefficiente_X		  = Coefficiente_X
		  , @PunteggioTEC_100		  = isnull(PunteggioTEC_100 , '0' ) 
		  , @PunteggioTEC_TipoRip   = isnull( PunteggioTEC_TipoRip , '0' ) 
		  , @Conformita			  = Conformita
		  , @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara
		  , @ModAttribPunteggio = ModAttribPunteggio
	   from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO 
	   where idBando = @idBando and ( N_Lotto = @NumeroLotto or N_Lotto is null )



	-- nel caso in cui il campo non è presente si preserva il comportamento precedente effettuando il ricalcolo
	select  @RicalcoloSeCiSonoEsclusioni = Value from CTL_DOC_Value with(nolock) where idheader = @idBando and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'RicalcolaPerEsclusioni' 
	set @RicalcoloSeCiSonoEsclusioni = isnull( @RicalcoloSeCiSonoEsclusioni , '1' )
	If  @RicalcoloSeCiSonoEsclusioni not in ('0','1')
		set @RicalcoloSeCiSonoEsclusioni='1'

	 
    --FACCIO LA VALUTAZIONE TECNICA SE CRITERIO DI AGGIUDICAZIONE GARA E' OEPV OPPURE COSTO FISSO 
    if @CriterioAggiudicazioneGara in ('15532','25532')	
    begin



	    if @InCorsodiVAlutazione = 1 
	    begin
		    ----------------------------------------------------------
		    -- Nel caso il calcolo tecnico viene eseguito più di una volta si annullano eventuali esclusioni automatiche riammettendo il fornitore
		    ----------------------------------------------------------
		    declare crsEsclusioni cursor static for 
				    select O.ID , e.id
					    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
								inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
								inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('escluso' ) and P.NumeroLotto = O.NumeroLotto
								inner join CTL_DOC e WITH(NOLOCK)  on e.LinkedDoc = O.id and e.TipoDoc = 'ESITO_LOTTO_ESCLUSA' and isnull(e.JumpCheck ,'') = 'AUTO' and e.deleted = 0 and e.StatoFunzionale = 'Confermato'
					    where P.ID = @IdDoc 

		    open crsEsclusioni 
		    fetch next from crsEsclusioni into @IdLotto , @idEsclusione
		    while @@fetch_status=0 
		    begin 
			    update CTL_DOC set StatoFunzionale = 'Annullato' where id = @idEsclusione
			    update Document_MicroLotti_Dettagli set statoRiga = case when @Conformita = 'Ex-Ante' then 'Conforme' else 'Valutato' end where id = @IdLotto    --'Valutato' , 'Conforme'

			    fetch next from crsEsclusioni into @IdLotto , @idEsclusione
		    end 
		    close crsEsclusioni 
		    deallocate crsEsclusioni
	    END


		-- azzero il punteggio tecnico di tutte le offerte sul Lotto per evitare che resti su offerte escluse
		--print 'Azzero i punteggi'
		update LO 
			set  PunteggioTecnicoRiparCriterio = null , PunteggioTecnicoRiparTotale = null , PunteggioTecnico = null , PunteggioTecnicoAssegnato = null
			from Document_PDA_OFFERTE o WITH(NOLOCK) 
				inner join Document_MicroLotti_Dettagli LO WITH(NOLOCK)  on LO.idheader = o.idrow and lo.tipodoc = 'PDA_OFFERTE' and isnull( lo.voce  , 0 ) = 0  and lo.NumeroLotto = @NumeroLotto
			where o.idheader = @IdPDA

		
	    ------------------------------------------------------------
	    ------------------------------------------------------------
	    -- Inzio operazione per riportare tutti i punteggi con le eventuali riparametrazioni
	    -- l'intera operazione si ripete fino a quando la verifica delle soglie non aggiunge nuove esclusioni nei controlli effettuati
	    ------------------------------------------------------------
	    ------------------------------------------------------------
	    declare @NuoveEsclusioni int
	    declare @NuoveEsclusioni2 int
	    set @NuoveEsclusioni = 1
	
	    while @NuoveEsclusioni = 1
	    begin

		    set @NuoveEsclusioni = 0






		    ------------------------------------------------------------
		    -- PULISCO tutti i dati usati per la riparametrazione per le offerte se la riparametrazione è dopo la soglia di sbarramento
			-- se fatto sempre potremmo trovarci con il valore svuotato e l'offerta esclusa in automatico e non si comprende perchè è stata esclusa
		    ------------------------------------------------------------
			if @PunteggioTEC_100 = '1'  -- Riparametro Dopo la soglia di sbarramento
			begin
				declare crsClean cursor static for 
		    			select O.ID 
		    				from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
		    				inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
		    				inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and P.NumeroLotto = O.NumeroLotto and isnull( o.voce  , 0 ) = 0 
		    				where P.ID = @IdDoc 

				open crsClean 
				fetch next from crsClean into @IdLotto 
				while @@fetch_status=0 
				begin 

		    		update Document_MicroLotti_Dettagli set PunteggioTecnicoRiparCriterio = null , PunteggioTecnicoRiparTotale = null , PunteggioTecnico = null  where id = @IdLotto
		    		update Document_Microlotto_PunteggioLotto set PunteggioRiparametrato = null , GiudizioRiparametrato = null where idHeaderLottoOff = @IdLotto

		    		fetch next from crsClean into @IdLotto 
				end 
				close crsClean 
				deallocate crsClean
			end

		    ----------------------------------------------------------
		    -- Vengono rieseguiti i calcoli dei punteggi per i criteri di MIN e MAX per rinfrescarli di eventuali lotti esclusi
		    ----------------------------------------------------------
			-- l'operazione non è più necessaria viene innescata dalla stored PDA_VALUTAZIONE_TEC_ELAB_LOTTO
		    -- exec PDA_VALUTAZIONE_TEC_LOTTO_MINMAX @idPDA , @NumeroLotto 
			
		    ----------------------------------------------------------
		    -- per ogni fornitore del lotto riporto la valutazione di ogni criterio in modo da avere i dati per riparametrare
		    ----------------------------------------------------------
			declare @old_NumeroLotto int
			set @old_NumeroLotto=-1

		    declare crsFirst cursor static for 
				    select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto
					    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
							inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
							inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga /* in ('Valutato' ) */ not in ( '' , 'Saved','InValutazione','daValutare','inVerifica') and  P.NumeroLotto = O.NumeroLotto and isnull( o.voce  , 0 ) = 0 
					    where P.ID = @IdDoc 

		    open crsFirst 
		    fetch next from crsFirst into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
		    while @@fetch_status=0 
		    begin 
				
			    exec PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA_PUNTEGGI @IdLotto
				--CHIAMO LA SP PDA_VALUTAZIONE_TEC_ELAB_LOTTO con un parametro opzionale per non fare
				--N volte la PDA_VALUTAZIONE_TEC_LOTTO_MINMAX
				--print @NumeroLotto
				if @old_NumeroLotto=@NumeroLotto
				BEGIN
					exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @IdLotto , 0
				END
				else
				BEGIN
					exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @IdLotto , 1
				END				
				set @old_NumeroLotto=@NumeroLotto

			    fetch next from crsFirst into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto

		    end 
		    close crsFirst 
		    deallocate crsFirst


			
			-- VERIFICO ESCLUSIONI SENZA RIPARAMETRAZIONE
		    if @InCorsodiVAlutazione = 1 and @RicalcoloSeCiSonoEsclusioni = '0'
				exec PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE @IdDoc , @IdPFU , @PunteggioTecMin , @PunteggioTEC_100    , 'CriteriPrimaRiparametrazione' ,  @NuoveEsclusioni2 output 

		   

		    ----------------------------------------------------------
		    --se è richiesto di riparametrare per criterio è necessario un passaggio
		    -- per riparametrare ogni criterio
		    ----------------------------------------------------------
		    if @PunteggioTEC_100 <> '0' and @PunteggioTEC_TipoRip in ( '2' , '3' )
		    begin

			    set @RiparametroCriterio = 1


			    -- recupero la prima offerta per basare la lista di criteri da riparametrare
			    select top 1 @IdLotto = O.ID 
				    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
							 inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
							 inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' /*and O.statoRiga in ('Valutato' , 'inVerificaEco' )*/ and P.NumeroLotto = O.NumeroLotto and isnull( o.voce  , 0 ) = 0 
				    where P.ID = @IdDoc 



			    -- ciclo sui criteri di valuatzione del lotto
			    declare crsSec cursor static for 
					    select Pu.idRowValutazione
						    from Document_MicroLotti_Dettagli O WITH(NOLOCK) 
								   inner join Document_Microlotto_PunteggioLotto  Pu WITH(NOLOCK) on Pu.idHeaderLottoOff = O.ID
						    where O.ID = @IdLotto


			    open crsSec 
			    fetch next from crsSec into @idRowValutazione
			    while @@fetch_status=0 
			    begin 


				    --per ogni criterio prendo il massimo
				    select @PunteggioCriterioMax = max(Punteggio) , @GiudizioCriterioMax = max( cast( Giudizio as float ))
					    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
								inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
								inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso' ,'esclusoEco' ,'inVerifica' ) /*in ('Valutato' , 'Conforme' , 'inVerificaEco' )*/ and P.NumeroLotto = O.NumeroLotto
								inner join Document_Microlotto_PunteggioLotto  Pu WITH(NOLOCK) on Pu.idHeaderLottoOff = O.ID 
					    where  P.ID = @IdDoc and pu.idRowValutazione = @idRowValutazione
			
			
			
				    --aggiorno i punteggi riparametrati 


					Update Document_Microlotto_PunteggioLotto 
							set PunteggioRiparametrato = 
								case when isnull( Riparametra , '1' ) = '1' then
										case 
											when @ModAttribPunteggio = 'punteggio' then
												case @PunteggioCriterioMax when 0 then 0 else dbo.AFS_ROUND  ( PunteggioMax * ( cast( Punteggio as float ) /  @PunteggioCriterioMax ) , 2 )  end 
											else
												case @GiudizioCriterioMax when 0 then 0 else dbo.AFS_ROUND  ( PunteggioMax * ( cast( Giudizio as float ) /  @GiudizioCriterioMax ) , 2 )  end 
										end
									else Punteggio
									end
									, 
								GiudizioRiparametrato = 
									case when isnull( Riparametra , '1' ) = '1' then
										case 
											when @ModAttribPunteggio = 'punteggio' then
												case @PunteggioCriterioMax when 0 then 0 else cast( Punteggio as float ) /  @PunteggioCriterioMax end
											else
												case @GiudizioCriterioMax when 0 then 0 else cast( Giudizio as float ) /  @GiudizioCriterioMax end
										end
									else Giudizio
									end

							from Document_Microlotto_PunteggioLotto WITH(NOLOCK) 
								inner join (
												select Pu.idRow as ix , PunteggioMax , Riparametra
													from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
															inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
															inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco' , 'inVerifica' ) /* in ('Valutato' , 'Conforme', 'inVerificaEco' ) */ and P.NumeroLotto = O.NumeroLotto
															inner join Document_Microlotto_PunteggioLotto  Pu WITH(NOLOCK) on Pu.idHeaderLottoOff = O.ID 
															inner join Document_Microlotto_Valutazione V WITH(NOLOCK) on Pu.idRowValutazione = V.idRow
													where  P.ID = @IdDoc and pu.idRowValutazione = @idRowValutazione
								) as a on  idRow = ix
					

				    fetch next from crsSec into @idRowValutazione
			    end 
			    close crsSec 
			    deallocate crsSec	
		

		    end

			
			---------------------------- NUOVO STEP
			-- VERIFICO ESCLUSIONI CON RIPARAMETRAZIONE
		    if @InCorsodiVAlutazione = 1 and @RicalcoloSeCiSonoEsclusioni = '0'
				exec PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE @IdDoc , @IdPFU , @PunteggioTecMin , @PunteggioTEC_100    , 'CriteriDopoRiparametrazione' ,  @NuoveEsclusioni2 output 

		    ----------------------------------------------------------
		    -- per ogni fornitore del lotto riporto la valutazione tecnica ed eseguo la valutazione tecnica
		    ----------------------------------------------------------
		    declare crs cursor static for 
				    select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto
					    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
								inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
								inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) /*in ('Valutato' , 'Conforme', 'inVerificaEco' ) */ and P.NumeroLotto = O.NumeroLotto
					    where P.ID = @IdDoc 

		    open crs 
		    fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
		    while @@fetch_status=0 
		    begin

			    if @StatoRiga not in ( '' , 'Saved','daValutare','escluso','esclusoEco' ) /*in ( 'Valutato' , 'inVerificaEco' )*/ and @Conformita = 'no'
			    begin
				    exec PDA_VALUTAZIONE_TEC_CHIUDI_LOTTO_OFFERTA @IdLotto , @RiparametroCriterio
			    end
			    else
			    begin
				    update Document_MicroLotti_Dettagli set PunteggioTecnico = 0 where id = @IdLotto
			    end
				
				fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto

		    end 
		    close crs 
		    deallocate crs

			IF EXISTS ( select id from lib_dictionary where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES' )
			BEGIN

				-- RICHIEDO IL PROTOCOLLO GENERALE PER LA BUSTA ECONOMICA DELL'OFFERTA

				declare @idPfuMitt INT --l'idpfu mittente dell'offerta. utile per chiamare la stored ProtGenInsert
				declare @idDaProtocollare INT
				--SOSTITUISCO IL CURSORE E LA CHIAMATA AL PROTOCOLLO ONLINE
				--CON UNA CHIAMATA SCHEDULATA
				insert into CTL_Schedule_Process ( IdDoc,IdUser,DPR_DOC_ID,DPR_ID)
					select dof.id as idDaProtocollare, d.IdMittente,'OFFERTA_BT','RICHIEDI_PROTOCOLLO' 
						from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
									INNER JOIN Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader and d.Tipodoc = 'OFFERTA'

									-- recupero l'offerta del fornitore
									INNER JOIN Document_MicroLotti_Dettagli O WITH(NOLOCK) on O.idheader = d.idRow and O.TipoDoc = 'PDA_OFFERTE' 
															and O.NumeroLotto = P.NumeroLotto and o.Voce = 0 --and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) 

									-- prendo il dettaglio offerto dal fornitore
									LEFT JOIN Document_MicroLotti_Dettagli dof with(nolock) on dof.idheader = d.IdMsgFornitore and 
															dof.TipoDoc ='OFFERTA' and dof.Voce = 0 and dof.NumeroLotto = p.NumeroLotto

									-- recupera l'evidenza di lettura del documento
									LEFT JOIN CTL_DOC_VALUE BD with(nolock) on BD.idHeader = d.IdMsg and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
									LEFT JOIN CTL_DOC_VALUE v1 with(nolock) on v1.idHeader = D.IdMsg and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 

							where P.ID = @IdDoc and ( BD.IdRow is not null or v1.idrow is not null  ) -- prendiamo solo quelle la cui busta tecnica è stata 'aperta'/decifrata
	
				--DECLARE crsProt CURSOR STATIC FOR 
				--		select dof.id as idDaProtocollare, d.IdMittente 
				--			from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
				--					INNER JOIN Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader and d.Tipodoc = 'OFFERTA'

				--					-- recupero l'offerta del fornitore
				--					INNER JOIN Document_MicroLotti_Dettagli O WITH(NOLOCK) on O.idheader = d.idRow and O.TipoDoc = 'PDA_OFFERTE' 
				--											and O.NumeroLotto = P.NumeroLotto and o.Voce = 0 --and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) 

				--					-- prendo il dettaglio offerto dal fornitore
				--					LEFT JOIN Document_MicroLotti_Dettagli dof with(nolock) on dof.idheader = d.IdMsgFornitore and 
				--											dof.TipoDoc ='OFFERTA' and dof.Voce = 0 and dof.NumeroLotto = p.NumeroLotto

				--					-- recupera l'evidenza di lettura del documento
				--					LEFT JOIN CTL_DOC_VALUE BD with(nolock) on BD.idHeader = d.IdMsg and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
				--					LEFT JOIN CTL_DOC_VALUE v1 with(nolock) on v1.idHeader = D.IdMsg and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 

				--			where P.ID = @IdDoc and ( BD.IdRow is not null or v1.idrow is not null  ) -- prendiamo solo quelle la cui busta tecnica è stata 'aperta'/decifrata

				--OPEN crsProt
				--FETCH NEXT FROM CrsProt into @idDaProtocollare,@idPfuMitt
				--WHILE @@fetch_status=0
				--BEGIN

				--	-- SIA PER LE MULTILOTTO CHE PER LE MONOLOTTO PASSIAMO COME ID LA RIGA DELLA Document_MicroLotti_Dettagli TIPODOC 'OFFERTA'
				--	EXEC ProtGenInsert @idDaProtocollare,@idPfuMitt, 'OFFERTA_BT'
				
				--	FETCH NEXT FROM crsProt INTO @idDaProtocollare,@idPfuMitt

				--END
				--CLOSE crsProt
				--DEALLOCATE crsProt

			END


			---------------------------- NUOVO STEP
			-- VERIFICO ESCLUSIONI SENZA RIPARAMETRAZIONE TOTALE
		    if @InCorsodiVAlutazione = 1 and @RicalcoloSeCiSonoEsclusioni = '0'
				exec PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE @IdDoc , @IdPFU , @PunteggioTecMin , @PunteggioTEC_100    , 'TotalePrimaRiparametrazione' ,  @NuoveEsclusioni2 output 

	

		    -- se è stato richiesto di riparametrare i punteggi tecnici
		    if @PunteggioTEC_100 <> '0'
		    begin

			    -- conservo il massimo punteggio tecnico ottenuto per riparametrizzare
			    select @PunteggioTecnicoMax = max( O.PunteggioTecnico ) 
					    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
							    inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
								inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco' ,'inVerifica') /*in ('Valutato' , 'Conforme' , 'inVerificaEco' ) */ and P.NumeroLotto = O.NumeroLotto
					    where P.ID = @IdDoc 


				    declare crs cursor static for 
					    select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto
						    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
									inner join Document_PDA_OFFERTE d WITH(NOLOCK)  on d.idheader = p.idheader
									inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco' ,'inVerifica' ) /* in ('Valutato' , 'Conforme' , 'inVerificaEco') */ and P.NumeroLotto = O.NumeroLotto
						    where P.ID = @IdDoc 

				    open crs 
				    fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
				    while @@fetch_status=0 
				    begin 

					    if isnull( @PunteggioTecnicoMax , 0 ) > 0 
					    begin
						    -- riparametro il punteggio del lotto solo se è previsto per il lotto
						    if @PunteggioTEC_TipoRip in ('1' , '3' )
						    begin
							    --Update Document_MicroLotti_Dettagli set PunteggioTecnico = round( @MAX_PunteggioTecnico * ( PunteggioTecnico / @PunteggioTecnicoMax ) , @NumeroDecimali ) where id = @IdLotto 
							    Update Document_MicroLotti_Dettagli 
								    --set PunteggioTecnico = round( @MAX_PunteggioTecnico * ( PunteggioTecnico / @PunteggioTecnicoMax )  , 2 ) ,
								    set PunteggioTecnico = dbo.AFS_ROUND ( @MAX_PunteggioTecnico * ( PunteggioTecnico / @PunteggioTecnicoMax )  , 2 ) ,
									    --PunteggioTecnicoRiparTotale = round ( @MAX_PunteggioTecnico * ( PunteggioTecnico / @PunteggioTecnicoMax ) , 2 ) 
									    PunteggioTecnicoRiparTotale = dbo.AFS_ROUND ( @MAX_PunteggioTecnico * ( PunteggioTecnico / @PunteggioTecnicoMax ) , 2 ) 
								
								    where id = @IdLotto 

						    end			
					    end			

					    fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
				    end 
				    close crs 
				    deallocate crs

			    --end
		    end


	
			---------------------------- NUOVO STEP
			-- VERIFICO ESCLUSIONI CON RIPARAMETRAZIONE TOTALE
		    if @InCorsodiVAlutazione = 1 and @RicalcoloSeCiSonoEsclusioni = '0'
				exec PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE @IdDoc , @IdPFU , @PunteggioTecMin , @PunteggioTEC_100    , 'TotaleDopoRiparametrazione' ,  @NuoveEsclusioni2 output 
		
		    ---------------------------------------------------------------------------
		    ---------------------------------------------------------------------------
		    ---------------------------------------------------------------------------
		    -- controllo le soglie dei punteggi minimi per effettuare eventuali esclusioni automatiche

		    ---------------------------------------------------------------------------
		    ---------------------------------------------------------------------------
		    if @InCorsodiVAlutazione = 1 and @RicalcoloSeCiSonoEsclusioni = '1'
		    begin
				exec PDA_MICROLOTTI_VALUTAZIONE_TEC_ESCLUSIONI_SOGLIE @IdDoc , @IdPFU , @PunteggioTecMin , @PunteggioTEC_100    , 'CriteriPrimaRiparametrazione, CriteriDopoRiparametrazione,TotalePrimaRiparametrazione,TotaleDopoRiparametrazione' ,  @NuoveEsclusioni output 
		    end


	
	    end


	    ------------------------------------------------------------------------------------
	    ------------------------------------------------------------------------------------
	    -- I valori dei punteggi riparametrati vengono eliminati nel caso in cui 
	    -- ci sono offerte senza un esito
	    -- ma solo nel caso in cui la valutazione tecnica è in corso
	    ------------------------------------------------------------------------------------
	    ------------------------------------------------------------------------------------
	    if @InCorsodiVAlutazione = 0
	    begin
		    if exists( select * from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
										inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
										inner join Document_MicroLotti_Dettagli O WITH(NOLOCK)  on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' 
												and O.statoRiga in ('InValutazione','daValutare','inVerifica','') and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
						    where P.ID = @IdDoc 
				    )
		    BEGIN


			    declare crsErase cursor static for 
					    select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto
						    from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
									inner join Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader
									inner join Document_MicroLotti_Dettagli O WITH(NOLOCK) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and P.NumeroLotto = O.NumeroLotto and isnull( o.voce  , 0 ) = 0 
						    where P.ID = @IdDoc 

			    open crsErase 
			    fetch next from crsErase into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
			    while @@fetch_status=0 
			    begin 

				    update Document_MicroLotti_Dettagli set PunteggioTecnicoRiparCriterio = null , PunteggioTecnicoRiparTotale = null  where id = @IdLotto
				    update Document_Microlotto_PunteggioLotto set PunteggioRiparametrato = null , GiudizioRiparametrato = null where idHeaderLottoOff = @IdLotto

				    fetch next from crsErase into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto
			    end 
			    close crsErase 
			    deallocate crsErase

			

		    END
	    end

    end


end


GO
