USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ODC_CREATE_FROM_CARRELLO_PROCESSO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_ODC_CREATE_FROM_CARRELLO_PROCESSO] 
	( @IdPfu int  , @idUser int )
AS
BEGIN
	
	declare @id as varchar(50)
	declare @IdConvenzione as int
	declare @Esito as varchar(100)
	declare @Errore as nvarchar(2000)
	declare @ListaConvezioni_OK as varchar(1000)
	declare @ListaConvezioni_NOTOK as varchar(1000)
	declare @ListaOrdinativi_OK as varchar(1000)
	declare @IdOrdinativo as int	
	declare @IdPfuInCharge as int
	declare @StatoFunzionale as varchar(100)
	declare @userRole as varchar(100)
	declare @TempImpegnato as float
	declare @AziendaUtente as int
	declare @NumPO as int
	declare @APS_old as int
	declare @GestioneQuote as varchar(100)
	declare @TotalIva as float
	declare @ResiduoConvenzione as float
	declare @CodiceModelloConvenzione as varchar(200)
	declare @CodiceModelloOrdinativo as varchar(200)
--	declare @DztNameQT as varchar(200)
--	declare @DztNamePRZ as varchar(200)
--	declare @DztNameVALACC as varchar(200)
--	declare @IdModello as int
--	declare @strInsert as varchar(max)
	declare @NumeroLotto as varchar(50)
	declare @TotaleValoreAccessorio as float
	declare @TitoloConvenzione as nvarchar(150)
	declare @ListaConvenzioni_NOTOK_MininoOrdinativo as nvarchar(1000)
	declare @NumODC_OK as int
	declare @TipoScadenzaOrdinativo as varchar(100)
	declare @LockedAttrib as varchar(200)
	declare @DataScadenzaOrdinativo as datetime
	declare @NoteConvenzione as nvarchar(max)
	declare @TotalIvaEroso as float
	declare @TotaleEroso as float
	declare @TipoImporto as varchar(100)
	declare @StrutturaAppartenenza as varchar(500)

	set @NumODC_OK=0

	set @ListaConvenzioni_NOTOK_MininoOrdinativo=''

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @Id = ''
	set @ListaConvezioni_OK=''
	set @ListaConvezioni_NOTOK='' 
	set @IdPfuInCharge=null
	set @StatoFunzionale='InLavorazione'
	set @ListaOrdinativi_OK = ''

	--recupero azienda utente del carrello
	select @AziendaUtente=pfuidazi from profiliutente with(nolock) where idpfu=@IdPfu

	---recupero ruolo dell'utente
	select   @userRole= isnull( attvalue,'')
		from 
			profiliutenteattrib  with(nolock) 
		where 
			--dztnome = 'UserRoleDefault'  
			dztnome = 'UserRole'  
			and idpfu = @idUser
			and attvalue='PO'

	--se sono punto ordinante metto il documento ordinativo in approvazione per me stesso			
	if @userRole='PO'
	begin	
		set @IdPfuInCharge=@IdPfu
		set @StatoFunzionale='InLavorazione'
		set @NumPO=1
	end	
	else
	begin
		--sono punto istruttore (PI)
		--valorizzo @IdPfuInCharge solo se il PO è uno solo
		set @IdPfuInCharge = null
		set @NumPO=0
		select @NumPO=count(*) 
			from 
				PROFILIUTENTEATTRIB PA with(nolock)  inner join profiliutente P with(nolock)  on PA.attvalue=P.idpfu
			where 
				dztnome='pfuResponsabileUtente' and PA.idpfu=@IdPfu
				and PA.attvalue in (
									select PA.idpfu from PROFILIUTENTEATTRIB PA with(nolock)  ,profiliutente P with(nolock)  where attvalue='po' 
									and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
				and P.pfudeleted=0

		if @NumPO=1
		begin

			select @IdPfuInCharge=attvalue 
				from 
					PROFILIUTENTEATTRIB PA with(nolock)  inner join profiliutente P with(nolock)  on PA.attvalue=P.idpfu
				where 
					dztnome='pfuResponsabileUtente' and PA.idpfu=@IdPfu
					and PA.attvalue in (
									select PA.idpfu from PROFILIUTENTEATTRIB PA with(nolock)  ,profiliutente P with(nolock)  where attvalue='po' 
									and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
					and P.pfudeleted=0
		end

	end
	
	--se @IdPfuInCharge non è null ( ho detrminato il PO) allora recupero struttura di appartenenza per settarala 
	--nel campo strutturaaziendale
	set @StrutturaAppartenenza=''

	if @IdPfuInCharge is not null
	begin
		select @StrutturaAppartenenza = attvalue 
			from 
				ProfiliUtenteAttrib with (nolock)
			where
				idpfu = @IdPfuInCharge and dztnome='plant'
	end


	if exists (select id from carrello with(nolock)  where  idpfu=@IdPfu)	
	begin
		
		update carrello set Importo_Residuo_Quote=null,esitoriga='' where idpfu=@IdPfu
		

		delete profiliutenteattrib where dztnome in ('NumeroOrdinativi_FromCarrello','LastOrdinativo_FromCarrello') and idpfu=@IdPfu

		--per tutte le convenzioni-lotto del carrello verifico la disponibilita
		DECLARE crsConvenzioniLotto CURSOR STATIC FOR 
			select distinct id_convenzione,NumeroLotto from carrello with(nolock)  where  idpfu=@IdPfu

		OPEN crsConvenzioniLotto
		FETCH NEXT FROM crsConvenzioniLotto INTO @IdConvenzione,@NumeroLotto
		WHILE @@FETCH_STATUS = 0
		BEGIN

			--creo tabella temp per esito stored di verifica capienza
--			CREATE TABLE #TempCheck(
--				[Id] [varchar](200) NULL,
--				[Errore] [varchar](200) NULL
--			) 		
--
--			insert into #TempCheck select top 0 '' as id,'' as errore from aziende 
--
--			set @Errore=''
--			set @Esito=''
--
--			insert into #TempCheck exec CK_DISPONIBILITA_CARRELLO  -1 , @IdPfu, @IdConvenzione , @NumeroLotto	
--						
--			--cancello la tabella temporanea
--			drop table #TempCheck

			exec CK_DISPONIBILITA_CARRELLO  -1 , @IdPfu, @IdConvenzione ,@NumeroLotto	
			
			FETCH NEXT FROM crsConvenzioniLotto INTO @IdConvenzione,@NumeroLotto
		END

		CLOSE crsConvenzioniLotto 
		DEALLOCATE crsConvenzioniLotto 


		--per tutte le convenzioni del carrello per cui la capienza è rispettata (importo_residuo_quote a null) 
		--e sono superati i vincoli per ogni riga
		DECLARE crsConvenzioni CURSOR STATIC FOR 
			select distinct id_convenzione,Titolo from carrello with(nolock) where idpfu=@IdPfu and id_convenzione not in ( select distinct id_convenzione from carrello with(nolock) where idpfu=@IdPfu and isnull(esitoriga,'')<>'')

		OPEN crsConvenzioni
		FETCH NEXT FROM crsConvenzioni INTO @IdConvenzione,@TitoloConvenzione
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			set @NumODC_OK = @NumODC_OK + 1
			
			--recupero totale che volgio impegnare
			set @TempImpegnato=0
			select @TempImpegnato=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico),0) from carrello with(nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu
			
			--recupero totale eroso
			select @TotaleEroso=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico),0) from carrello with(nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu 
					and Id_Product in (select id from Document_MicroLotti_Dettagli with(nolock) where idheader=@IdConvenzione and isnull(erosione,'si')='si')


			--recupero importo minimo ordinativo
			--set @ImportoMinimoOrdinativo=0
			--select @ImportoMinimoOrdinativo=isnull(ImportoMinimoOrdinativo,0) from document_convenzione where Id = @IdConvenzione
			
			--if 	@TempImpegnato > @ImportoMinimoOrdinativo 
			--begin	
				set @LockedAttrib = ''
				set @TipoScadenzaOrdinativo=''
				set @TipoImporto=''

				select @TipoScadenzaOrdinativo=TipoScadenzaOrdinativo , @DataScadenzaOrdinativo=DataScadenzaOrdinativo,@TipoImporto=TipoImporto 
					from document_convenzione with(nolock) where Id = @IdConvenzione

				if @TipoScadenzaOrdinativo='duratafissata' or @TipoScadenzaOrdinativo='scadenzafissata' or @TipoScadenzaOrdinativo='immediatamenteesecutivo'
				begin
					set @LockedAttrib = ' RDA_DataScad '
				end

				
				--conservo la lista delle convenzioni OK
				if @ListaConvezioni_OK = ''
					set @ListaConvezioni_OK = cast(@IdConvenzione as varchar(100))
				else
					set @ListaConvezioni_OK = @ListaConvezioni_OK + ',' + cast(@IdConvenzione as varchar(100))
				

				
				--creo ordinativo associato alla convenzione corrente
				set @IdOrdinativo = null

				--inserisco nella ctl_doc		
				insert into CTL_DOC (
						 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
							ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck, StrutturaAziendale)
					
						select @idUser as IdPfu ,  'ODC' , 'Saved' , left('Ordinativo per ' + @TitoloConvenzione ,150)  , DescrizioneEstesa , @AziendaUtente ,azi_dest
							--,ProtocolloBando  , '' , Id  ,@StatoFunzionale,@IdPfuInCharge , case @userRole when 'PO' then 'IMPEGNATO' else '' end
							  ,ProtocolloBando  , '' , Id  ,@StatoFunzionale,@IdPfuInCharge , '', @StrutturaAppartenenza
						from document_convenzione with (nolock)
							where Id = @IdConvenzione

				--select * from document_convenzione
				set @IdOrdinativo = @@identity		
				

				-- sezione DOCUMENTAZIONE	
				insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable )
					select DescrizioneRichiesta, AllegatoRichiesto, obbligatorio, anagDoc, @IdOrdinativo as idHeader , TipoFile, isnull(RichiediFirma,'0')  , ' Descrizione ' 
						from Document_Bando_DocumentazioneRichiesta with (nolock)
						where idHeader = @IdConvenzione

				-- Inserisco il record nella document_protocollo
				insert into Document_dati_protocollo ( idHeader )
					values (  @IdOrdinativo )
	 				
				--recuperototale con iva
				set @TotalIva=0	
				select @TotalIva=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico + ( ((QTDisp*Prezzounitario) + ValoreAccessorioTecnico) * iva /100)),0) from carrello with (nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu

				--recupero totale con iva eroso
				select @TotalIvaEroso=isnull(sum(QTDisp*Prezzounitario + ValoreAccessorioTecnico + ( ((QTDisp*Prezzounitario) + ValoreAccessorioTecnico) * iva /100)),0) from carrello with (nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu 
						and Id_Product in (select id from Document_MicroLotti_Dettagli with (nolock) where idheader=@IdConvenzione and isnull(erosione,'si')='si')

				set @TotaleValoreAccessorio=0			
				select @TotaleValoreAccessorio=isnull(sum(ValoreAccessorioTecnico),0) from carrello with (nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu

				--se tipoimporto=ivainclusa allora cambio i calcoli
				if @TipoImporto='ivainclusa'
				begin
					
					--il totale con iva è proprio l'impegnato perchè il prezzo comprende già l'iva
					set @TotalIva=@TempImpegnato

					--calcolo l'imponibile scorporando l'iva per ogni prodotto
					set @TempImpegnato=0
					select @TempImpegnato=isnull(sum( (cast(QTDisp as float) * Prezzounitario + ValoreAccessorioTecnico) / ( 1.00 + iva/100) ),0) from carrello with (nolock) where id_convenzione=@IdConvenzione and idpfu=@IdPfu
					set @TempImpegnato=round(@TempImpegnato,2)

					--?????
					set @TotalIvaEroso = @TotaleEroso

				end


				--inserisco nella  document_ODC
				insert into document_ODC			
					(RDA_ID, RDA_Owner, RDA_Name, RDA_DataCreazione, RDA_Protocol, RDA_Object, RDA_Total,TotalIva, RDA_Stato, RDA_AZI,  RDA_Valuta, RDA_Deleted,  
					Id_Convenzione ,UserRup, NotEditable
					,IdAziDest,NumeroConvenzione,RDA_ResidualBudget,TotaleValoreAccessorio,TotaleEroso,TotalIvaEroso
					, RichiestaCigSimog, idpfuRup)

					select @IdOrdinativo, @idUser ,  'ODC per ' + doc_name , null,'', DescrizioneEstesa , @TempImpegnato ,@TotalIva,   'Saved', @AziendaUtente , valuta,0
							--,@IdConvenzione,@IdPfuInCharge, case @NumPO when 1 then ' UserRUP ' + @LockedAttrib else @LockedAttrib end
							,@IdConvenzione,@IdPfuInCharge, @LockedAttrib
							,azi_dest,NumOrd,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ),@TotaleValoreAccessorio,@TotaleEroso,@TotalIvaEroso
							,'no', @IdPfuInCharge
						from document_convenzione with(nolock)
						where Id = @IdConvenzione
				
				--se sulla convenzione TipoScadenzaOrdinativo=scadenzafissata setto
				--scadenzaordinativo=scadenza impostata sulla convenzione nel campo DataScadenzaOrdinativo
				if @TipoScadenzaOrdinativo='scadenzafissata'
				begin
					update document_ODC 
						set rda_datascad=@DataScadenzaOrdinativo
						where RDA_ID=@IdOrdinativo
				end

				if @TipoScadenzaOrdinativo='duratafissata'
				begin

					declare @NumeroMesi Int 
					select @NumeroMesi=NumeroMesi from document_convenzione with (nolock) where Id = @IdConvenzione

					set @DataScadenzaOrdinativo=dateadd(month, @NumeroMesi,getdate())
					update document_ODC 
						set rda_datascad=@DataScadenzaOrdinativo
						where RDA_ID=@IdOrdinativo
				end

				--settaggio modello di prodotti dinamico
				--recupero codice dalla convenzione
				set @CodiceModelloConvenzione=''
				set @CodiceModelloOrdinativo=''

				select @CodiceModelloConvenzione=value 
					from ctl_doc_value  with(nolock) 
					where 
						idheader=@IdConvenzione and dse_id='TESTATA_PRODOTTI' and dzt_name='Tipo_Modello_Convenzione' 

				set @CodiceModelloOrdinativo ='MODELLO_BASE_CONVENZIONI_' + @CodiceModelloConvenzione + '_MOD_Ordinativo'

				--memorizzo nella section_model
				insert into CTL_DOC_SECTION_MODEL				
					(IdHeader, DSE_ID, MOD_Name)
				values
					(@IdOrdinativo, 'PRODOTTI', @CodiceModelloOrdinativo)
				
				--recupero attributo quantità da valorizzare con la quantità indicata nel modello
				

				exec INSERT_ARTICOLI_ODC_FROM_CARRELLO @IdOrdinativo,@IdConvenzione,@IdPfu

				--recupero note dalla convenzione
				select @NoteConvenzione=Note from ctl_doc where id=@IdConvenzione
				
				--le inserisco sull'ordinativo
				insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value	)
				values
				( @IdOrdinativo, 'NOTECONTRATTO', 0, 'NoteConvenzione', @NoteConvenzione	)
				
				insert into CTL_ApprovalSteps 
					( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
					values 
					('ODC' , @IdOrdinativo , 'Compiled' , 'Creazione Ordinativo di fornitura' , @IdPfu , @userRole   , 0  , getdate() )
				
				--lista degli ordinativi creati
				if @ListaOrdinativi_OK=''
					set @ListaOrdinativi_OK = cast(@IdOrdinativo as varchar(100))
				else
					set @ListaOrdinativi_OK = @ListaOrdinativi_OK + ',' + cast(@IdOrdinativo as varchar(100))

			--end
			--else
			--begin
				--vincolo importo minimo ordinativo non rispettato
			--	if @ListaConvenzioni_NOTOK_MininoOrdinativo=''
			--		set @ListaConvenzioni_NOTOK_MininoOrdinativo = @TitoloConvenzione + ' - ' + dbo.CNV('importo minimo ordinativo' , 'I') + '=' + dbo.FormatMoney(@ImportoMinimoOrdinativo)
			--	else
			--		set @ListaConvenzioni_NOTOK_MininoOrdinativo = @ListaConvenzioni_NOTOK_MininoOrdinativo + ',' + @TitoloConvenzione + ' - ' + dbo.CNV('importo minimo ordinativo' , 'I') + '=' + dbo.FormatMoney(@ImportoMinimoOrdinativo)
				

				
			--end
				
				--esegue il calcolo dei totali anche ripartiti per lotto ( DOBBIAMO RIMUORE  LE STESSE OPERAZIONI GIA FATTE SOPRA )
				exec UPDATE_TOTALI_ODC @IdOrdinativo
				 

			FETCH NEXT FROM crsConvenzioni INTO @IdConvenzione,@TitoloConvenzione

		END

		
		CLOSE crsConvenzioni 
		DEALLOCATE crsConvenzioni 	
		
		--memorizzo il numero di ODC creati sulla profiliutenteattrib
		
		insert into profiliutenteattrib 
			(IdPfu, dztNome, attValue)
		values
			(@IdPfu, 'NumeroOrdinativi_FromCarrello', cast(@NumODC_OK as varchar(50)) )
		
		--memorizzo id ultikmo ODC creato sulla profiliutenteattrib		
		if @IdOrdinativo is not null
			insert into profiliutenteattrib 
				(IdPfu, dztNome, attValue)
			values
				(@IdPfu, 'LastOrdinativo_FromCarrello', cast(@IdOrdinativo as varchar(50)) )

		
--		--recupero numero convenzioni NOT OK
--		declare @nNumConvenzioniNOT_OK as int
--		set @nNumConvenzioniNOT_OK=0
--		select @nNumConvenzioniNOT_OK=count(*) from carrello where idpfu=@IdPfu and isnull(importo_residuo_quote,0)<>0 
--		
--		
--		if @ListaConvezioni_OK <> ''
--		begin	
--		
--				--se ho una sola convezione con capienza 
--				if CHARINDEX ( @ListaConvezioni_OK , ',' ) = 0 and @nNumConvenzioniNOT_OK=0 
--				begin	
--					
--					if @ListaConvenzioni_NOTOK_MininoOrdinativo=''	
--					begin
--						set @id = @ListaOrdinativi_OK
--						set @Errore=''
--					end
--					else
--					begin
--						set @id = 'INFO_NOML'
--						set @Errore= dbo.CNV('Gli ordinativi creati sono disponibili nella cartella "ordinativi di fornitura in lavorazione"' , 'I')  + ';  ' + @ListaConvenzioni_NOTOK_MininoOrdinativo	
--					end
--				end
--				else
--				begin
--					set @id = 'INFO_NOML'
--					--ho più convenzioni con capienza
--					set @Errore=dbo.CNV('Gli ordinativi creati sono disponibili nella cartella "ordinativi di fornitura in lavorazione"','I')
--					if @nNumConvenzioniNOT_OK > 0
--					begin
--						--ho anche convenzioni senza capienza
--						set @Errore= @Errore + '; ' + dbo.CNV('per gli articoli rimasti nel carrello capienza non trovata nella convenzione','I')			
--					end
--					
--					if @ListaConvenzioni_NOTOK_MininoOrdinativo<>''
--					begin
--						set @Errore= @ListaConvenzioni_NOTOK_MininoOrdinativo + ' ' + dbo.CNV(@Errore, 'I') 
--						set @id = 'INFO_NOML'
--					end
--				end
--				
--				--if @Errore<>''
--				--	select 'INFO' as id , @Errore as Errore
--				--else	
--					-- ritorna l'id ordinativo
--					select @id as id, @Errore as Errore
--				--end
--		end
--
--		else
--
--		begin
--				if @ListaConvenzioni_NOTOK_MininoOrdinativo=''
--				begin
--
--					--per nessuna convenzione c'è capienza
--					set @Errore='per tutti gli articoli nel carrello capienza non trovata nella convenzione'
--					-- rirorna l'errore
--					select 'ERRORE' as id , @Errore as Errore
--				end
--				else
--				begin
--					--tra quelli con capienza c'è qualcuno che non rispetta il minimo ordinativo indicato sulla convenzione
--					set @Errore= @ListaConvenzioni_NOTOK_MininoOrdinativo 
--					if @nNumConvenzioniNOT_OK > 0
--						set @Errore= @Errore + '; ' + dbo.CNV('per gli articoli con la colonna Residuo valorizzata capienza non trovata nella convenzione' , 'I') 
--
--					select 'INFO_NOML' as id , @Errore as Errore
--				end
--				
--		end	

	end
--	else
--	begin
--		--non ci sono articoli nel carrello
--		set @Errore='non ci sono articoli nel carrello'
--		-- rirorna l'errore
--		select 'ERRORE' as id , @Errore as Errore
--	end
	

END











GO
