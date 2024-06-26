USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_VERIFICA_ANOMALIA_CREATE_FROM_LOTTO_DAL_01_07_2023]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_VERIFICA_ANOMALIA_CREATE_FROM_LOTTO_DAL_01_07_2023]
	( @idDoc int , @IdUser int ,@idBando as int, @idNew as int, @IdPDA as int, @StatoRiga varchar(50), @OffAnomale varchar(50))
AS
BEGIN

	SET NOCOUNT ON
	-- preparo una tabella di lavoro per gestire tutti i campi come decimal senza modificare la struttura della tabella fisica
	CREATE TABLE #Document_Verifica_Anomalia
	(
		[idRow] [int]   NOT NULL,
		[idHeader] [int] NULL,
		[aziRagioneSociale] [nvarchar](max) NULL,
		[id_rowLottoOff] [int] NULL,
		[id_rowOffPDA] [int] NULL,
		[PunteggioTecnico] [float] NULL,
		[PunteggioEconomico] [float] NULL,
		[PunteggioTotale] [float] NULL,
		[Ribasso] decimal(30,10) NULL,
		[ScartoAritmetico] decimal(30,10) NULL,
		[TaglioAli] [nvarchar](20) NULL,
		[Motivazione] [ntext] NULL,
		[StatoAnomalia] [nvarchar](200) NULL,
		[NotEdit] [nvarchar](500) NULL,
		[RibassoAssoluto] [float] NULL
	)

	-- travaso i record da lavorare
	insert into #Document_Verifica_Anomalia 
		( [idRow], [idHeader], [aziRagioneSociale], [id_rowLottoOff], [id_rowOffPDA], [PunteggioTecnico], [PunteggioEconomico], [PunteggioTotale], [Ribasso], [ScartoAritmetico], [TaglioAli], [Motivazione], [StatoAnomalia], [NotEdit], [RibassoAssoluto] ) 
		select 
			[idRow], [idHeader], [aziRagioneSociale], [id_rowLottoOff], [id_rowOffPDA], [PunteggioTecnico],
			[PunteggioEconomico], [PunteggioTotale], cast(Ribasso  as decimal( 30, 10 )) as [Ribasso], cast([ScartoAritmetico]  as decimal( 30, 10 )) as ScartoAritmetico, [TaglioAli],
			[Motivazione], [StatoAnomalia], [NotEdit], [RibassoAssoluto] 
			from Document_Verifica_Anomalia
			where idHeader=@idNew	
			order by IdRow

	---------------------------------------------------------------------------------------
	-- AL PREZZO (PPB ed OEpV)
	---------------------------------------------------------------------------------------

	declare @Id as INT
	declare @Algoritmo varchar(100)
	declare @idDocAlgoritmo int
	declare @NumAmmesse int
	declare @SogliaAnomalia decimal( 30, 10 ) 
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	--conto le offerte ammesse 
	select @NumAmmesse = count(*) 
		from Document_MicroLotti_Dettagli g
			inner join document_pda_offerte o on o.IdHeader = g.IdHeader
			inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.Voce = 0 
				and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  
				and g.NumeroLotto = l.NumeroLotto 
		where g.id = @idDoc 

	select @idDocAlgoritmo = LinkedDoc 
		from CTL_DOC 
		where id = @IdPDA 
			and tipodoc = 'PDA_MICROLOTTI' 
			and deleted = 0

	select top 1 @Algoritmo = metodo_di_calcolo_anomalia, @OffAnomale = OffAnomale
		from document_bando
		where idheader = @idDocAlgoritmo 

	IF EXISTS (
		SELECT *
		from  ctl_doc bando
			inner join ctl_doc pda on pda.linkedDoc = bando.id
			inner join ctl_doc criterioDoc on criterioDoc.linkedDoc = pda.id
			inner join ctl_doc_value criterio on criterio.idheader = criterioDoc.id 
		where bando.id = @idDocAlgoritmo
			AND DSE_ID = 'CRITERI'  
			AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'	
	)
	BEGIN
	SELECT @Algoritmo = 'Metodo ' + UPPER(RIGHT( dzt_name , 1 ))
		from  ctl_doc bando
			inner join ctl_doc pda on pda.linkedDoc = bando.id
			inner join ctl_doc criterioDoc on criterioDoc.linkedDoc = pda.id
			inner join ctl_doc_value criterio on criterio.idheader = criterioDoc.id 
		where bando.id = @idDocAlgoritmo
			AND DSE_ID = 'CRITERI'  
			AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'
	END

	-- NUOVI ALGORITMI (Metodo B e Metodo C) con la rivisitazione del Metodo A - PARTENDO DALLA DATA DI INVIO DEL BANDO 2023-07-01 DL 36/2023

	-- GRANDEZZE IN COMUNE SUGLI ALGORITMI
	-- Calcolo delle ALI
	-- Calcolo della somma dei ribassi.
	-- Calcolo della media aritmetica dei ribassi.
	-- Calcolo dello scarto aritmetico medio dei ribassi

	declare @NumAli int
	declare @idrow int
	declare @i int
	declare @EstensioneAli as varchar(10)

	-- INIZIO - Calcolo delle ALI  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.
	if @NumAmmesse % 10 > 0
	begin
		set @NumAli = floor( @NumAmmesse / 10.0 ) + 1 
	end
	else
	begin
		set @NumAli =  @NumAmmesse / 10 
	end

	set @EstensioneAli ='NO'

	---- recupero dalla gara se considerare nelle ali le offerte con egual ribasso una volta sola anzichè distinte
	if exists( select value from ctl_DOC_VALUE with(nolock) where idheader = @idBando and dzt_name = 'EstensioneAli' and DSE_ID = 'CRITERI_ECO' )
		select @EstensioneAli = value 
				from ctl_DOC_VALUE with(nolock) 
				where idheader = @idBando 
					and dzt_name = 'EstensioneAli' 
					and DSE_ID = 'CRITERI_ECO'
	else
		select @EstensioneAli = dbo.PARAMETRI ('BANDO_SEMPLIFICATO_CRITERI_ECO','EstensioneAli','DefaultValue','SI',-1)

	if @EstensioneAli ='NO'
	begin
		--3. Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
		declare CurProg Cursor static for 
			Select idRow from #Document_Verifica_Anomalia 	
				--where idHeader=@idNew 
			order by IdRow
			
		open CurProg

		set @i = 1
		FETCH NEXT FROM CurProg INTO @idrow
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
				update #Document_Verifica_Anomalia  set TaglioAli = 'Ali'  --where idRow = @idrow             
			set @i = @i + 1 
			FETCH NEXT FROM CurProg INTO @idrow
		END 
		CLOSE CurProg
		DEALLOCATE CurProg
	end
	else
	begin
		declare @NumRibassiDistinti as int
		declare @RibassoCur as decimal( 30, 10 ) 

		Select @NumRibassiDistinti=count(*) from 
			( select distinct Ribasso 
					from 
						#Document_Verifica_Anomalia 	
					--where idHeader=@idNew 
			) A		
				
		--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
		declare CurProg Cursor static for 
			Select distinct Ribasso from #Document_Verifica_Anomalia 	
				--where idHeader=@idNew 
			order by Ribasso	
		open CurProg
		set @i = 1
		FETCH NEXT FROM CurProg INTO @RibassoCur
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--
			if @i <= @NumAli or @i > @NumRibassiDistinti - @NumAli 
				update #Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where dbo.AFS_ROUND(ribasso,10) = @RibassoCur -- idHeader=@idNew  and      
			set @i = @i + 1 
			FETCH NEXT FROM CurProg INTO @RibassoCur
		END 
		CLOSE CurProg
		DEALLOCATE CurProg
	end

	-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
	update #Document_Verifica_Anomalia  
		set TaglioAli = 'Ali'  
			where  isnull( TaglioAli , '' ) <> 'Ali' --idheader = @idNew and
					and Ribasso in ( 
						select Ribasso from #Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) = 'Ali' --idheader = @idNew and
					)

	-- FINE - Calcolo delle ALI ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	-- INIZIO - Calcolo della somma dei ribassi  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
	declare @MediaRibassi decimal( 30, 10 ) 			
	declare @OfferteUtili varchar(100)
	set @OfferteUtili = 'SI'

	IF exists( select * from #Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' ) --and  idheader = @idNew
	begin		
		declare @SommaRibassi as decimal( 30, 10)
		declare @NumeroTotRibassi as decimal( 30, 10)

		-- 5.2 Calcolo della somma dei ribassi
		select @SommaRibassi = sum(Ribasso)
			from #Document_Verifica_Anomalia 
			where  isnull( TaglioAli , '' ) <> 'Ali' 
				--and  idheader = @idNew

	-- FINE - Calcolo della somma dei ribassi  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- INIZIO - Calcolo della media aritmetica dei ribassi  --------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Media aritmetica dei ribassi percentuali

		select @NumeroTotRibassi = count(*) 
			from #Document_Verifica_Anomalia 
			where  isnull( TaglioAli , '' ) <> 'Ali' 
				--and  idheader = @idNew
		
		--5.3 Calcolo della media aritmetica dei ribassi
		set @MediaRibassi = cast( @SommaRibassi as float ) / cast( @NumeroTotRibassi as float ) 
	-- FINE - Calcolo della media aritmetica dei ribassi  --------------------------------------------------------------------------------------------------------------------------------------------------------
	end
	else
	begin
		set @MediaRibassi = 0 
		set @OfferteUtili = 'NO'
	end

	-- INIZIO - 5.4 Calcolo dello scarto aritmetico medio dei ribassi  ----------------------------------------------------------------------------------------------------------------------------------------------------
	declare @scartoAritmetico as decimal( 30, 10 )
	declare @numTotScartiAritmetici as decimal( 30, 10 )

	update #Document_Verifica_Anomalia 
		set ScartoAritmetico = Ribasso - @MediaRibassi 
		where isnull( TaglioAli , '' ) <> 'Ali' and Ribasso > @MediaRibassi -- and  idheader = @idNew

	select @scartoAritmetico  = sum(ScartoAritmetico) , @numTotScartiAritmetici = count(*)
			from #Document_Verifica_Anomalia 
			where isnull( TaglioAli , '' ) <> 'Ali' and Ribasso > @MediaRibassi -- and  idheader = @idNew

	declare @MediaScarti decimal( 30, 10 ) 

	IF isnull(@numTotScartiAritmetici,0) > 0
	BEGIN
		set @MediaScarti = cast( @scartoAritmetico as float ) / cast( @numTotScartiAritmetici as float ) 
		set @MediaScarti = isnull( @MediaScarti , 0 )
	END
	ELSE
	BEGIN
		set @MediaScarti = 0
	END
	-- FINE - 5.4 Calcolo dello scarto aritmetico medio dei ribassi  ------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Mi ricavo i primi due decimali e il prodotto tra i due
	declare @PrimiDecimali varchar(2)
	declare @Correttivo  as int
				
	set @PrimiDecimali = left( dbo.GetPos( str( @SommaRibassi,20,10) , '.' , 2 )  , 2 ) 
	set @Correttivo = cast( left ( @PrimiDecimali  , 1 ) as int ) * cast( right ( @PrimiDecimali  , 1 ) as int ) 

	IF @Algoritmo = 'Metodo A' 
	BEGIN
		-- Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
		-- Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
		update #Document_Verifica_Anomalia 
			set ScartoAritmetico = Ribasso - @MediaRibassi 
			where isnull( TaglioAli , '' ) <> 'Ali' and Ribasso > @MediaRibassi --and  idheader = @idNew

		-- l'algoritmo si differenzia in funzione delle offerte ammesse
		if @NumAmmesse >= 15 
		begin
			-- Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
			set @SogliaAnomalia = @MediaScarti + @MediaRibassi

			-- Nuovo approccio sul calcolo della soglia anomalia
			-- Formula = 'M + S * ( 1.0 - (c1 * c2 / 100.0) )'

			declare @fattoreDiCalcolo1 as decimal( 30, 10 )
			declare @fattoreDiCalcolo2 as decimal( 30, 10 )
			declare @fattoreDiCalcolo3 as decimal( 30, 10 )

			set @fattoreDiCalcolo1 = @Correttivo / 100.0
			set @fattoreDiCalcolo2 = 1.0 - @fattoreDiCalcolo1
			set @fattoreDiCalcolo3 =  cast( @MediaScarti as float ) * cast( @fattoreDiCalcolo2 as float ) 

			set @SogliaAnomalia = cast( @MediaRibassi + @fattoreDiCalcolo3 as decimal( 30, 10 ))
		end
		else
		------------------------------------------------------------------------------------------
		-- caso in cui le offerte sono minori di 15
		------------------------------------------------------------------------------------------
		begin
		--AGGIUNTO PER CORREGGERE ERRORE DIVISION BY ZERO
		if @MediaRibassi <> 0
		BEGIN
			-- se il rapporto degli scarti è <= 0,15 
			if @MediaScarti / @MediaRibassi  <= 0.15 
			BEGIN
				set @SogliaAnomalia =  cast( @MediaRibassi as float ) * 1.2
			end
			else
			begin
				-- se il rapporto degli scarti è > 0,15 
				-- Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
				set @SogliaAnomalia = @MediaScarti + @MediaRibassi

			end
		END
		ELSE
		BEGIN
			set @SogliaAnomalia=0
		END
		end
	end

	IF @Algoritmo = 'Metodo B' OR  @Algoritmo = 'Metodo C'
	BEGIN
		declare @ValoreRandomicoPercentuale as decimal( 30, 10 )
		set @ValoreRandomicoPercentuale = cast( @Correttivo as float ) * cast( @MediaScarti as float ) 
		declare @SommaRibassiTruncate as INT
		
		-- Moltiplico per cento per spostare nella parte intera i primi due decimali
		set @SommaRibassiTruncate = cast( @SommaRibassi as float ) * 100.0
		
		-- Escludo tutta la parte decimale che non mi interessa
		set @SommaRibassiTruncate = FLOOR(@SommaRibassiTruncate)

		declare @SommaCifreRibassi as INT
		declare @SogliaAnomaliaDefinitiva as decimal( 30, 10 )
		DECLARE @ValueToString NVARCHAR(MAX)
		DECLARE @MaxPosition INT
		DECLARE @CurrentPosition INT 
		set @SommaCifreRibassi = 0
		-- Converto a stringa il numero intero per prendere cifra per cifra e sommarle
		set @ValueToString = cast(@SommaRibassiTruncate as nvarchar)
		-- Leggo il massimo numero di posizione tramite la lunghezza della stringa
		set @MaxPosition = len(@ValueToString)
		SET @CurrentPosition = 1

		WHILE (@CurrentPosition <= @MaxPosition)
		BEGIN
			set @SommaCifreRibassi = @SommaCifreRibassi + cast(substring(@ValueToString,@CurrentPosition,1) as int)
			SET @CurrentPosition  = @CurrentPosition  + 1
		END
	END

	IF @Algoritmo = 'Metodo B'			
	BEGIN
		
		-- I primi 4 punti sono in comune con l'algoritmo A ovvero
		-- Calcolo delle ALI
		-- Calcolo della somma dei ribassi.
		-- Calcolo della media aritmetica dei ribassi.
		-- Calcolo dello scarto aritmetico medio dei ribassi

		-- 5. Calcolo della soglia 
		set @SogliaAnomalia = @MediaScarti + @MediaRibassi

		--6. Calcolo della percentuale dello scarto medio aritmetico (10 dec.)
		-- 6.a Valore (10 dec.) = 1.ma cifra decimale della Somma ribassi percentuali (10 dec.) moltiplicata 2.da cifra decimale 
		-- della Somma dei ribassi percentuali (10 dec.)
		-- 6.b Valore randomico (10 dec.) = %valore (10 dec.) moltiplicato scarto medio aritmetico (10 dec.)

		-- Punto 7) Calcolo della somma delle cifre fino al 2 decimale della somma dei ribassi

		-- 8. Calcolo della soglia di anomalia definitiva 
			--a. Se somma del punto 7 è pari
			--Soglia (10 dec.) = Valore punto 5 (10 dec.) – Valore randomico (10 dec.);
			--b.	Se somma del punto 7 è dispari
			--Soglia (10 dec.) = Valore punto 5 (10 dec.) + Valore randomico (10 dec.).

		set @ValoreRandomicoPercentuale =  @ValoreRandomicoPercentuale / 100.0

		IF @SommaCifreRibassi % 2 = 0
		BEGIN
			set @SogliaAnomaliaDefinitiva = @SogliaAnomalia - @ValoreRandomicoPercentuale
		END
		ELSE
		BEGIN
			set @SogliaAnomaliaDefinitiva = @SogliaAnomalia + @ValoreRandomicoPercentuale
		END
	END

	IF @Algoritmo = 'Metodo C' 

	BEGIN

		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
				values( @idNew , 'MEDIE'  , 0 , 'Metodo' , 'C ' )
				
		set @SogliaAnomalia = @MediaScarti + @MediaRibassi

		-- 1. Definizione dello sconto di riferimento 
		declare @ScontoDiRiferimento as decimal( 30, 10 )
		select @ScontoDiRiferimento = ScontoDiRiferimento from document_bando where idHeader = @idBando
				
		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
				values( @idNew , 'MEDIE'  , 0 , 'ScontoDiRiferimento' , @ScontoDiRiferimento )

		-- Gli altri 4 punti sono in comune con l'algoritmo A ovvero
		-- Calcolo delle ALI
		-- Calcolo della somma dei ribassi.
		-- Calcolo della media aritmetica dei ribassi.
		-- Calcolo dello scarto aritmetico medio dei ribassi

		--6. Calcolo della percentuale dello scarto medio aritmetico (10 dec.) 
		-- 6.a Valore (10 dec.) = 1.ma cifra decimale della Somma ribassi percentuali (10 dec.) moltiplicata 2.da cifra decimale 
		-- della Somma dei ribassi percentuali (10 dec.)
		-- 6.b Valore randomico (10 dec.) = %valore (10 dec.) moltiplicato scarto medio aritmetico (10 dec.)

		-- Punto 7) Calcolo della somma delle cifre fino al 2 decimale della somma dei ribassi

		-- 8. Calcolo della soglia di anomalia definitiva 
		--a. Se somma del punto 7 è pari
		--Soglia (10 dec.) = Sconto  (10 dec.) – Valore randomico (10 dec.);
		--b.	Se somma del punto 7 è dispari
		--Soglia (10 dec.) = Sconto  (10 dec.) + Valore randomico (10 dec.).

		set @ValoreRandomicoPercentuale =  @ValoreRandomicoPercentuale / 100.0

		IF @SommaCifreRibassi % 2 = 0
		BEGIN
			set @SogliaAnomaliaDefinitiva = @ScontoDiRiferimento - @ValoreRandomicoPercentuale
		END
		ELSE
		BEGIN
			set @SogliaAnomaliaDefinitiva = @ScontoDiRiferimento + @ValoreRandomicoPercentuale
		END

		-- Poichè tale metodo potrebbe portare anche alla esclusione di tutte le offerte presentate (essendo basato su uno sconto di riferimento a priori) è necessario 
		-- ipotizzare, in tale evenienza la possibilità di una fase di “valutazione” per definire l’aggiudicatario in luogo della riesecuzione della procedura stessa.
	END

	set @id = @idNew

	IF @Algoritmo = 'Metodo B' OR  @Algoritmo = 'Metodo C'
	BEGIN	
			
		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
				values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomaliaDefinitiva' , @SogliaAnomaliaDefinitiva )

		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
				values( @idNew , 'MEDIE'  , 0 , 'ValoreRandomicoPercentuale' , @ValoreRandomicoPercentuale )

		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
				values( @idNew , 'MEDIE'  , 0 , 'SommaCifreRibassi' , @SommaCifreRibassi )
	END



	-- Se ci sono offerte utili allora settiamo in anomalo o sospetto anomalo lo stato dell'offerta 
	-- solo nel caso in cui il ribasso è maggiore o uguale della soglia di anomalia
	if @OfferteUtili = 'SI'
	begin

		IF @Algoritmo = 'Metodo B' OR  @Algoritmo = 'Metodo C'
		BEGIN

			set @SogliaAnomalia = @SogliaAnomaliaDefinitiva
		END

		-- riporto sulla tabella del calcolo anomalia lo stato della riga
		update #Document_Verifica_Anomalia 
				set StatoAnomalia=@StatoRiga,
				Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
			where  Ribasso > @SogliaAnomalia --idheader = @idNew and

	end
	else
	begin
		-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
		insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
	end

	IF @SogliaAnomalia < 0
	BEGIN
		SET @SogliaAnomalia = 0
	END

	-- salviamo collegato al documento i valori utilizzati per i calcoli
	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'SommaRibassi' , @SommaRibassi  )

	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti  )

	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia  )

	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'EstensioneAli' , @EstensioneAli  )

	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
		values( @idNew , 'MEDIE'  , 0 , 'METODO_DI_CALCOLO_ANOMALIA' ,  @Algoritmo)

	-- Tolgo la non editabilità dalle offerte in stato sospetto anomalo
	update #Document_Verifica_Anomalia set NotEdit = '0' where NotEdit = '1' and statoAnomalia = 'SospettoAnomalo' --idHeader = @idNew and

	UPDATE A    
		SET A.Ribasso = RA.Ribasso,  
			A.ScartoAritmetico = RA.ScartoAritmetico,
			A.TaglioAli = RA.TaglioAli,
			A.StatoAnomalia = RA.StatoAnomalia,
			A.Notedit = RA.Notedit
	from Document_Verifica_Anomalia A
		INNER JOIN #Document_Verifica_Anomalia RA
		 ON A.idRow = RA.idRow

		 drop table #Document_Verifica_Anomalia

	if @Errore = ''
	begin
		-- rirorna l'id della nuova appena creata
		select @Id as id
	end
	else
	begin
		-- ritorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

	SET NOCOUNT OFF

END

GO
