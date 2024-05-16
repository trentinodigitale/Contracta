USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFFIDAMENTO_DIRETTO_CREATE_FROM_CARRELLO_ME_PROCESSO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_AFFIDAMENTO_DIRETTO_CREATE_FROM_CARRELLO_ME_PROCESSO] 
	( @IdPfu int  , @idUser int)
AS
BEGIN
	
	declare @IdAZiDest as int 
	declare @NumDoc_OK as int
	declare @IdAffidamentoDiretto as int
	declare @strFilter as nvarchar(max)
	declare @ListaProdotti as nvarchar(max)
	declare @aziRagioneSociale as nvarchar(max)
	declare @QTDisp as float
	declare @PrezzoUnitario as Float
	declare @Errore as nvarchar(100)
	declare @idProd as int
	set @NumDoc_OK=0
	
	
	
						
	--per tutte le mandatarie creo un affidamneto diretto semplificato
	--e sono superati i vincoli per ogni riga
	DECLARE crsFornitori CURSOR STATIC FOR 

		select distinct Mandataria from VIEW_DOCUMENT_CARRELLO_ME where idpfu=@IdPfu  and isnull(Mandataria,0) <> 0

	OPEN crsFornitori
	FETCH NEXT FROM crsFornitori INTO @IdAZiDest
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @IdAffidamentoDiretto = null

		CREATE TABLE #TempCheck(
						[Id] [varchar](200) collate DATABASE_DEFAULT NULL,
						[Errore] [varchar](200) collate DATABASE_DEFAULT NULL,
						[JSCRIPT] [varchar](200) collate DATABASE_DEFAULT NULL
					)  
		insert into #TempCheck select top 0 '' as id,'' as errore , '' as JSCRIPT
		
		
			
		--innesco la stored per la creazione dell'affidamento diretto
		insert into #TempCheck 
				exec AFFIDAMENTO_SEMPLIFICATO_CREATE_FROM_OE   @IdAZiDest , @IdPfu

		--@IdAffidamentoDiretto (id della ctl_doc)
		select @IdAffidamentoDiretto=id , @Errore=Errore from #TempCheck

		--cancello la tabella temporanea
		drop table #TempCheck

		if @IdAffidamentoDiretto is not null and cast( @IdAffidamentoDiretto as varchar(100) ) <> 'Errore'
		begin
			
			--recupero ragione sociale fornitore
			select @aziRagioneSociale = aziRagioneSociale  from aziende with (nolock) where idazi = @IdAZiDest

			--aggiorno il titolo del documento
			update 
				ctl_doc 
					set titolo = 'Prodotti nel Carrello ' + @aziRagioneSociale
				where 
					id = @IdAffidamentoDiretto

			set @ListaProdotti =''

			-- travaso gli articoli se il fornitore è ancora iscritto all'albo (disponibile)
			-- da approfondire questo concetto per adesso non applico restrizioni

			-- travaso gli articoli del carrello_me individuati per mandataria e idpfu
			-- nella document_microlotti_dettagli dell'affidamento diretto

			-- recupero id_product presente sul carrello_ME su ogni riga da travasare

			declare crsProdotti CURSOR STATIC FOR 
				select Id_Product, QTDisp, PrezzoUnitario from VIEW_DOCUMENT_CARRELLO_ME
				where idPfu = @IdPfu and Mandataria = @IdAZiDest

			OPEN crsProdotti

			FETCH NEXT FROM crsProdotti INTO @idProd, @QTDisp, @PrezzoUnitario

			WHILE @@FETCH_STATUS = 0

			BEGIN
				declare @valoriQta_Prz as varchar(max) 

				set @strFilter = ' id in ('+ cast (@idProd as varchar(100)) +')'
				
				set @valoriQta_Prz =' ''BANDO_GARA'' as TipoDoc,' + cast (@QTDisp as varchar(100)) + ',' + cast (@PrezzoUnitario as varchar(100))
				
				exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', -1 , @IdAffidamentoDiretto, 'IdHeader', 
							' Id,IdHeader,TipoDoc ', 
							 @strFilter,
							'TipoDoc,Quantita,VALORE_BASE_ASTA_IVA_ESCLUSA', 
							 @valoriQta_Prz,						
							' id '

				--cancello le righe dal carrello_me che ho inserito nell'AFFIDAMENTO DIRETTO
				exec ( 'delete carrello_me where id_product in (' + @idProd + ') '  )

				FETCH NEXT FROM crsProdotti INTO @idProd, @QTDisp, @PrezzoUnitario
			END

			CLOSE crsProdotti 
			DEALLOCATE crsProdotti 	
				
			--rettifico numero riga/voce progressivo su id 
			update Document_MicroLotti_Dettagli 
					set NumeroRiga= V.RowNUm -1 , voce = V.RowNUm -1
				from	 
					Document_MicroLotti_Dettagli A
						inner join (  select  
											id,ROW_NUMBER() over (order by id) as RowNUm
										from 
											Document_MicroLotti_Dettagli 
										where 
											idheader=@IdAffidamentoDiretto and tipodoc='BANDO_GARA') V on A.id=V.id

			
			--modifico la prima riga dei prodotti con la somma dei totali
			declare @totQuantita as int
			declare @totQuantitaPrezzo as int

			select @totQuantita = SUM(Quantita), @totQuantitaPrezzo = SUM(Quantita * VALORE_BASE_ASTA_IVA_ESCLUSA)
				from Document_MicroLotti_Dettagli  
				where idheader=@IdAffidamentoDiretto and NumeroRiga <> 0

			update Document_MicroLotti_Dettagli set
				Descrizione = 'Affidamento come da dettaglio',
				--Quantita = @totQuantita, 
				VALORE_BASE_ASTA_IVA_ESCLUSA = @totQuantitaPrezzo
			where idheader=@IdAffidamentoDiretto and NumeroRiga = 0

			update Document_MicroLotti_Dettagli 
				set VALORE_BASE_ASTA_IVA_ESCLUSA=(Quantita * VALORE_BASE_ASTA_IVA_ESCLUSA)
			where idheader=@IdAffidamentoDiretto and NumeroRiga <> 0
		
		end
		set @NumDoc_OK = @NumDoc_OK + 1

		FETCH NEXT FROM crsFornitori INTO @IdAZiDest

	END

		
	CLOSE crsFornitori 
	DEALLOCATE crsFornitori 	
		
	--memorizzo il numero di ODC creati sulla profiliutenteattrib
	insert into profiliutenteattrib 
		(IdPfu, dztNome, attValue)
	values
		(@IdPfu, 'NumeroAffidamentiDiretti_FromCarrello_ME', cast(@NumDoc_OK as varchar(50)) )
		
	--memorizzo id ultikmo Affidamento Diretto creato sulla profiliutenteattrib		
	if @IdAffidamentoDiretto is not null
		insert into profiliutenteattrib 
			(IdPfu, dztNome, attValue)
		values
			(@IdPfu, 'LastAffidamentoDiretto_FromCarrello_ME', cast(@IdAffidamentoDiretto as varchar(50)) )

	

END











GO
