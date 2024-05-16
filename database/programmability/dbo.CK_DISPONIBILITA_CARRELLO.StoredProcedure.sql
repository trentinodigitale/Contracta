USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_DISPONIBILITA_CARRELLO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CK_DISPONIBILITA_CARRELLO] ( @idArticolo int , @IdUser int, @IdConvenzione int , @NumeroLotto varchar(50), @idOrdinativo int = 0)
AS
BEGIN

	SET NOCOUNT ON
	
	declare @Errore as nvarchar(4000)
	declare @GestioneQuote as varchar(100)
	declare @AziendaUtente as int
	declare @ResiduoConvenzione as float
	declare @TempImpegnato as float
	declare @Titolo as nvarchar(150)
	declare @NoML as tinyint
	declare @idProduct as int
	declare @ErroreVincolo as nvarchar(4000)
	declare @ImportoMinimoOrdinativo as float

	declare @qtyOriginale float
	declare @valEcoOriginale float
	declare @qtyCarrello float
	declare @valEcoCarrello float
	declare @idOdcRidotto int
	declare @ValoreAccessorioOriginale float
	declare @ValoreAccessorioRidotto float
	declare @StruttureAbilitate as varchar(max)
	declare @StrutturaAppartenza_User as varchar(500)
	declare @cig varchar(500)
	declare @Id_User_Struttura_Appartenenza as int
	declare @Suffisso_CNV_User as varchar(10)
	declare @Convenzione_Importi_Negativi as int

	set @Convenzione_Importi_Negativi = 0


	set @Id_User_Struttura_Appartenenza = @IdUser

	set @NoML=1
	set @Errore =''
	set @idOdcRidotto = 0
	set @Suffisso_CNV_User = ''

	--recupero azienda utente collegato
	select @AziendaUtente=pfuidazi from profiliutente with(nolock) where idpfu=abs(@IdUser)
	
	--recupero id della convenzione
	if @idArticolo <> -1
	BEGIN
		
		select @NumeroLotto=NumeroLotto,@IdConvenzione = idheader from document_microlotti_dettagli with(nolock) where id=@idArticolo

		select @cig = d.cig
			from carrello C with(nolock)
					inner join document_microlotti_dettagli D with(nolock) on d.id = C.id_product and D.Tipodoc='CONVENZIONE' and D.Idheader = c.id_convenzione
			where C.idpfu = @IdUser and c.id_convenzione = @IdConvenzione and C.Id_Product = @idArticolo

	END
	ELSE
	BEGIN

		select top 1 @cig = d.cig
			from document_microlotti_dettagli D with(nolock)
			where D.Tipodoc='CONVENZIONE' and d.IdHeader = @IdConvenzione and D.NumeroLotto = @NumeroLotto and isnull(voce,0) = 0

	END

	--recupero titolo della convenzione
	select @Titolo=titolo from ctl_doc with(nolock) where id=@IdConvenzione	

	--aggiorno il titolo sul carrello	
	update carrello set Titolo=@Titolo where id_convenzione=@IdConvenzione and idpfu=@IdUser and NumeroLotto=@NumeroLotto

	--recupero gestionequote
	--recuperare @ResiduoConvenzione per lotto	
	select 
		@GestioneQuote=GestioneQuote--,@ResiduoConvenzione=isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) 
		, @Convenzione_Importi_Negativi = 
										case
											when Total < 0 then 1 
											else 0
										end
			
		from Document_Convenzione with(nolock) where id=@IdConvenzione

	
	--svuoto la colonna esitoriga per tutto il carrello dell'utente per la convenzione corrente
	update carrello set esitoriga='' 
		where id_convenzione=@IdConvenzione and idpfu=@IdUser and  NumeroLotto=@NumeroLotto
	
	if 	@GestioneQuote <> 'senzaquote'
	begin

		--controllo che mi è stata associata una quota per proseguire
		set @Errore = dbo.CNV('quota non associata per ente sulla convenzione' , 'I')

		if exists (
				select 
					idrow from 
						Document_Convenzione_Quote_Importo with(nolock)
					where idheader=@IdConvenzione and Azienda=@AziendaUtente
				)		
		begin
			set @Errore=''
		end
		else
		begin
			
			--aggiorno esitoriga su tutte le righe della convenzione-lotto
			update carrello 
					set esitoriga=@Errore
				where 
					idpfu=@IdUser and id_convenzione=@IdConvenzione --and numerolotto=@NumeroLotto
		end

	end
	
	--Att. 480390 se definite le strutture abilitate sull'ente verifico che la struttura di appartenenza
	--dell'utente è compresa tra le strutture abilitate
	select @StruttureAbilitate = isnull(plant,'') 
		from Document_Convenzione_Plant with (nolock) where idHeader = @IdConvenzione and AZI_Ente = @AziendaUtente
			
	if @StruttureAbilitate <> ''
	begin

		--se sono su ODC recupero id del PO se presente altrimenti uso utente corrente
		if @idOrdinativo <> 0
		begin
			select @Id_User_Struttura_Appartenenza = UserRUP 
				from 
					document_odc with (nolock) 
				where rda_id = @idOrdinativo and isnull(UserRUP,0) <> 0
					
			set @Suffisso_CNV_User  = 'PO'

		end

		set @StrutturaAppartenza_User = ''
		select @StrutturaAppartenza_User = isnull(attvalue,'') 
			from ProfiliUtenteAttrib with (nolock) where IdPfu = @Id_User_Struttura_Appartenenza and dztNome = 'Plant'
				
		if @StrutturaAppartenza_User <> ''
		begin
					
			if CHARINDEX ('###' + @StrutturaAppartenza_User + '###', @StruttureAbilitate ) = 0
				set @Errore = dbo.CNV('struttura di appartenenza utente ' + @Suffisso_CNV_User + ' non presente sulle strutture abilitate sulla convenzione' , 'I')

			--aggiorno esitoriga su tutte le righe della convenzione-lotto
			update carrello 
				set esitoriga=@Errore
			where 
				idpfu=@IdUser and id_convenzione=@IdConvenzione --and numerolotto=@NumeroLotto

		end

	end


	--verifico che esiste la disponibilita per i prodotti a carrello della convenzione
	if @Errore = ''
	begin

		--controllo a prescindere il residuo sul lotto - convenzione
		--recuperare TempImpegnato per lotto (numerolotto) e convenzione
		set @TempImpegnato=0

		select @TempImpegnato=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico),0) 
			from 
				carrello with(nolock)
			where id_convenzione=@IdConvenzione 
					and idpfu=@IdUser 
					and numerolotto=@NumeroLotto 
					and Id_Product in (select id from Document_MicroLotti_Dettagli where idheader=@IdConvenzione and isnull(erosione,'si')='si')

		--print @TempImpegnato
		--recupero residuo lotto della convenzione
		set @ResiduoConvenzione=0
		
											   
		select @ResiduoConvenzione=isnull(Residuo,0) from CONVENZIONE_CAPIENZA_LOTTI_VIEW with(nolock) where idheader=@IdConvenzione and numerolotto=@NumeroLotto

		set @Errore =  dbo.CNV('importo non disponibile sulla convenzione' , 'I') 

		--se provengo da aggiungi articolo aggiungo il lotto e tolgo il ML
		if @idArticolo <> -1
		begin
		  set @Errore = dbo.CNV('Importo non disponibile sul lotto' , 'I') + ' ' +  @NumeroLotto
		  set @NoML=1
		end

		--if @TempImpegnato <= @ResiduoConvenzione and @ResiduoConvenzione >= 0
		if 
			( 
				dbo.AFS_ROUND(@TempImpegnato,2) <= dbo.AFS_ROUND( @ResiduoConvenzione,2) 
				and dbo.AFS_ROUND( @ResiduoConvenzione,2) >= 0
				and @Convenzione_Importi_Negativi = 0
			)
			or
			( 
				--CONVENZIONI CON IMPORTI NEGATIVI
				dbo.AFS_ROUND(@TempImpegnato,2) >= dbo.AFS_ROUND( @ResiduoConvenzione,2) 
				and dbo.AFS_ROUND( @ResiduoConvenzione,2) <= 0
				and @Convenzione_Importi_Negativi = 1
			)
		begin
			set @Errore =''
		end
		else
		begin

			--aggiorno residuo non rispettato su tutte le righe della convenzione-lotto
			update 
				carrello 
					set Importo_Residuo_Quote=dbo.AFS_ROUND( @ResiduoConvenzione,2),
						esitoriga=isnull(esitoriga,'') + char(13) + char(10) + @Errore
				where 
					idpfu=@IdUser and id_convenzione=@IdConvenzione and numerolotto=@NumeroLotto 
					and Id_Product in (select id from Document_MicroLotti_Dettagli where idheader=@IdConvenzione and isnull(erosione,'si')='si')
		end
		

		--in caso di quote controllo anche il residuo sulla quota
		if 	@GestioneQuote <> 'senzaquote'
		begin

			set @ResiduoConvenzione=0
			set @Errore = dbo.CNV('importo non disponibile sulla quota associata', 'I') 

			IF EXISTS ( select idRow  from Document_Convenzione_Quote_Importo_Lotto with(nolock) where idHeader=@IdConvenzione and Azienda = @AziendaUtente and NumeroLotto=@NumeroLotto )
			BEGIN
				select 
					@ResiduoConvenzione = isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 ) 
					from 
						Document_Convenzione_Quote_Importo_Lotto with(nolock)
					where idHeader = @IdConvenzione and Azienda = @AziendaUtente and NumeroLotto=@NumeroLotto
			END
			ELSE
			BEGIN
				select 
					@ResiduoConvenzione = isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 ) 
					from 
						Document_Convenzione_Quote_Importo with(nolock)
					where idHeader = @IdConvenzione and Azienda = @AziendaUtente
			END
			
			--if @TempImpegnato <= @ResiduoConvenzione and @ResiduoConvenzione >= 0
			if 
				( 
					dbo.AFS_ROUND(@TempImpegnato,5) <= dbo.AFS_ROUND( @ResiduoConvenzione,5) 
					and dbo.AFS_ROUND( @ResiduoConvenzione,2) >= 0
					and @Convenzione_Importi_Negativi = 0
				)
				or 
				( 
					--CONVENZIONI CON IMPORTI NEGATIVI
					dbo.AFS_ROUND(@TempImpegnato,5) >= dbo.AFS_ROUND( @ResiduoConvenzione,5) 
					and dbo.AFS_ROUND( @ResiduoConvenzione,2) <= 0
					and @Convenzione_Importi_Negativi = 1
				)
			begin
				set @Errore =''
			end
			else
			begin

				--aggiorno residuo non rispettato su tutte le righe della convenzione-lotto
				IF EXISTS ( select * from Document_Convenzione_Quote_Importo_Lotto with(nolock) where idHeader=@IdConvenzione and Azienda = @AziendaUtente and NumeroLotto=@NumeroLotto )
				BEGIN
					update 
						carrello 
						set Importo_Residuo_Quote=dbo.AFS_ROUND( @ResiduoConvenzione,2),
							esitoriga=isnull(esitoriga,'') + char(13) + char(10) + @Errore 
						where idpfu=@IdUser and id_convenzione=@IdConvenzione and numerolotto=@NumeroLotto
				END
				ELSE
				BEGIN
					update 
						carrello 
						set Importo_Residuo_Quote=dbo.AFS_ROUND( @ResiduoConvenzione,2),
							esitoriga=isnull(esitoriga,'') + char(13) + char(10) + @Errore 
						where idpfu=@IdUser and id_convenzione=@IdConvenzione --and numerolotto=@NumeroLotto
				END

			end
		end

	end

	IF @Errore = ''
	begin

		IF dbo.superatoImpoAggiudicatoInConv( @IdConvenzione , @cig , @TempImpegnato ) = 1
		BEGIN

			SET @Errore = dbo.CNV('Superato l''Importo Aggiudicato in Convenzione residuo sul lotto per le varie convenzioni in aggiudicazione multipla' , 'I')

			update carrello 
				set esitoriga=isnull(esitoriga,'') + char(13) + char(10) + @Errore
			where idpfu=@IdUser and id_convenzione=@IdConvenzione

		END

	END


	--RECUPERO TOTALE CHE VOGLIO IMPEGNARE A PRESCINDERE DALL'EROSIONE DEL LOTTO ( il totale era calcolato precedentemente ma solo per i lotti da erodere )
	set @TempImpegnato=0
	select @TempImpegnato=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico),0) from carrello with(nolock) where id_convenzione=@IdConvenzione and idpfu=@IdUser
	--select @TempImpegnato
	select @idOdcRidotto = isnull(a.IdDocRidotto,0) from Document_ODC a with(nolock) where a.RDA_ID = @idOrdinativo --and isnull(a.IdDocRidotto,0) > 0

	--nel caso di chiamata dalla creazione ordinativo verifico il vincolo del minimo importo ordinabile
	--e convenzione non scaduta
	IF @idArticolo=-1
	BEGIN

			-- SE NON PROVENGO DA UN ORDINATIVO DI RIDUZIONE
			IF @idOdcRidotto = 0
			BEGIN

				--recupero importo minimo ordinativo
				set @ImportoMinimoOrdinativo=0
				select @ImportoMinimoOrdinativo=isnull(ImportoMinimoOrdinativo,0) from document_convenzione with(nolock) where Id = @IdConvenzione
			
				--if 	@TempImpegnato < @ImportoMinimoOrdinativo 
				if 
					(
						dbo.AFS_ROUND(@TempImpegnato,5) < dbo.AFS_ROUND(@ImportoMinimoOrdinativo,5)
						and 
						@Convenzione_Importi_Negativi=0
					)
					or 
					(
						--CONVENZIONI CON IMPORTI NEGATIVI
						dbo.AFS_ROUND(@TempImpegnato,5) > dbo.AFS_ROUND(@ImportoMinimoOrdinativo,5)
						and 
						@Convenzione_Importi_Negativi=1
					)
				begin

					update carrello 
							set Importo_Residuo_Quote=dbo.AFS_ROUND( @ResiduoConvenzione,2),
								esitoriga=isnull(esitoriga,'') + char(13) + char(10) + dbo.CNV('vincolo importo minimo ordinativo' , 'I')  + '=' + dbo.FormatMoney(@ImportoMinimoOrdinativo) + ' ' + dbo.CNV('non superato' , 'I')
						where idpfu=@IdUser and id_convenzione=@IdConvenzione 

				end

			END

			--verifico che la convenzione non è scaduta
			if exists(select id from document_convenzione with(nolock) where id=@IdConvenzione and convert(varchar(10) ,datafine , 121) < convert( varchar(10) , getdate() , 121 ) )
			begin
				update carrello 
						set esitoriga=isnull(esitoriga,'') + char(13) + char(10) + dbo.CNV('Convenzione Scaduta. Articolo non ordinabile' , 'I')
					where idpfu=@IdUser and id_convenzione=@IdConvenzione and NumeroLotto=@NumeroLotto

			end

			--verifico che la convenzione non è scaduta
			if exists(select id from document_convenzione with(nolock) where id=@IdConvenzione and StatoConvenzione = 'Chiuso')
			begin
				update carrello 
						set esitoriga=isnull(esitoriga,'') + char(13) + char(10) + dbo.CNV('Convenzione Chiusa. Articolo non ordinabile' , 'I')
					where idpfu=@IdUser and id_convenzione=@IdConvenzione and NumeroLotto=@NumeroLotto

			end

	END
	ELSE
	BEGIN
		--select @idOdcRidotto

		-- SE PROVENGO DA UN ORDINATIVO DI RIDUZIONE
		IF @idOdcRidotto > 0
		BEGIN
			
			IF 
				( 
					( @TempImpegnato >= 0 and @Convenzione_Importi_Negativi=0)
					or 
					--CONVENZIONI CON IMPORTI NEGATIVI
					( @TempImpegnato <= 0 and @Convenzione_Importi_Negativi=1)
				)
			BEGIN
				
				set @Errore = dbo.CNV('Per gli ordinativi di riduzione il totale deve essere negativo' , 'I')

				--CONVENZIONI CON IMPORTI NEGATIVI
				if @Convenzione_Importi_Negativi = 1
					set @Errore = dbo.CNV('Per gli ordinativi di riduzione il totale deve essere positivo' , 'I')
				
				--select @Errore

				update carrello 
						set esitoriga = isnull(esitoriga,'') + char(13) + char(10) + @Errore
					where idpfu=@IdUser and id_convenzione=@IdConvenzione 

			END
			ELSE
			BEGIN

				------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--- SE L'UTENTE STA EFFETTUANDO UN ORDINATIVO DI RIDUZIONE, VERIFICO CHE LA QUANTITÀ ED IL PREZZO NON SIANO INFERIORI DEL VALORE PRESENTE NELL'ORDINATIVO ORIGINALE ----
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				select  @qtyOriginale = D2.Qty,
						@valEcoOriginale = D2.ValoreEconomico,
						@qtyCarrello = C.QTDisp,
						@valEcoCarrello = C.PrezzoUnitario,
						@ValoreAccessorioOriginale = D2.ValoreAccessorioTecnico,
						@ValoreAccessorioRidotto = C.ValoreAccessorioTecnico
					from carrello C with(nolock)
							inner join document_microlotti_dettagli D with(nolock) on d.id = C.id_product and D.Tipodoc='CONVENZIONE' and D.Idheader = c.id_convenzione
							--inner join document_microlotti_dettagli D2 with(nolock) on d2.IdHeader = @idOdcRidotto and d2.NumeroRiga = D.NumeroRiga and  D2.Tipodoc='ODC'
							--cambiata join su idheaderlotto perchè numeroriga sugli ODC viene ricalcolata all'invio
							inner join document_microlotti_dettagli D2 with(nolock) on d2.IdHeader = @idOdcRidotto and d2.idHeaderLotto = D.id and  D2.Tipodoc='ODC'
					where C.idpfu = @IdUser and c.id_convenzione = @IdConvenzione and C.Id_Product = @idArticolo

				DECLARE @TotQtyRidotte FLOAT
				DECLARE @TotValEcoRidotti FLOAT
				DECLARE @TotValAccRidotti FLOAT

				set @TotQtyRidotte = 0
				set @TotValEcoRidotti = 0
				set @TotValAccRidotti = 0

				select  @TotQtyRidotte = sum(D.Qty), --as TotQtyRidotte, 
						@TotValEcoRidotti = sum(D.valoreeconomico), --as TotValEcoRidotti
						@TotValAccRidotti = SUM(D.ValoreAccessorioTecnico)
					from document_microlotti_dettagli D2 with(nolock) 
							
							inner join document_microlotti_dettagli D with(nolock) ON D.idHeaderLotto = D2.idHeaderLotto and D.TipoDoc = 'ODC' and D.IdHeader <> D2.IdHeader
							
							--aggiunta relazione per considerare solo le riduzioni fatte sullo stesso ordinativo origine
							--che non sono cancellate e non sono in lavorazione o rifiutate
							inner join Document_ODC D3  with(nolock) on D3.RDA_ID = D.IdHeader and D3.IdDocRidotto =@idOdcRidotto
							inner join ctl_doc D4 with(nolock) on D4.Id = D3.RDA_ID and D3.RDA_Deleted=0 and D4.StatoFunzionale not in ( 'Inlavorazione','Rifiutato','NotApproved') and D4.Deleted=0

					where D2.IdHeader = @idOdcRidotto and D2.TipoDoc = 'ODC' and D2.idHeaderLotto = @idArticolo
					group by D2.idHeaderLotto
				
				--insert into CTL_TRACE ( descrizione ) 
				--select '@qtyOriginale:' + cast(@qtyOriginale as varchar(50)) + '@@@TotQtyRidotte:' + cast(@TotQtyRidotte as varchar(50)) + '@@@TotQtyRidotte:' + cast(@TotQtyRidotte as varchar(50))  
				--select '@valEcoOriginale:' + cast(@valEcoOriginale as varchar(50)) + '@@@valEcoCarrello:' + cast(@valEcoCarrello as varchar(50)) + '@@@TotValEcoRidotti:' + cast(@TotValEcoRidotti as varchar(50))  
				IF ( @qtyOriginale + @qtyCarrello + @TotQtyRidotte) < 0
				BEGIN

					set @Errore = dbo.CNV('La quantita sottratta in totale non puo essere maggiore di quella presente sull''ordinativo' , 'I')

					update carrello 
							set esitoriga = isnull(esitoriga,'') + char(13) + char(10) + @Errore
						where idpfu=@IdUser and id_convenzione = @IdConvenzione and Id_Product = @idArticolo

				END
				ELSE IF  (
							( 
								( @valEcoOriginale + @valEcoCarrello + @TotValEcoRidotti  ) < 0 and @Convenzione_Importi_Negativi=0 
							)
							or
							( 
								--CONVENZIONI CON IMPORTI NEGATIVI
								( @valEcoOriginale + @valEcoCarrello + @TotValEcoRidotti  ) > 0 and @Convenzione_Importi_Negativi=1 
							)
						)

								
				BEGIN

					set @Errore = dbo.CNV('Il prezzo sottratto in totale non puo superare quello presente sull''ordinativo' , 'I')

					update carrello 
							set esitoriga = isnull(esitoriga,'') + char(13) + char(10) + @Errore
						where idpfu=@IdUser and id_convenzione = @IdConvenzione and Id_Product = @idArticolo

				END
				ELSE IF  
						(
							(
								( @ValoreAccessorioOriginale + @ValoreAccessorioRidotto + @TotValAccRidotti ) < 0 and @Convenzione_Importi_Negativi=0
							)
							or
							( 
								--CONVENZIONI CON IMPORTI NEGATIVI
								( @ValoreAccessorioOriginale + @ValoreAccessorioRidotto + @TotValAccRidotti ) > 0 and @Convenzione_Importi_Negativi=1
							)
						)
				BEGIN

					set @Errore = dbo.CNV('La sommatoria dei valori accessori ridotti non puo superare il valore presente sull''ordinativo' , 'I')

					update carrello
							set esitoriga = isnull(esitoriga,'') + char(13) + char(10) + @Errore
						where idpfu=@IdUser and id_convenzione = @IdConvenzione and Id_Product = @idArticolo

				END

			END

		END

	END

	--verifico che i vincoli sulla riga di prodotto che sto aggiungendo sono rispettati
	if @Errore = ''
	begin
		--solo quando vengo da aggiungi articolo
		if @idArticolo<>-1
		begin
			exec CK_VerificaVincoli @IdUser, @idArticolo  , @IdConvenzione, @Errore output
			if 	@Errore <> ''
				set @NoML=1
		end
	end

	if @Errore = ''
	begin
		-- rirorna OK
		select 'OK' as id , '' as Errore
	end
	else
	begin

		--cancello la riga che ho inserito e restituisco il messaggio di errore
		if @idArticolo<>-1
			delete from carrello where id_convenzione=@IdConvenzione and idpfu=@IdUser and id_product=@idArticolo

		-- rirorna l'errore
		if @NoML=0
			select 'ERRORE' as id , @Errore as Errore
		else
			select 'INFO_NOML' as id , @Errore as Errore

	end

SET NOCOUNT OFF
END

















GO
