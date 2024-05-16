USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_GARA_DEFINIZIONE_STRUTTURA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[BANDO_GARA_DEFINIZIONE_STRUTTURA]  ( @IdNewDoc int , @idDoc int = 0, @idAzi int = 0 )
AS
BEGIN
	
 

  IF ( (SELECT TipoDoc FROM ctl_doc WITH (NOLOCK) WHERE Id = @IdNewDoc) = 'TEMPLATE_GARA' )
  BEGIN

	  EXEC TEMPLATE_GARA_DEFINIZIONE_STRUTTURA @IdNewDoc, @idDoc, @idAzi

  END
  ELSE
  BEGIN  

  	declare @tipodoc as varchar(200)
  	declare @TipoProceduraCaratteristica as varchar(200)
  	declare @TipoSceltaContraente as varchar(200)
  	declare @tipobandogara varchar(500)
  	declare @proceduraGara varchar(500)
  	declare @richiestaCIG varchar(100)
  	declare @fascicoloGenerale varchar(500)
  	declare @idPfuAOO int
	declare @idAziEnte INT = 0
	declare @importoBaseAsta as float
	declare @pcp_TipoScheda as nvarchar(200)
	declare @pcp_VersioneScheda as varchar(50)
	declare @TipoAppaltoGara as varchar(50)
	declare @Modello_INTEROP_PCP as varchar(100)
	declare @IdaziMaster as int

  	select 
  			@tipodoc=TipoDoc,
  			@TipoProceduraCaratteristica=TipoProceduraCaratteristica,
  			@tipobandogara = TipoBandoGara,
  			@proceduraGara = DB.ProceduraGara,
  			@TipoSceltaContraente=DB.TipoSceltaContraente,
  			@richiestaCIG = db.RichiestaCigSimog,
  			@fascicoloGenerale = fascicoloSecondario,
  			@idPfuAOO=IdPfu,
			@idAziEnte = gara.Azienda,
			@importoBaseAsta = ImportoBaseAsta,
			@TipoAppaltoGara = DB.TipoAppaltoGara
  		from ctl_doc gara with(nolock)
  				inner join document_bando DB with(nolock) on id=DB.idheader 
  				left join Document_dati_protocollo b with(nolock) on b.idHeader = Id	
  		where id=@IdNewDoc

  	-- RETTIFICO IL MODELLO DI TESTATA CON QUELLO DEFINITO 	
  	IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoProceduraCaratteristica,'') = ''
  	BEGIN

  		DELETE FROM CTL_DOC_SECTION_MODEL WHERE DSE_ID='TESTATA' and IdHeader=@IdNewDoc

  		/* SE AVVISO O RISTRETTA-BANDO */
  		IF  @tipobandogara = '1' or ( @proceduraGara = '15477' and @tipobandogara = '2' ) or (@proceduraGara = '15583' and (@tipobandogara = '4' or @tipobandogara = '5'))
  		BEGIN
  
  			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values ( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_AVVISO' )
  
  		END

  	END
  
  	-- BANDO_GARA-RDO
  	IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoProceduraCaratteristica,'') = 'RDO'
  	BEGIN		
  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  			
  		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  			values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_RDO' )
  	END
	
	--recupero se ATTIVO Cottimo_Gara_Unificato
	declare @Cottimo_Gara_Unificato_Attivo as varchar(10)
	select @Cottimo_Gara_Unificato_Attivo = dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 )
	
  	-- BANDO_GARA-COTTIMO
  	IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoProceduraCaratteristica,'') = 'Cottimo' 
  	BEGIN	
		
		if @Cottimo_Gara_Unificato_Attivo <> 'YES'
		begin

  			delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_COTTIMO' )
		end
		else
		begin
			--se è un avviso utilizzo lo stesso modello dell'avviso della negoziata
			IF  @tipobandogara = '1'
			begin
				delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  					values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_AVVISO' )
			end
		end


  	END
	


  	-- BANDO_GARA-ACCORDOQUADRO
  	IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoSceltaContraente,'') = 'ACCORDOQUADRO'
  	BEGIN		
  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  			
  		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  			values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_ACCORDOQUADRO' )
  	END
  
  	-- BANDO_ASTA
  	IF @tipodoc = 'BANDO_ASTA' or ISNULL(@TipoProceduraCaratteristica,'') = 'RilancioCompetitivo'
  	BEGIN
  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  	END
  
  	/*AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO*/ 
  	IF @tipodoc = 'BANDO_GARA' and  @ProceduraGara in ( '15583','15479' ) and @tipobandogara = '3'
  	begin
  		
  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  		
  		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  			values ( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_GAREINFORMALI' )
		


  	end
  	
  	/*SE SUL CLIENTE NON E' ATTIVO attestazione_di_partecipazione setto a no il campo ClausolaFideiussoria sulla document_bando*/
  	if ( dbo.PARAMETRI('ATTIVA_MODULO','attestazione_di_partecipazione','ATTIVA','YES',-1) <> 'YES' )
  	BEGIN
  		update document_bando set ClausolaFideiussoria='0' where idHeader=@IdNewDoc
  	END
  
  	declare @richiestaTED as varchar(10) = 'no'
  
  	IF dbo.IsTedActive(@idAzi) = 1 and @richiestaCIG = 'si'
  	BEGIN
  	
  		-- Nel caso dell'appalto specifico, richiesta di offerta, richiesta di preventivo ed affidamento diretto il campo Invio GUUE in Testata deve essere nascosto oppure non selezionabile e bloccato su no
  		IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoProceduraCaratteristica,'') = '' and  isnull(@ProceduraGara,'') not in ( '15583','15479' ) 
  		BEGIN
  			set @richiestaTED = 'si'
  		END
  
  	END
  
  	-- BANDO_GARA-AFFIDAMENTO DIRETTO SEMPLIFICATO
  	IF @tipodoc = 'BANDO_GARA' and ISNULL(@TipoProceduraCaratteristica,'') = 'AffidamentoSemplificato'
  	BEGIN		
  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  		
		--SE ATTIVO PARAMETRO CampiEnteProponente UTILIZZO MODELLO ESTESO
		IF dbo.PARAMETRI('AFFIDAMENTO_SEMPLIFICATO' ,'CampiEnteProponente', 'DefaultValue', 'NO', -1 ) = 'YES'
		BEGIN
		  	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI_PROPONENTE' )			
		END
		ELSE
		BEGIN
		  	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdNewDoc , 'TESTATA' , 'BANDO_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI' )
		END

  	END
  
  	update document_bando set RichiestaTED = @richiestaTED where idHeader=@IdNewDoc
  
  	-- vede se deve rendere editabile il fascicolo
  	-- è non editabile solo se è attivo il genera fascicolo per quel documento-AOO
  	declare @contesto varchar(500)
  	declare @sottoTipo varchar(500)
  	declare @noteditable varchar(500)
  	
  	set @noteditable = ''
  
  	IF EXISTS ( select id from lib_dictionary where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES' )
  	begin
  
  		set @contesto=dbo.GetContestoFascicolo(@tipoDoc,@IdNewDoc)
  
  		IF isnull(@fascicoloGenerale,'') = ''
  			and EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc 
  				and isnull(contesto,'') = @contesto /* and attivo = 1*/ and deleted = 0 
  				and aoo = dbo.getAOO( @idPfuAOO ) and generaFascicolo = 1 )
  		BEGIN
  			set @noteditable = ' fascicoloSecondario ' 
  		end
  	end
  
  	update Document_dati_protocollo set noteditable = @noteditable where idHeader=@IdNewDoc
  
  END

   	-- attività 544634 - nuova tabella sotto la sezione caption per l'interoperabilità/e-forms
	IF NOT EXISTS(select a.idRow from Document_E_FORM_CONTRACT_NOTICE a with(nolock) where a.idheader = @IdNewDoc )
	BEGIN
			
		DECLARE @urlAtti nvarchar(1000) = ''

		--questa sys sarà vuota come default e verrà specializzata per cliente
		SELECT @urlAtti = a.DZT_ValueDef from LIB_Dictionary a with(nolock) where DZT_Name = 'SYS_TED_DOCUMENTI_GARA'

		INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
			VALUES (  @IdNewDoc, @urlAtti )

		----questa sys sarà vuota come default e verrà specializzata per cliente
		--if dbo.PARAMETRI('BANDO_GARA','URL_BT15','ATTIVO','NO','-1') = 'YES'
		--begin
		--	--nuova gestione 
		--	--Indirizzo documenti di gara - prepopolare il campo con il dettaglio del bando
		--	set @urlAtti = dbo.GetUrlDettagliBandoByID(@IdNewDoc)

		--	INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
		--		VALUES (  @IdNewDoc, @urlAtti )
		--end
		--else
		--begin
		--	SELECT @urlAtti = a.DZT_ValueDef from LIB_Dictionary a with(nolock) where DZT_Name = 'SYS_TED_DOCUMENTI_GARA'

		--	INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
		--		VALUES (  @IdNewDoc, @urlAtti )
		--end
		
		--generazione uid dopo l'insert 
		DECLARE @CONTRACT_FOLDER_ID nvarchar(500) = ''
			
		-- si lega alla PCP solamente se non è un avviso di un affidamento diretto
		if not ( @proceduraGara = '15583' and @tipobandogara in ( '4','5' ) )
			and dbo.attivoPCP() = 1
		BEGIN
			SET @CONTRACT_FOLDER_ID = lower(newid())
		END

		update Document_E_FORM_CONTRACT_NOTICE
				set CN16_CODICE_APPALTO = @CONTRACT_FOLDER_ID
					, cn16_ContractingSystemTypeCode_framework = case when ISNULL(@TipoSceltaContraente,'') = 'ACCORDOQUADRO' then 'true' else 'false' end
			where idHeader = @IdNewDoc

	END


	IF NOT EXISTS(select a.idRow from Document_PCP_Appalto a with(nolock) where a.idheader = @IdNewDoc )
	BEGIN
			
		--chiamo una SP che inizializza i campi della scheda PCP
		EXEC INIT_SCHEDA_PCP_GARA @IdNewDoc, @idPfuAOO

	END
	
	IF @proceduraGara = '15583' and @tipobandogara in ( '4','5' ) 
	begin
		if not exists (select idrow from Document_PCP_Appalto where idHeader= @IdNewDoc)
		begin
			INSERT INTO Document_PCP_Appalto 
				( idHeader,MOTIVO_COLLEGAMENTO)
				values 
				( @IdNewDoc , '100')

		end
		else
		begin
			update Document_PCP_Appalto set MOTIVO_COLLEGAMENTO = '100' where idheader = @IdNewDoc
		end

	end

END






GO
