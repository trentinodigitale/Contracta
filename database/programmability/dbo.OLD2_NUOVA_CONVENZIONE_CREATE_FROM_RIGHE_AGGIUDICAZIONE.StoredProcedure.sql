USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NUOVA_CONVENZIONE_CREATE_FROM_RIGHE_AGGIUDICAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[OLD2_NUOVA_CONVENZIONE_CREATE_FROM_RIGHE_AGGIUDICAZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as int
	declare @IdCom as int
	declare @IdAggiudicatario as int
	declare @EnteAggiudicatrice as int
	declare @IdPda as int
	declare @IdBando as int
	declare @ProtocolloBando as varchar(50)
	declare @DataBando as datetime
	declare @Fascicolo as varchar(50)
	declare @DataRiferimentoInizio as datetime
	declare @DataScadenzaOfferta as datetime
	declare @ProtocolloOfferta as varchar(50)
	declare @DataOfferta as datetime
	declare @TotaleAggiudicato as float
	declare @OggettoBando as nvarchar(max)
	declare @ModelloBando as varchar(500)
	declare @ModelloContratto as varchar(4000)
	declare @IdOfferta as int
	declare @Testo as nvarchar(max)
	declare @idpfuOfferta as int
	declare @cig as varchar(100)
	declare @NumRow as int
	declare @TipoDocBando as varchar(500)
	declare @DivisioneLotti as varchar(10)

	declare @errore varchar(1000)
	declare @righeSelezionate varchar(1000)
	declare @totRipetizioni INT
	declare @Oneri as float
	declare @Azienda as int
	declare @IdConvenzione_Lavorazione as varchar(1000)
	declare @IdConvenzione_Pubblicate as varchar(1000)
	declare @IdConvenzione_Lavor_Pubb as varchar(1000)
	declare @Ambito as varchar(10)

	declare @BandoUserRup as varchar(500) 
	declare @BandoAreaMerceologica as varchar(500) 
	declare @BandoAppaltoVerde as varchar(100)
	declare @BandoAcquistoSociale as varchar(500)

	SET @NumRow=1
	SET @errore = ''

	-- QUESTA MAKE DOC FROM VIENE INVOCATA CON IL PARAMETRO BUFFER, MI TROVERO' QUINDI LE RIGHE SELEZIONATE NELLA COLONNA 'A' DELLA CTL_IMPORT
	select @righeSelezionate = A from CTL_Import with(nolock) where idPfu = @IdUser

	select * into #righe_selezionate from dbo.Split( @righeSelezionate, ',')
	
	--87476
	--select * from CTL_Import where idpfu = 45094

	-----------------------------------------------------------------------------------------------------------------------------------
	-- CONTROLLO BLOCCANTE PER CONSENTIRE LA SELEZIONE DELLE SOLE RIGHE CHE FANNO PARTE DELLA STESSA GARA E DELLO STESSO FORNITORE.  --
	-----------------------------------------------------------------------------------------------------------------------------------
	SELECT @totRipetizioni = COUNT(*) FROM
		(
			select  IdAziAggiudicataria
				from Document_comunicazione_StatoLotti with(nolock)
						inner join #righe_selezionate on Id = items
				group by IdAziAggiudicataria
		) A

	IF @totRipetizioni > 1
	BEGIN
		set @errore = 'Selezionare solo righe dello stesso operatore economico'
	END

	IF @errore = ''
	BEGIN

		SELECT @totRipetizioni = COUNT(*) FROM
		(
			select b.LinkedDoc
				from Document_comunicazione_StatoLotti a with(nolock) 
						inner join ctl_doc b with(nolock) on b.Id = a.IdHeader 
						inner join #righe_selezionate on a.Id = items
				group by b.LinkedDoc
		) A

		IF @totRipetizioni > 1
		BEGIN
			set @errore = 'Selezionare solo righe della stessa procedura'
		END

	END

	--controllo che almeno 1 lotto è disponibile
	--cioè che non è presente in una convenzione in lavorazione/pubblicata
	IF @errore = ''
	BEGIN


		--recupero info della gara
		select top 1 @idDoc = cast(items as int) from #righe_selezionate 

		--recupero info dal dettaglio del lotto aggiudicato
		select @IdCom=idheader,@IdAggiudicatario=IdAziAggiudicataria from Document_comunicazione_StatoLotti with(nolock) where id = @idDoc
	
	
		select @IdPda = com.linkeddoc,			--recupero IDPDA dalla comunicazione
			   @IdBando = gara.id,				--recupero IDBANDO dalla PDA
			   @TipoDocBando = gara.Tipodoc,		--recupero tipodoc del bando
			   @Fascicolo=gara.Fascicolo,
			   @OggettoBando =gara.body , 
			   @ProtocolloBando = gara.Protocollo,
			   @Ambito = DG.value
			from ctl_doc com with(Nolock)
					inner join ctl_doc pda with(nolock) on pda.Id = com.LinkedDoc
					inner join ctl_doc gara with(nolock) on gara.Id = pda.LinkedDoc
					inner join CTL_DOC_Value DG with(nolock) on gara.Id = DG.idheader and DG.DSE_ID='TESTATA_PRODOTTI' and DG.DZT_Name='Ambito'
			where com.id=@IdCom


		--eredito la merceologia e il rup dal bando
		select 
			--@BandoAreaMerceologica = bando.CATEGORIE_MERC,
			@BandoAreaMerceologica = bando.Merceologia,
			@BandoUserRup = bandoVal.Value,
			@BandoAppaltoVerde = bando.Appalto_Verde,
			@BandoAcquistoSociale = bando.Acquisto_Sociale
		from Document_Bando as bando with(nolock)
			inner join ctl_doc_value as bandoVal with(nolock) on bando.idHeader = bandoVal.IdHeader and bandoVal.DZT_Name = 'UserRup'
		where bando.idHeader = @IdBando

			
		select 
			isnull(DG.cig,DB.CIG) as CIG ,DG.NumeroLotto
			--DG.cig,DG.NumeroLotto
				into #temp_lotti_gara
			from 
				Document_MicroLotti_Dettagli DG with(nolock)
					inner join document_bando DB with(nolock) on DG.IdHeader = DB.IdHeader
			where DG.IdHeader = @IdBando and DG.TipoDoc=@TipoDocBando and isnull(DG.Voce,0)=0 
				

		--delle righe selezionate recupero numerolotto, cig dei lotti e aggiudicatario e li metto in una temp #Temp_Lotti_Aggiudicati
		select 
			DETT_PDA.id, CL.NumeroLotto, ISNUlL(DETT_PDA.CIG,T.CIG) as CIG,CL.IdAziAggiudicataria,DETT_PDA.Descrizione,DETT_PDA.idHeaderLotto
				into #Temp_Lotti_Aggiudicati
			from 
				Document_comunicazione_StatoLotti CL with(nolock)  
					inner join #righe_selezionate on CL.Id = items
					inner join CTL_DOC COM with(nolock)   on COM.Id = CL.IdHeader 
					inner join  Document_MicroLotti_Dettagli DETT_PDA  with(nolock)   on DETT_PDA.IdHeader = COM.LinkedDoc and DETT_PDA.TipoDoc='PDA_MICROLOTTI' 
																							and DETT_PDA.NumeroLotto = CL.NumeroLotto and isnull(DETT_PDA.Voce,0)=0 
					--PER LE MONOLOTTO NON E' PRESENTE NELLA Document_MicroLotti_Dettagli  della PDA
					inner join #temp_lotti_gara T on T.NumeroLotto=DETT_PDA.NumeroLotto 

		--recupero cig e fornitore sulle convenzioni in lavorazione/pubblicate sulla stessa gara e li metto in una temp #Temp_Lotti_Convenzioni
		 select 
			CONV.id as IdConvenzione, DETT_CONV.AZI_Dest,lottic.cig,lottiC.NumeroLotto,CONV.StatoFunzionale
				into #Temp_Lotti_Convenzioni		
			from 
				ctl_doc CONV with(nolock)
					inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id 
					inner join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc and isnull(lottiC.Voce,0) = 0
					inner join #temp_lotti_gara lottigara on lottic.cig=lottigara.CIG and lottigara.NumeroLotto = lottic.NumeroLotto
			where 
				CONV.tipodoc='CONVENZIONE' and  CONV.statofunzionale in ('InLavorazione','Pubblicato')  and CONV.Deleted = 0  and AZI_Dest<>''
		
		--metto in una temp #Temp_Lotti_OK tutti i lotti aggiudicati; quelli disponibili hanno la colonna EsitoRiga vuota
		select 
			LA.ID,LA.idHeaderLotto , LA.NumeroLotto , LA.Descrizione , LA.cig, case when LC.IdConvenzione IS null then '' else 'Lotto non disponibile' end as EsitoRiga, LC.IdConvenzione 
			,LC.StatoFunzionale 
			into #Temp_Lotti_OK
				
			from #Temp_Lotti_Aggiudicati LA
				left  join #Temp_Lotti_Convenzioni LC on LC.CIG=LA.CIG and LC.AZI_Dest=LA.IdAziAggiudicataria and LC.NumeroLotto = LA.NumeroLotto 
					order by LA.id
				--where LC.IdConvenzione is 

		if  not exists (
			
				select * from #Temp_Lotti_OK where EsitoRiga=''
					
			)
		begin
			set @errore = 'le righe selezionate non sono disponibili perchè presenti su altre convenzioni in lavorazione e/o pubblicate'
		end
	END



	--SE NON HO BLOCCO CREO IL WIZARD NUOVA_CONVEZIONE

	IF @errore = ''
	BEGIN
		
		--recuperio azienda utente loggato
		select @Azienda = pfuidazi from ProfiliUtente with (nolock) where IdPfu = @IdUser
		
		

		insert into CTL_DOC 
			( IdPfu,Titolo, TipoDoc, Azienda, Body,	ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_Azi ,idPfuInCharge,StrutturaAziendale , Deleted ) 
				values 
				( @IdUser,'Nuova Convenzione', 'NUOVA_CONVENZIONE', @Azienda ,  @OggettoBando,@ProtocolloBando, @Fascicolo, @IdBando , @IdAggiudicatario , @IdUser , cast( @Azienda as varchar) + '#' + '\0000\0000' , 1 )   

		set @Id = SCOPE_IDENTITY()

		
		--popolo la griglia Elenco Lotti nella document_microlotti_dettagli
		insert into Document_MicroLotti_Dettagli 
			(idheader,tipodoc,idHeaderLotto,NumeroLotto,CIG,Descrizione,EsitoRiga)
			select 
				@Id , 'NUOVA_CONVENZIONE' as tipodoc, idHeaderLotto,NumeroLotto,CIG,Descrizione,EsitoRiga
				from 
					#Temp_Lotti_OK
				order by ID
			
		
		--inserisco il record nella document_convenzione
		INSERT into Document_Convenzione (ID , Ambito , Mandataria,AZI_Dest, UserRUP, Merceologia ) 
			VALUES (@id, @Ambito,@IdAggiudicatario,@IdAggiudicatario, @BandoUserRup, @BandoAreaMerceologica )

		--nella ctl_doc_Value memorizzo id delle convenzioni in lavorazione/pubblicate
		--per filtrare l'attributo scelta_concenzione sul wizard
		--lo inizializzo con -1 che è la scelta "Nuova_Concenzione" che deve essere sempre presente
		set @IdConvenzione_Lavorazione=''
		set @IdConvenzione_Pubblicate =''

		--set @IdConvenzione_Lavor_Pubb = '-1,'
		
		select 
			distinct IdConvenzione , StatoFunzionale, AZI_Dest
				into #Temp_Convenzioni_InPub
			from 
				#Temp_Lotti_Convenzioni

		--recupero le convenzioni in lavorazione/pubblicate sullo stesso fornitore
		select 
			--distinct 
			@IdConvenzione_Lavorazione = @IdConvenzione_Lavorazione + cast(IdConvenzione AS varchar(50))  + ','
			
			--@IdConvenzione_Lavor_Pubb = @IdConvenzione_Lavor_Pubb +  cast(IdConvenzione AS varchar(50))  + ','
			from
				#Temp_Convenzioni_InPub
			where 
				AZI_Dest = @IdAggiudicatario and StatoFunzionale='InLavorazione'
		
		select 
			--distinct
			@IdConvenzione_Pubblicate = @IdConvenzione_Pubblicate + cast(IdConvenzione AS varchar(50))  + ','
			
			--@IdConvenzione_Lavor_Pubb = @IdConvenzione_Lavor_Pubb +  cast(IdConvenzione AS varchar(50))  + ','
			from
				#Temp_Convenzioni_InPub
			where 
				AZI_Dest = @IdAggiudicatario and StatoFunzionale='Pubblicato'

	

			--tolgo il carattere ',' finaLE
		if @IdConvenzione_Lavorazione <> ''
			set @IdConvenzione_Lavorazione = left(@IdConvenzione_Lavorazione,LEN(@IdConvenzione_Lavorazione)-1)
		if @IdConvenzione_Pubblicate <> ''
			set @IdConvenzione_Pubblicate = left(@IdConvenzione_Pubblicate,LEN(@IdConvenzione_Pubblicate)-1)
		
		insert into CTL_DOC_Value
			(IdHeader,dse_id, row,DZT_Name,value)
			values
			(@Id,'TESTATA_PRODOTTI',0,'IdConvenzione_Lavorazione',@IdConvenzione_Lavorazione)

		insert into CTL_DOC_Value
			(IdHeader,dse_id, row,DZT_Name,value)
			values
			(@Id,'TESTATA_PRODOTTI',0,'IdConvenzione_Pubblicate',@IdConvenzione_Pubblicate)		
		
		--------- ambiente sociale
		insert into CTL_DOC_Value
			(IdHeader,dse_id, row,DZT_Name,value)
			values
			(@Id,'INFO_AGGIUNTIVE',0,'Acquisto_Sociale',@BandoAcquistoSociale)
			
		insert into CTL_DOC_Value
			(IdHeader,dse_id, row,DZT_Name,value)
			values
			(@Id,'INFO_AGGIUNTIVE',0,'Appalto_Verde',@BandoAppaltoVerde)

	END
		
	IF @Errore = ''
	BEGIN
		select @Id as id
	END
	ELSE
	BEGIN
		select 'Errore' as id , @Errore as Errore
	END

END













GO
