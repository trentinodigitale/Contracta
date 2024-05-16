USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[APPLICA_SORTEGGIO_TERRITORIALE]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[APPLICA_SORTEGGIO_TERRITORIALE] 
	( @IdDoc int , @ret int output )
AS
BEGIN
	--@IdDoc è id di un documento RICERCA_OE/SORTEGGIO_PUBBLICO....
	--numero minimo di soggetti da invitare alle procedure
	declare @NumMinDaInvitare as int
	
	--numero di soggetti aventi i requisiti richiesti (SOA);
	declare @SoggconReq as int
	
	--numero dei soggetti invitati sarà quello risultante
	declare @SoggInv as int

	--operatori economici aventi sede legale nell aprovincia indicata
	declare @OperProvincia as int

	--operatori economici aventi sede legale fuori della provincia indicata
	declare @OperEstProvincia as int

	declare @Provincia_Territorio as varchar (100)
	
	declare @NumMinRound as int
	declare @NumOpInterni_DaEstrarre as int
	declare @NumOpEsterni_DaEstrarre as int
	declare @NumOpEstratti as int

	declare @rn int

	declare @aziRND TABLE ( [IdAzi] [int] NULL, [ix] [int] NOT NULL IDENTITY(1,1) ) 
	declare @aziDestinatari TABLE ( [IdAzi] [int] NULL ) 

	declare @TipoDoc as varchar(100)
	declare @dse_id as varchar(500)
	declare @idrow as int


	set @ret = -1
	
	set @NumOpInterni_DaEstrarre=0
	set @NumOpEsterni_DaEstrarre=0


	--a seconda del documento su cui sto lavorando recuopero le info principali per l'algoritmo
	select @TipoDoc=tipodoc from ctl_doc where id = @IdDoc
	set @dse_id='BOTTONE'
	if @TipoDoc = 'SORTEGGIO_PUBBLICO'
		set @dse_id='NUMERO_OE'
	

	--recupero numero minimo di soggetti da invitare alle procedure
	select @NumMinDaInvitare=value from ctl_doc_Value with (nolock) where idheader = @IdDoc and dse_id=@dse_id and dzt_name='NumeroMinimoOperatoridaInvitare'
	
	--recupero numero di soggetti aventi i requisiti richiesti (SOA); usciti dalla ricerca
	if @TipoDoc = 'RICERCA_OE'
		select @SoggconReq = count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc 
	else
		select @SoggconReq = count(*) from Document_AziSortPub where  idheader = @IdDoc 


	--recupero la provincia che indica il teritorio interno
	select @Provincia_Territorio=value from ctl_doc_Value with (nolock) where idheader = @IdDoc and dse_id=@dse_id and dzt_name='aziProvinciaLeg3'
	
	--seconda il tipo doc travaso in una tabella temp le aziende da invitare
	if @TipoDoc = 'RICERCA_OE'
		insert into @aziDestinatari
			( idAzi ) 
			select idazi  from CTL_DOC_Destinatari  where idheader = @IdDoc
	else
		insert into @aziDestinatari
			( idAzi ) 
			select idazi from Document_AziSortPub  where idheader = @IdDoc

	--recupero numero operatori economici aventi sede legale nella provincia indicata
	select 
		@OperProvincia=count(*) 
		from 
			@aziDestinatari D 
				inner join aziende A with (nolock) on A.idazi=D.idazi
		where  
			A.aziProvinciaLeg2=@Provincia_Territorio
	
	--conservo gli operatori in provincia in una temp #temp_In_Provincia
	select 
		d.idazi into #temp_In_Provincia
		from 
			@aziDestinatari D
				inner join aziende A with (nolock) on A.idazi=D.idazi
		where  
			A.aziProvinciaLeg2=@Provincia_Territorio 
	
	--conservo gli operatori fuori provincia in una temp #temp_Est_Provincia
	select 
		d.idazi into #temp_Est_Provincia
		from 
			@aziDestinatari D 
				inner join aziende A with (nolock) on A.idazi=D.idazi
		where  
			A.aziProvinciaLeg2 <> @Provincia_Territorio 

	--recupero numero operatori economici fuori provincia indicata
	set @OperEstProvincia = @SoggconReq - @OperProvincia

	

	--CASISTICA 1
	--NumMin ≤ SoggconReq ≤ 2NumMin
	--Allora
	--SoggInv = SoggconReq = OperBL+OperEstBL
	if @SoggconReq >= @NumMinDaInvitare and @SoggconReq <= (2*@NumMinDaInvitare)
	begin
		set @SoggInv = @SoggconReq
		
		--sono tutti da includere aprescindere se in provincia o fuori provincia
		--set @NumOperIncludi = @SoggInv
		--if @TipoDoc = 'RICERCA_OE'
		--begin
		--	update CTL_DOC_Destinatari 
		--					set Seleziona ='includi'
		--					where  idheader = @IdDoc
		--end
		set @NumOpInterni_DaEstrarre = @OperProvincia

		--SORTEGGIO_PUBBLICO - SETTO LA COLONNA ORDINAMENTO PER TUTTI
		--if @TipoDoc = 'SORTEGGIO_PUBBLICO'
		--begin
			
		--	update lista
		--		set ordinamento =  b.ordinamento 
		--		from 
		--			Document_AziSortPub lista
		--				INNER JOIN ( 
		--							select 
		--								ROW_NUMBER() OVER(ORDER BY numeroRandom ASC) as ordinamento, idrow
		--							from 
		--								Document_AziSortPub with (nolock)
		--							where idHeader = @idDoc

		--							) B ON B.idrow = lista.idrow
		--		where lista.idHeader = @IdDoc

		--end
		set @NumOpEsterni_DaEstrarre = @OperEstProvincia

		set @ret = @SoggInv

	end

	--CASISTICA 2
	if @SoggconReq >= 2*@NumMinDaInvitare
	begin
		
		--calcolo numero minimo arrotondato eccesso superiore		
		set @NumMinRound = @NumMinDaInvitare + (@NumMinDaInvitare % 2)
		
		--2.1
		--Se NumMin/2 ≤ OperBL ≤ NumMin → SoggInv = OperBL + OperEstBL(=OperBL)
		if @OperProvincia >= @NumMinRound/2 and @OperProvincia <= @NumMinRound 
		begin
			
			set @SoggInv = 2 * @OperProvincia 
			
			
			--RICERCA_OE - saranno inclusi gli operatori in provincia
			--if @TipoDoc = 'RICERCA_OE'
			--BEGIN
			--	update 
			--		CTL_DOC_Destinatari 
			--			set Seleziona ='includi'
			--			where  
			--			idheader = @IdDoc and idazi in (select idazi from #temp_In_Provincia)
			--END

			--SORTEGGIO_PUBBLICO - SETTO LA COLONNA ORDINAMENTO PER LE AZIENDE DELLA PROVINCIA
			--if @TipoDoc = 'SORTEGGIO_PUBBLICO'
			--begin
			
				set @NumOpInterni_DaEstrarre = @OperProvincia

			--end


			-- ed in più devo estrarre a sorte un numero di operatori fuori provincia uguale al numero di operatori in provincia
			set @NumOpEsterni_DaEstrarre = @OperProvincia

			set @ret = @SoggInv

		end

		ELSE
		--2.2
		--Se OperBL < NumMin/2 → SoggInv = OperBL + numero di OperEstBL(=Nummin -numOperBL)
		if @OperProvincia < @NumMinRound/2
		begin
			
			set @SoggInv = @OperProvincia + (@NumMinDaInvitare-@OperProvincia)
			
			--RICERCA_OE - saranno inclusi gli operatori in provincia
			--if @TipoDoc = 'RICERCA_OE'
			--BEGIN
			--	update CTL_DOC_Destinatari 
			--				set Seleziona ='includi'
			--				where  idheader = @IdDoc and idazi in (select idazi from #temp_In_Provincia)
			--END

			--SORTEGGIO_PUBBLICO - SETTO LA COLONNA ORDINAMENTO PER LE AZIENDE DELLA PROVINCIA
			--if @TipoDoc = 'SORTEGGIO_PUBBLICO'
			--begin
			
				set @NumOpInterni_DaEstrarre = @OperProvincia

			--end

			-- ed in più in questo caso gli operatori esterni estratti a sorte sono pari alla differenza tra il numero minimo di legge e il numero di operatori in provincia
			set @NumOpEsterni_DaEstrarre = @NumMinDaInvitare-@OperProvincia

			set @ret = @SoggInv

		end

		ELSE

		--2.3
		--Se NumMin < OperBL → SoggInv = OperBL(=NumMin) + OperEstBL(=NumMin)
		if @OperProvincia > @NumMinDaInvitare
		begin

			set @SoggInv = 2 * @NumMinDaInvitare
			--in questo caso estraggo a sorte @NumMinDaInvitare operatori in provincia
			--e @NumMinDaInvitare operatori fuori provincia
			set @NumOpInterni_DaEstrarre = @NumMinDaInvitare 
			set @NumOpEsterni_DaEstrarre = @NumMinDaInvitare
			
			set @ret = @SoggInv

		end

		

	END


	--CASISTICA 3
	if @SoggconReq < @NumMinDaInvitare
	begin
		
		--nel caso del sorteggio pubblico invito tutti
		if @TipoDoc = 'SORTEGGIO_PUBBLICO'
		begin

			set @SoggInv = @SoggconReq
			set @NumOpInterni_DaEstrarre = @OperProvincia 
			set @NumOpEsterni_DaEstrarre = @OperEstProvincia
			set @ret = @SoggInv

		end
		else
		begin
			--nel caso della RICERCA_OE
			--non faccio nulla restituisci 0 per dire che non ho incluso nessuno
			--e si dovrà fara avviso per le MI (manifestazioni di interesse)
			set @ret = 0
		end
	end


	--PER IL SORTEGGIO PUBBLICO SETTO LA COLONNA numeroRandom per tutte le aziende
	if @TipoDoc = 'SORTEGGIO_PUBBLICO' and ( @NumOpInterni_DaEstrarre > 0 or @NumOpEsterni_DaEstrarre > 0 )
	begin

		DECLARE curs CURSOR STATIC FOR     
			select idrow from Document_AziSortPub with(nolock) where idHeader = @idDoc

		OPEN curs 
		FETCH NEXT FROM curs INTO @idrow


		WHILE @@FETCH_STATUS = 0   
		BEGIN  

			update 
				Document_AziSortPub
					set numeroRandom = RAND()
				where idrow = @idrow

			FETCH NEXT FROM curs INTO @idrow

		END  


		CLOSE curs   
		DEALLOCATE curs
	end

	--EFFETTUO LE ESTRAZIONI SE RICHIESTE		
	--se ci sono operatori interni da estrarre a sorte lo faccio
	if @NumOpInterni_DaEstrarre > 0 
	begin
			
		if @TipoDoc = 'RICERCA_OE'
		BEGIN

			insert into
					@aziRND ( idAzi ) 
				select idazi from #temp_In_Provincia 

			-- finchè non ho raggiunto il numero di operatori da invitare
			while  @NumOpInterni_DaEstrarre >  ( select count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc and  Seleziona = 'includi' )  --@NumOpInterni_DaEstrarre
			begin 

				set @rn=CAST(RAND(CHECKSUM(NEWID())) * @OperProvincia as INT) + 1

				update CTL_DOC_Destinatari 
					set Seleziona ='includi'
					where idheader = @IdDoc 
							and Seleziona <> 'includi'
							and idazi=(select idazi from @aziRND where ix =  @rn ) 

				--set @NumOpEstratti = @NumOpEstratti + 1

			end 
		END

		--SORTEGGIO_PUBBLICO - SETTO LA COLONNA ORDINAMENTO PER LE AZIENDE DELLA PROVINCIA
		if @TipoDoc = 'SORTEGGIO_PUBBLICO'
		begin
			
			update lista
				set ordinamento = case when b.ordinamento <= @NumOpInterni_DaEstrarre then b.ordinamento else NULL end
				from Document_AziSortPub lista
						INNER JOIN ( 
									select 
										ROW_NUMBER() OVER(ORDER BY numeroRandom ASC) as ordinamento, idrow
										from 
											Document_AziSortPub
										where idHeader = @idDoc  and idazi in (select idazi from #temp_In_Provincia)

									) B ON B.idrow = lista.idrow
				where lista.idHeader = @idDoc

		end

	end


	--se ci sono operatori esterni da estrarre a sorte lo faccio
	if @NumOpEsterni_DaEstrarre > 0 
	begin
			
		if @TipoDoc = 'RICERCA_OE'
		BEGIN
			set @NumOpEstratti=0
			delete from @aziRND

			insert into
					@aziRND ( idAzi ) 
				select idazi from #temp_Est_Provincia 

			-- finchè non ho raggiunto il numero di operatori da invitare
			while   @SoggInv   >  ( select count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc and  Seleziona = 'includi' ) 
			begin 

				set @rn=CAST(RAND(CHECKSUM(NEWID())) * @SoggconReq as INT) + 1

				update CTL_DOC_Destinatari 
					set Seleziona ='includi'
					where idheader = @IdDoc 
							and Seleziona <> 'includi'
							and idazi=(select idazi from @aziRND where ix =  @rn ) 

				--set @NumOpEstratti = @NumOpEstratti + 1

			end 
		END

		--SORTEGGIO_PUBBLICO - SETTO LA COLONNA ORDINAMENTO PER LE AZIENDE DELLA PROVINCIA
		if @TipoDoc = 'SORTEGGIO_PUBBLICO'
		begin
			
			update lista
				set ordinamento = case when b.ordinamento <= @NumOpEsterni_DaEstrarre then @NumOpInterni_DaEstrarre + b.ordinamento else NULL end
				from Document_AziSortPub lista
						INNER JOIN ( 
									select 
										ROW_NUMBER() OVER(ORDER BY numeroRandom ASC) as ordinamento, idrow
										from 
											Document_AziSortPub
										where idHeader = @idDoc  and idazi in (select idazi from #temp_Est_Provincia)

									) B ON B.idrow = lista.idrow
				where lista.idHeader = @idDoc

		end


	end

	

END


GO
