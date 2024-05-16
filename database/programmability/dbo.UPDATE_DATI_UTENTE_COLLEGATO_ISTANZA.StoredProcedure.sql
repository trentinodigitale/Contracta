USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_DATI_UTENTE_COLLEGATO_ISTANZA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE proc [dbo].[UPDATE_DATI_UTENTE_COLLEGATO_ISTANZA]( @iddoc as int, @idPfu as int ) 
AS
BEGIN

	SET NOCOUNT ON

	--CONTROLLI PRIMA DI FARE UPDATE DEI DATI
	IF EXISTS ( Select * from ctl_doc with(nolock) where id=@iddoc and tipodoc like 'Istanza%' and StatoFunzionale='InLavorazione' and ISNULL(SIGN_LOCK,0)=0 and ( ISNULL(idPfuInCharge,0)=0 or ISNULL(idPfuInCharge,0)=@idPfu ))
	BEGIN
		---utente
		declare @NomeRapLeg as varchar(100)
		declare @CognomeRapLeg as varchar(100)
		declare @CFRapLeg as varchar(100)
		declare @DataRapLeg as varchar(100)
		declare @TelefonoRapLeg as varchar(100)
		declare @CellulareRapLeg as varchar(100)
		declare @RuoloRapLeg as varchar(100)

		--rapleg
		declare @StatoResidenzaRapLeg as varchar(100)
		declare @StatoResidenzaRapLeg2 as varchar(100)
		declare @ProvResidenzaRapLeg as varchar(100)
		declare @ProvResidenzaRapLeg2 as varchar(100)
		declare @ResidenzaRapLeg as varchar(100)
		declare @ResidenzaRapLeg2 as varchar(100)
		declare @IndResidenzaRapLeg as varchar(500)
		declare @CapResidenzaRapLeg as varchar(100)

		declare @StatoRapLeg as varchar(100)
		declare @StatoRapLeg2 as varchar(100)
		declare @ProvinciaRapLeg as varchar(100)
		declare @ProvinciaRapLeg2 as varchar(100)
		declare @LocalitaRapLeg as varchar(100)
		declare @LocalitaRapLeg2 as varchar(100)

		declare @notedit as varchar(4000)
		declare @idazi as int
		declare @PrevDoc as int
		set @PrevDoc=0
		declare @valore as varchar(8000)
		
		declare @valore_CF_Prec as varchar(100)

		set @valore_CF_Prec = ''

		declare @CodiceCatastale as varchar(100)
		declare @TipoDoc as varchar(500)
		declare @Section as varchar(500)

		--recupero le info dell'utente
		Select 
			@idazi=pfuidazi,
			@NomeRapLeg=pfunomeutente,
			@CognomeRapLeg=pfuCognome,
			@CFRapLeg=pfuCodiceFiscale,
			@DataRapLeg=dbo.GetDataNascita_FROM_CF ( pfuCodiceFiscale),
			@TelefonoRapLeg=pfuTel,
			@CellulareRapLeg=pfuCell,
			@RuoloRapLeg=pfuRuoloAziendale
		from ProfiliUtente with(nolock)
		where idpfu=@idPfu


		-- aggiorno i dati dall'azienda
		declare @mail nvarchar(1000)
		declare @RagSoc		nvarchar( 500)
		declare @NaGi nvarchar( 500)
		declare @INDIRIZZOLEG nvarchar( 500)
		declare @LOCALITALEG nvarchar( 500)
		declare @LOCALITALEG2 nvarchar( 500)
		declare @CAPLEG nvarchar( 500)
		declare @PROVINCIALEG nvarchar( 500)
		declare @PROVINCIALEG2 nvarchar( 500)
		declare @EMail nvarchar( 500)
		declare @PIVA nvarchar( 500)
		declare @codicefiscale nvarchar( 500)

		declare @STATOLOCALITALEG nvarchar( 500)
		declare @STATOLOCALITALEG2 nvarchar( 500)


		Select 
	 		@RagSoc=aziRagioneSociale 
			,@NaGi=aziIdDscFormasoc 
			,@INDIRIZZOLEG=aziIndirizzoLeg
			,@LOCALITALEG=aziLocalitaLeg 
			,@STATOLOCALITALEG=aziStatoLeg
			,@LOCALITALEG2=aziLocalitaLeg2
			,@STATOLOCALITALEG2=aziStatoLeg2
			,@CAPLEG=aziCAPLeg
			,@PROVINCIALEG=aziProvinciaLeg
			,@PROVINCIALEG2 =aziProvinciaLeg2
			,@mail=aziE_Mail
			,@PIVA=aziPartitaIVA 	

			from aziende with(nolock)  where idazi = @idazi

		select @codicefiscale=vatValore_FT from DM_Attributi with(nolock)  where lnk=@idazi and dztNome='codicefiscale'

		update ctl_doc_value set value = @RagSoc where idheader =  @iddoc and DZT_Name = 'RagSoc'
		update ctl_doc_value set value = @NaGi where idheader =  @iddoc and DZT_Name = 'NaGi'
		update ctl_doc_value set value = @INDIRIZZOLEG where idheader =  @iddoc and DZT_Name = 'INDIRIZZOLEG'

		update ctl_doc_value set value = @LOCALITALEG where idheader =  @iddoc and DZT_Name = 'LOCALITALEG'
		update ctl_doc_value set value = @LOCALITALEG2 where idheader =  @iddoc and DZT_Name = 'LOCALITALEG2'

		update ctl_doc_value set value = @PROVINCIALEG where idheader =  @iddoc and DZT_Name = 'PROVINCIALEG'
		update ctl_doc_value set value = @PROVINCIALEG2 where idheader =  @iddoc and DZT_Name = 'PROVINCIALEG2'

		update ctl_doc_value set value = @STATOLOCALITALEG where idheader =  @iddoc and DZT_Name = 'STATOLOCALITALEG'
		update ctl_doc_value set value = @STATOLOCALITALEG2 where idheader =  @iddoc and DZT_Name = 'STATOLOCALITALEG2'

		update ctl_doc_value set value = @CAPLEG where idheader =  @iddoc and DZT_Name = 'CAPLEG'
		update ctl_doc_value set value = @PIVA where idheader =  @iddoc and DZT_Name = 'PIVA'
		
		
		 select @TipoDoc = TipoDoc from ctl_doc  with(nolock) where id = @iddoc

		if exists (select * from ctl_doc_value with(nolock) where idheader = @iddoc and dzt_name = 'EMAIL')
		begin  

		  update ctl_doc_value set value = @mail where idheader = @iddoc and dzt_name = 'EMAIL' --and DSE_ID = 'TESTATA2'
		  --AGGIUNTO CON IL KPF 553797, su puglia rimaneva la mail della precedente istanza quando la trovava
		  update ctl_doc_value set value = @mail where idheader = @iddoc and dzt_name = 'EMAILRapLeg' --and DSE_ID = 'TESTATA2'


		end
		else
		begin
		  
		  --recupero sezione del documento che contiene attributo EMAIL		  
		  select top 1 @Section=dse_id 
			 from LIB_DocumentSections with (nolock)
				    inner join LIB_ModelAttributes with (nolock) on DSE_MOD_ID + '_SAVE' = MA_MOD_ID  
			 where dse_doc_id=@TipoDoc and MA_DZT_Name='EMAIL'
		  
		  
		  --inserisco la sezione con attributo e valore sul documento
		  insert into ctl_doc_value 
			 ( IdHeader, DSE_ID, Row, DZT_Name, Value)
		  values
			 ( @iddoc, @Section , 0, 'EMAIL', @mail)

		end   
	



		--Stabilisce i campi not edit sul documento
		Set @notedit = ' , '
		if ISNULL(@NomeRapLeg,'') <> ''
			set @notedit=@notedit + 'NomeRapLeg , ' 

		if ISNULL(@CognomeRapLeg,'') <> ''
			set @notedit=@notedit + 'CognomeRapLeg , ' 
	
		if ISNULL(@CFRapLeg,'') <> ''
			set @notedit=@notedit + 'CFRapLeg , ' 
	
		if ISNULL(@DataRapLeg,'') <> ''
			set @notedit=@notedit + 'DataRapLeg , ' 

		if ISNULL(@TelefonoRapLeg,'') <> ''
			set @notedit=@notedit + 'TelefonoRapLeg , ' 

		if ISNULL(@CellulareRapLeg,'') <> ''
			set @notedit=@notedit + 'CellulareRapLeg , ' 

		if ISNULL(@RuoloRapLeg,'') <> ''
			set @notedit=@notedit + 'RuoloRapLeg , ' 		

		---Aggiorno i dati sul documento
		Update CTL_DOC_VALUE 
			set Value=@NomeRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NomeRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@CognomeRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CognomeRapLeg'
		
		--print 'codice fiscale utente collegato=' + @CFRapLeg
		Update CTL_DOC_VALUE 
			set Value=@CFRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CFRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@DataRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='DataRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@TelefonoRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='TelefonoRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@RuoloRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='RuoloRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@CellulareRapLeg
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CellulareRapLeg'
		Update CTL_DOC_VALUE 
			set Value=@codicefiscale
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='codicefiscale'		
		Update CTL_DOC_VALUE 
			set Value=@codicefiscale
			where DSE_ID='STUDIO_ASSOCIATO' and idheader=@iddoc and DZT_NAME='CFRapLegassociato'
		--kpf 561819  istanza prof puglia quando variavava la ragione sociale non veniva aggiornata sulla nuova ist
		if @TipoDoc='ISTANZA_AlboProf_RP'
		BEGIN
			Update CTL_DOC_VALUE 
				set Value=@RagSoc
				where DSE_ID='STUDIO_ASSOCIATO' and idheader=@iddoc and DZT_NAME='AziRagioneSociale'
		END
		Update CTL_DOC_VALUE 
			set Value=''
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='Procura'
		Update CTL_DOC_VALUE 
			set Value=''
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NumProcura'
		Update CTL_DOC_VALUE 
			set Value=''
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NumRaccolta'
		Update CTL_DOC_VALUE 
			set Value=''
			where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='DelProcura'
	


		--verifica se l'utente e rapleg. se è così avvaloro tutti i dati dell'istanza a lui legati. altrimenti
		--,per coerenza , svuoto tutte queste informazioni per farle ri-compilare all'utente
		IF EXISTS (select * from profiliutenteattrib with(nolock) where idpfu  = @idPfu and dztnome = 'Profilo' and attvalue = 'RapLegOE')
		BEGIN
			

			--print 'se ha profilo RapLegOE recupero i dati del RAP LEG dalla dm attributi'
			---recupero i dati del RAP LEG		
			select @StatoResidenzaRapLeg=vatValore_FT from dm_attributi  with(nolock) where lnk=@idazi and idApp=1 and dztNome='StatoResidenzaRapLeg' 
			select @StatoResidenzaRapLeg2=vatValore_FT from dm_attributi with(nolock)  where lnk=@idazi and idApp=1 and dztNome='StatoResidenzaRapLeg2' 
			select @ProvResidenzaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ProvResidenzaRapLeg' 
			select @ProvResidenzaRapLeg2=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ProvResidenzaRapLeg2' 
			select @ResidenzaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ResidenzaRapLeg' 
			select @ResidenzaRapLeg2=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ResidenzaRapLeg2' 
			select @IndResidenzaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='IndResidenzaRapLeg' 
			select @CapResidenzaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='CapResidenzaRapLeg' 

			select @StatoRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='StatoRapLeg' 
			select @StatoRapLeg2=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='StatoRapLeg2' 
			select @ProvinciaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ProvinciaRapLeg' 
			select @ProvinciaRapLeg2=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='ProvinciaRapLeg2' 
			select @LocalitaRapLeg=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='LocalitaRapLeg' 
			select @LocalitaRapLeg2=vatValore_FT from dm_attributi with(nolock) where lnk=@idazi and idApp=1 and dztNome='LocalitaRapLeg2' 
		


			if ( ISNULL(@StatoResidenzaRapLeg,'') <> '' and ISNULL(@ProvResidenzaRapLeg,'') <> '' and ISNULL(@ResidenzaRapLeg,'') <> '' )
				set @notedit=@notedit + 'StatoResidenzaRapLeg , ProvResidenzaRapLeg , ResidenzaRapLeg , ' 	

			if ISNULL(@IndResidenzaRapLeg,'') <> ''
				set @notedit=@notedit + 'IndResidenzaRapLeg , '

			if ISNULL(@CapResidenzaRapLeg,'') <> ''
				set @notedit=@notedit + 'CapResidenzaRapLeg , '
		
			if ( ISNULL(@StatoRapLeg,'') <> '' and ISNULL(@ProvinciaRapLeg,'') <> '' and ISNULL(@LocalitaRapLeg,'') <> '' )
				set @notedit=@notedit + 'StatoRapLeg , ProvinciaRapLeg , LocalitaRapLeg , ' 

			---Aggiorno i dati sul documento
			Update CTL_DOC_VALUE 
				set Value=@StatoResidenzaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@StatoResidenzaRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg2'
			Update CTL_DOC_VALUE 
				set Value=@ProvResidenzaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@ProvResidenzaRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg2'
			Update CTL_DOC_VALUE 
				set Value=@ResidenzaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@ResidenzaRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg2'
			Update CTL_DOC_VALUE 
				set Value=@IndResidenzaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='IndResidenzaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@CapResidenzaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CapResidenzaRapLeg'

			Update CTL_DOC_VALUE 
				set Value=@StatoRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@StatoRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg2'
			Update CTL_DOC_VALUE 
				set Value=@ProvinciaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@ProvinciaRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg2'
			Update CTL_DOC_VALUE 
				set Value=@LocalitaRapLeg
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg'
			Update CTL_DOC_VALUE 
				set Value=@LocalitaRapLeg2
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg2'	


		END
		ELSE
		BEGIN
			
			
			--se utente proprietario del documento è lo stesso di quello collegato non svuoto
			--if not exists ( select * from ctl_doc where id=@iddoc and idpfu=@idPfu)
			--begin
			 
			    -- SE L'utente non è il rappresentante legale svuoto i campi che avrei recuperato per non creare
			    -- un incoerenza di dati (tra quelli dell'utente collegato e quelli di un precedente utente che cel'aveva in carico
				
				--print 'se non ho il profilo raplegoe svuoto i campi'

			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg2'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg2'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg2'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='IndResidenzaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CapResidenzaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg2'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg2'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg'
			    Update CTL_DOC_VALUE 
				    set Value=''
				    where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg2'	

			 --end

		END

		IF not exists ( select * from ctl_doc_value with(nolock) where IdHeader = @iddoc and DSE_ID = 'TESTATA' and DZT_Name = 'Not_Editable' )
		BEGIN

			INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
				VALUES (@iddoc, 'TESTATA', 0, 'Not_Editable', isnull(@notedit,''))

		END
		ELSE
		BEGIN
			Update CTL_DOC_VALUE 
				set Value= isnull(@notedit,'')
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='Not_Editable'	
		END

		---cerca di recuperare i dati inseriti su una precedente istanza dello stesso utente che non ho trovato
		---mi recupero id dell'istanza precedente
	
		Select @PrevDoc=PrevDoc from ctl_doc with(nolock) where id=@iddoc and idpfu=@idPfu
		--controllo se esiste un'istanza precendetemente inviata
		

		IF @PrevDoc > 0 --and @valore_CF_Prec= @CFRapLeg
		BEGIN	

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='NomeRapLeg'
			
			if ISNULL(@NomeRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NomeRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='CognomeRapLeg'
			
			if ISNULL(@CognomeRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CognomeRapLeg'
			END

			select @valore_CF_Prec =value from CTL_DOC_VALUE with(nolock)
					where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='CFRapLeg'

			if ISNULL(@CFRapLeg,'') = ''
			BEGIN
				--print 'aggiorno dall''istanza precedente'
				Update CTL_DOC_VALUE 
				set Value=@valore_CF_Prec
				where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CFRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='DataRapLeg'
			if ISNULL(@DataRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='DataRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='TelefonoRapLeg'
			if ISNULL(@TelefonoRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='TelefonoRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='CellulareRapLeg'
			if ISNULL(@CellulareRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CellulareRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='RuoloRapLeg'
			if ISNULL(@RuoloRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='RuoloRapLeg'
			END
		---------------------------------------------------------------------------------------
			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='Procura'
			Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='Procura'

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='NumProcura'
			Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NumProcura'

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='NumRaccolta'
			Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='NumRaccolta'

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='DelProcura'
			Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='DelProcura'
	
		------------------------------------------------------------------------------------
			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='StatoResidenzaRapLeg'
			if ISNULL(@StatoResidenzaRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='StatoResidenzaRapLeg2'
			if ISNULL(@StatoResidenzaRapLeg2,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoResidenzaRapLeg2'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ProvResidenzaRapLeg'
			if ISNULL(@ProvResidenzaRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ProvResidenzaRapLeg2'
			if ISNULL(@ProvResidenzaRapLeg2,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvResidenzaRapLeg2'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ResidenzaRapLeg'
			if ISNULL(@ResidenzaRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ResidenzaRapLeg2'
			if ISNULL(@ResidenzaRapLeg2,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ResidenzaRapLeg2'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='IndResidenzaRapLeg'
			if ISNULL(@IndResidenzaRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='IndResidenzaRapLeg'
			END
	    
			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='CapResidenzaRapLeg'
			if ISNULL(@CapResidenzaRapLeg,'') = ''
			BEGIN
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='CapResidenzaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='StatoRapLeg'
			
			if ISNULL(@StatoRapLeg,'') = ''
			BEGIN
					set @StatoRapLeg=@valore

					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='StatoRapLeg2'
			
			if ISNULL(@StatoRapLeg2,'') = ''
			BEGIN
					
					set @StatoRapLeg2=@valore

					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg2'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ProvinciaRapLeg'
			
			if ISNULL(@ProvinciaRapLeg,'') = ''
			BEGIN
				
					SET @ProvinciaRapLeg = @valore

					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='ProvinciaRapLeg2'
			
			if ISNULL(@ProvinciaRapLeg2,'') = ''
			BEGIN
				
					SET @ProvinciaRapLeg2 = @valore

					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg2'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='LocalitaRapLeg'
			
			if ISNULL(@LocalitaRapLeg,'') = ''
			BEGIN
					set @LocalitaRapLeg = @valore

					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg'
			END

			select @valore=value from CTL_DOC_VALUE with(nolock)
				where DSE_ID='TESTATA' and idheader=@PrevDoc and DZT_NAME='LocalitaRapLeg2'
			
			if ISNULL(@LocalitaRapLeg2,'') = ''
			BEGIN
					set @LocalitaRapLeg2 = @valore
					Update CTL_DOC_VALUE 
					set Value=@valore
					where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg2'
			END		

		END --- FINE IF RECUPERO INFO DA PRECEDENTE ISTANZA

		-- Se una sola di queste info è vuota le desumo dal CF
		--oppure se il codice fiscale utente corrente diverso da codice fiscale precedente istanza
		if ( ISNULL(@StatoRapLeg,'') = '' or ISNULL(@ProvinciaRapLeg,'') = '' or ISNULL(@LocalitaRapLeg,'') = '' or @valore_CF_Prec <> @CFRapLeg )
		BEGIN
			
			--IF LEN(@CFRapLeg) >= 16
			if dbo.fn_checkCF(@CFRapLeg)='1'
			BEGIN

				--aggiungere chimata per risolvere dicotomia del CF

				set @CodiceCatastale = SUBSTRING (@CFRapLeg,12,4) 

				declare @LastIndexOf int
				declare @CodiceIstatDelComune_formato_alfanumerico as nvarchar(100)

				-- recupero il codice catastale del comune
				select @CodiceIstatDelComune_formato_alfanumerico=CodiceIstatDelComune_formato_alfanumerico 
					from GEO_ISTAT_elenco_comuni_italiani  with(nolock) where codicecatastale=@CodiceCatastale

				IF ISNULL(@CodiceIstatDelComune_formato_alfanumerico,'') <> ''
				BEGIN

					--print 'recupero info dal codice fiscale'
					-- mi recupero comune e codice
					select @LocalitaRapLeg=DMV_DescML,@LocalitaRapLeg2=DMV_Cod  
					from LIB_DomainValues with(nolock) where DMV_DM_ID='GEO' and DMV_COD like '%-' + @CodiceIstatDelComune_formato_alfanumerico   
					and DMV_LEVEL='7'

					--tolgo l'ultimo livello cosi ottengo il codice della provincia
					set @LastIndexOf = LEN(@LocalitaRapLeg2) -  CHARINDEX('-', REVERSE(@LocalitaRapLeg2)) +1
					set @ProvinciaRapLeg2=SUBSTRING(@LocalitaRapLeg2, 0, @LastIndexOf)

					select @ProvinciaRapLeg=DMV_DescML from LIB_DomainValues 
					where DMV_DM_ID='GEO'    and DMV_LEVEL = '6' and dmv_cod=@ProvinciaRapLeg2

					--tolgo gli ultimi 3 livelli cosi ottengo il codice dello stato
				
					/*
					set @LastIndexOf = LEN(@ProvinciaRapLeg2) -  CHARINDEX('-', REVERSE(@ProvinciaRapLeg2)) +1
					set @StatoRapLeg2 = SUBSTRING(@ProvinciaRapLeg2, 0, @LastIndexOf)


					set @LastIndexOf = LEN(@StatoRapLeg2) -  CHARINDEX('-', REVERSE(@StatoRapLeg2)) +1
					set @StatoRapLeg2 = SUBSTRING(@StatoRapLeg2, 0, @LastIndexOf)


					set @LastIndexOf = LEN(@StatoRapLeg2) -  CHARINDEX('-', REVERSE(@StatoRapLeg2)) +1
					set @StatoRapLeg2 = SUBSTRING(@StatoRapLeg2, 0, @LastIndexOf)
					*/

					set @StatoRapLeg2 = dbo.getpos(@LocalitaRapLeg2,'-', 1) + '-' + dbo.getpos(@LocalitaRapLeg2,'-', 2) + '-' + dbo.getpos(@LocalitaRapLeg2,'-', 3) + '-' + dbo.getpos(@LocalitaRapLeg2,'-', 4)

					select @StatoRapLeg=DMV_DescML from LIB_DomainValues with(nolock) 
					where DMV_DM_ID='GEO'    and DMV_LEVEL = '3' and dmv_cod=@StatoRapLeg2

					Update CTL_DOC_VALUE 
						set Value=@LocalitaRapLeg
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg'

					Update CTL_DOC_VALUE 
						set Value=@LocalitaRapLeg2
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg2'

					Update CTL_DOC_VALUE 
						set Value=@ProvinciaRapLeg
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg'

					Update CTL_DOC_VALUE 
						set Value=@ProvinciaRapLeg2
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg2'

					Update CTL_DOC_VALUE 
						set Value=@StatoRapLeg
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg'

					Update CTL_DOC_VALUE 
						set Value=@StatoRapLeg2
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg2'
				
					-- metto i 3 campi del codice fiscale appena recuperati tra i not edit
					IF not exists ( select * from ctl_doc_value with(nolock) where IdHeader = @iddoc and DSE_ID = 'TESTATA' and DZT_Name = 'Not_Editable' )
					BEGIN
						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
						VALUES (@iddoc, 'TESTATA', 0, 'Not_Editable', ' StatoRapLeg , ProvinciaRapLeg , LocalitaRapLeg ' )

					END
					ELSE
					BEGIN
						Update CTL_DOC_VALUE 
						set Value= Value + ' StatoRapLeg , ProvinciaRapLeg , LocalitaRapLeg ' 
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='Not_Editable'	
					END


				 END -- FINE IF SE @CodiceIstatDelComune_formato_alfanumerico E' VUOTO
				 else
				 BEGIN
					
					--print 'svuoto i campi per non corrispondenza del codice fiscale'

					--svuotiamo i campi sul documento perchè nn c'è corrispondenza con il codice fiscale
					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg'

					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='LocalitaRapLeg2'

					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg'

					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='ProvinciaRapLeg2'

					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg'

					Update CTL_DOC_VALUE 
						set Value=''
						where DSE_ID='TESTATA' and idheader=@iddoc and DZT_NAME='StatoRapLeg2'
					


				 END

			END --FINE IF SE CF MINORE DI 16 CARATTERI

		END	  --- FINE IF RECUPERO INFO DA CF
	END  ---FINE IF CONTROLLO SE POSSO FARE UPDATE DEI DATI

END










GO
