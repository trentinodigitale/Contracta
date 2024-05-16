USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO] 	(  @idDoc_QUESTIONARIO_AMMINISTRATIVO int  )
AS
BEGIN
	SET NOCOUNT ON;


	declare @Template nvarchar( max )


	set @Template  = ''


	declare @Descrizione nvarchar( max)
	declare @DescrizioneEstesa nvarchar( max)

	declare @JSonCampiObbligatori nvarchar( max)

	declare @KeyRiga varchar(500)
	declare @KeyRigaSezione varchar(500)
	declare @Modello_Modulo varchar(500)
	declare @TipoRigaQuestionario varchar(100) 
	declare @TipoParametroQuestionario varchar(100) 
	declare @Tech_Info_Parametro nvarchar( max) 
	
	
	declare @DivSpiegazioneRelazione nvarchar( max) 
	declare @FlagSezioneAperta int
	declare @idx int
	declare @StrFilter_Domain as varchar(200)
	declare @Sezionicondizionate as nvarchar(max)
	declare @JSon_Sezionicondizionate as nvarchar(max)
	declare @StrClassObblig as varchar(200)
	declare @ChiaveUnivocaRiga as varchar(100)
	declare @ChiaveSezione as varchar(100)
	declare @FormatAllegato as nvarchar(max)
	declare @TipoFileAllegato as nvarchar(max)
	declare @StartTipoFile as int
	declare @EndTipoFile as int
	declare @Coda_Tech_Info_Parametro nvarchar( max) 
	declare @EsitoRiga as nvarchar(max)
	declare @TemplateScript as nvarchar(max)
	declare @TemplateCampiHidden as nvarchar(max)

	declare @crlf varchar(10)

	set @JSonCampiObbligatori = ''
	set @JSon_Sezionicondizionate = ''
	set @EsitoRiga = ''
	set @TemplateScript = ''
	set @TemplateCampiHidden = ''

	set @crlf  = '
'

	set @Modello_Modulo = 'MODULO_QUESTIONARIO_AMMINISTRATIVO_' + cast(  @idDoc_QUESTIONARIO_AMMINISTRATIVO as varchar(20))
	set @FlagSezioneAperta = 0


	-------------------------------------------------------
	-- cancella una eventuale presenza prima di crearlo
	-------------------------------------------------------
	delete from CTL_Models where [MOD_ID] = @Modello_Modulo
	delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo
	delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo		
	
	delete from CTL_Models where [MOD_ID] = @Modello_Modulo + '_SAVE'
	delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo + '_SAVE'
	delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo + '_SAVE'
	


	set @Template = @Template + ''
	set @idx = 0


	-------------------------------------------------------
	-- Ciclo sulle righe per la costruzione del modulo da compilare
	-------------------------------------------------------
	declare CurSezioni Cursor local static for 

		Select  replace( P.KeyRiga , '.' , '_' ) , P.TipoRigaQuestionario , P.Descrizione , P.DescrizioneEstesa , 
					P.TipoParametroQuestionario , P.Tech_Info_Parametro, P.Sezionicondizionate , P.ChiaveUnivocaRiga ,
					S.ChiaveUnivocaRiga as ChiaveSezione,
					P.EsitoRiga

			FROM 
				[dbo].[Document_Questionario_Amministrativo] P with(nolock)
					inner join
						[dbo].[Document_Questionario_Amministrativo] S with(nolock) on S.idHeader=P.idHeader and S.TipoRigaQuestionario='Sezione' 
														and S.KeyRiga = dbo.getPos(P.Keyriga,'.',1)

			where 
				P.idHeader= @idDoc_QUESTIONARIO_AMMINISTRATIVO 
			order by P.[idrow]

	
	open CurSezioni

	FETCH NEXT FROM CurSezioni 	INTO @KeyRiga, @TipoRigaQuestionario ,  @Descrizione , @DescrizioneEstesa , @TipoParametroQuestionario , @Tech_Info_Parametro, @Sezionicondizionate , @ChiaveUnivocaRiga , @ChiaveSezione, @EsitoRiga
	WHILE @@FETCH_STATUS = 0
	BEGIN


		-------------------------------------------------------
		-- SEZIONE
		-------------------------------------------------------
		if @TipoRigaQuestionario = 'Sezione'
		begin

			-- se c'è una sezione precedente devo chiudere la DIV
			if @FlagSezioneAperta = 1
				set @Template = @Template + '</div>' + @crlf


			-- se è presente una relazione
			set @DivSpiegazioneRelazione = '' 
			if isnull(@EsitoRiga,'') <> ''
			begin
				
				--recupero il contenuto del tag title dell'immagine di info
				set @DivSpiegazioneRelazione = isnull(@EsitoRiga,'')

				set @DivSpiegazioneRelazione = replace( @DivSpiegazioneRelazione , '<br>' , '')
				
				set @DivSpiegazioneRelazione = dbo.GetPos( @DivSpiegazioneRelazione ,'<img src="../images/Domain/state_info24x24.png" title="',2)
				
				set @DivSpiegazioneRelazione = replace( @DivSpiegazioneRelazione ,'">','')
				
			end 


			-- Descrizione sintetica
			set @Template = @Template + 
					@crlf + '<!-- Apertura Sezione ' + @KeyRiga + ' -->' + @crlf 
					+ '<div class="panel ModuloQuestionario col-md-12">

							<div class="panel-heading" >' + @KeyRiga + ' ' + @Descrizione + '</div>
							' 
							+ '<div class="Questionario_Sezione_Condizionata" >' + @DivSpiegazioneRelazione + '</div>' +
							'
						</div>
						'
			set @FlagSezioneAperta = 1 -- segno che la sezione è aperta e dopo deve essere chiusa
			

			-- contenitore della sezione per consentire di nasconderla se relazionata
			set @Template = @Template + '<div id="SEZIONE_' + @ChiaveUnivocaRiga + '" class="Questionario_sezione container">' + @crlf


			-- descrizione estesa se presente
			if @DescrizioneEstesa <> ''
				set @Template = @Template + '	<div class="Descrizione_Sezione col-md-12 "> ' + replace( dbo.HTML_Encode(  @DescrizioneEstesa ), @crlf , '<br />' )  + '</div>' + @crlf



		end

		-------------------------------------------------------
		-- NOTE
		-------------------------------------------------------
		if @TipoRigaQuestionario = 'Nota'
		begin


			-- Descrizione sintetica
			set @Template = @Template +  '<div class="col-md-12 Questionario_Nota_Titolo">' + replace(@KeyRiga,'_','.') + ' ' + @Descrizione + '</div>'+ @crlf
		
			
			-- descrizione estesa se presente
			if @DescrizioneEstesa <> ''
				set @Template = @Template + '	<div class="col-md-12 Questionario_Nota_Descrizione"> ' + replace( dbo.HTML_Encode(  @DescrizioneEstesa ), @crlf , '<br />' )  + '</div>' + @crlf


		end


		-------------------------------------------------------
		-- PARAMETRO
		-------------------------------------------------------
		if @TipoRigaQuestionario = 'Parametro'
		begin
			
			set @StrClassObblig=''

			-- se il parametro è obbligatorio
			if charindex( '"obbligatorio":true' , @Tech_Info_Parametro ) > 0 
			begin
				--insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
				--	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Obbligatory' as MAP_Propety , '1' as MAP_Value ,'TEMPLATE_GARA' as MA_Module


				-- elenco campi obbligatori
				set @JSonCampiObbligatori = @JSonCampiObbligatori + 'PARAMETRO_' + @KeyRiga + '@@@' + @ChiaveSezione + ','

				set @StrClassObblig = ' obb '

			end

			-- Descrizione sintetica
			set @Template = @Template +  '<div class="row" ><div class="col-md-6" > <div class="col-md-12 Questionario_Parametro_Titolo' + @StrClassObblig + '">' + replace(@KeyRiga,'_','.') + ' ' + @Descrizione + '</div>'+ @crlf

			
			-- descrizione estesa se presente
			if @DescrizioneEstesa <> ''
				set @Template = @Template + '	<div class="col-md-12 Questionario_Parametro_Descrizione"> ' + replace( dbo.HTML_Encode(  @DescrizioneEstesa ), @crlf , '<br />' )  + '</div>' + @crlf


			set @Template = @Template +  '</div>'  -- chiude la div interna


			set @Template = @Template + '	<div class="col-md-6 Questionario_Parametro">(((PARAMETRO_' +  @KeyRiga + ')))</div>'  + @crlf


			set @Template = @Template +  '</div>'  -- chiude la div esterna


			-------------------------------------------------------
			-- inserisce il record per la creazione del modello
			-------------------------------------------------------
			set @idx = @idx  + 1
			insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
				select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga as MA_DZT_Name, '' as MA_DescML, @idx as MA_Pos, /*dz.DZT_Len*/ 0  as   MA_Len, @idx as MA_Order, 
						 dz.DZT_Type, 
						 dz.DZT_DM_ID, 
						 dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
						 dz.DZT_Format,
						 dz.DZT_Help, dz.DZT_Multivalue, 
						 'TEMPLATE_GARA' as MA_Module
					from LIB_Dictionary dz with(nolock)  
					where dz.DZT_Name = 'PARAMETRO_QUESTIONARIO_' + @TipoParametroQuestionario

			
      
			-- se parametro TESTO aggiungo il "massimo numero caratteri" sulla proprietà MaxLen della CTL_ModelAttributeProperties
		IF @TipoParametroQuestionario IN ('Testo')
    BEGIN
      DECLARE @StartMaxNumeroCaratteri AS INT = CHARINDEX('"MaxNumeroCaratteri":"', @Tech_Info_Parametro)

      IF @StartMaxNumeroCaratteri > 0
      BEGIN

        SET @StartMaxNumeroCaratteri = @StartMaxNumeroCaratteri + 22
        SET @Coda_Tech_Info_Parametro = SUBSTRING(@Tech_Info_Parametro, @StartMaxNumeroCaratteri, LEN(@Tech_Info_Parametro))
        DECLARE @EndMaxNumeroCaratteri AS INT = CHARINDEX('"', @Coda_Tech_Info_Parametro)
        DECLARE @MaxNumeroCaratteri AS VARCHAR(50)
        SET @MaxNumeroCaratteri = SUBSTRING(@Tech_Info_Parametro, @StartMaxNumeroCaratteri, @EndMaxNumeroCaratteri - 1)

        --UPDATE Document_Questionario_Amministrativo
        --SET Tech_Info_Parametro = '{"obbligatorio":true,"tipoParametro":"Testo","row":"0","MaxNumeroCaratteri":"00765"}'
        --WHERE idHeader = 470716 AND KeyRiga=4.1
        
		 IF @MaxNumeroCaratteri <> ''
         BEGIN
           INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
           SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'MaxLen' AS MAP_Propety, @MaxNumeroCaratteri AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module
           
           --UPDATE Document_Questionario_Amministrativo
           --SET Tech_Info_Parametro = '{"obbligatorio":true,"tipoParametro":"Testo","row":"0","MaxNumeroCaratteri":"12890"}'
           --WHERE idHeader = 470716 AND KeyRiga=4.1
         END
      END
    END



			-- se parametro scelta singola/multipla aggiungo il filtro sul dominio
			if @TipoParametroQuestionario in ('sceltasingola','sceltamultipla')
			begin
				
				set @StrFilter_Domain = ''
				set @StrFilter_Domain ='SQL_WHERE= IdHeader = ' + cast( @idDoc_QUESTIONARIO_AMMINISTRATIVO as varchar(100)) + ' and DMV_Father =''' + replace(@KeyRiga,'_','.') + ''''

				insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
					select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Filter' as MAP_Propety , @StrFilter_Domain  as MAP_Value ,'TEMPLATE_GARA' as MA_Module
				

				--per i paraemtri a scelta multipla inserisco la format OMA
				if @TipoParametroQuestionario = 'sceltamultipla'
				begin
					insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
						select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Format' as MAP_Propety , 'OMAE99'  as MAP_Value ,'TEMPLATE_GARA' as MA_Module
					
				end


				--se ci sono SezioniCondizionate sul parametro aggiorno la stringa che tiene elenco dei paraemtri che inflenzano
				--sezioni
				if @Sezionicondizionate <> ''
				begin
					set @JSon_Sezionicondizionate = @JSon_Sezionicondizionate + 'PARAMETRO_' + @KeyRiga + ':' + @Sezionicondizionate + ','
				end

			end

			--per tutti i parametri aggiungo una funzione di onchange che serve a farmi capire che ho fatto un cambiamento
			--sul Modulo Questionario Amministrativo 
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
				select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'OnChange' as MAP_Propety , 'OnChangeFields_QUESTIONARIO(this);'  as MAP_Value ,'TEMPLATE_GARA' as MA_Module
						


			--per i parametri di tipo allegato devo aggiungere la format con le estensioni ammesse
			if @TipoParametroQuestionario in ('Allegato','AllegatoFirmato')
			begin
				
				--setto la format minima
				set @FormatAllegato = 'INT'
			
				--se allegato firmato aggiungo la V
				if @TipoParametroQuestionario = 'AllegatoFirmato'
				begin
					set @FormatAllegato =  @FormatAllegato + 'V' 
				end

				--se ci sono estensioni ammesse le accodo alla format
				set @StartTipoFile = 0
				set @EndTipoFile = 0
				set @TipoFileAllegato=''

				set @StartTipoFile = CHARINDEX('"TipoFile_Value":',@Tech_Info_Parametro)
				if @StartTipoFile > 0
				begin
					
					set @Coda_Tech_Info_Parametro = SUBSTRING(@Tech_Info_Parametro,@StartTipoFile,LEN(@Tech_Info_Parametro))

					set @EndTipoFile = CHARINDEX(',',@Coda_Tech_Info_Parametro)

					if @EndTipoFile > 0
					begin
						set @TipoFileAllegato = SUBSTRING ( @Tech_Info_Parametro , @StartTipoFile + 18 , @EndTipoFile - (18 + 2))

						--se ci sono estensioni ammesse
						if @TipoFileAllegato <>''

						begin
							set @FormatAllegato = @FormatAllegato + 'EXT:' + SUBSTRING ( REPLACE(@TipoFileAllegato ,'###',','),2,len( REPLACE(@TipoFileAllegato ,'###',','))-2) + '-'
						end
					end
				end

				--aggiungo la format per gli allegati
				insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
					select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Format' as MAP_Propety , @FormatAllegato  as MAP_Value ,'TEMPLATE_GARA' as MA_Module
			

			end



		end


	
		FETCH NEXT FROM CurSezioni 	INTO @KeyRiga, @TipoRigaQuestionario ,  @Descrizione , @DescrizioneEstesa , @TipoParametroQuestionario , @Tech_Info_Parametro, @Sezionicondizionate, @ChiaveUnivocaRiga, @ChiaveSezione, @EsitoRiga
	END 
	CLOSE CurSezioni
	DEALLOCATE CurSezioni


	-- chiudo l'html dell'ultima sezione
	if @FlagSezioneAperta = 1
		set @Template = @Template + '</div>' + @crlf

	set @TemplateScript = @TemplateScript  + '<script type="text/javascript">'
	
	--aggiungo in javascript le due variabili per gli obbligatori e per le sezioni condizionate
	if @JSonCampiObbligatori <> ''
	begin
		--tolgo ultima virgola
		set @JSonCampiObbligatori = LEFT(@JSonCampiObbligatori,len(@JSonCampiObbligatori)-1)
	end
	
	
	set @TemplateScript = @TemplateScript  + 'var JsonCampiObbligatori = ''' + @JSonCampiObbligatori + ''';' + @crlf
	set @TemplateCampiHidden = @TemplateCampiHidden + '<input type="hidden" id="ModuloQuestionario_Obbligatori" name="ModuloQuestionario_Obbligatori" value="' + @JSonCampiObbligatori + '">'

	if @JSon_Sezionicondizionate <> ''
	begin
		--tolgo ultima virgola
		set @JSon_Sezionicondizionate = LEFT(@JSon_Sezionicondizionate,len(@JSon_Sezionicondizionate)-1)
	end
	
	set @TemplateScript = @TemplateScript  + 'var JSon_Sezionicondizionate = ''' + replace(@JSon_Sezionicondizionate,'''','\''') + ''';'
	set @TemplateCampiHidden = @TemplateCampiHidden + '<input type="hidden" id="ModuloQuestionario_SezioniCondizionate" name="ModuloQuestionario_SezioniCondizionate" value="' + replace(@JSon_Sezionicondizionate,'"','""') + '">'

	set @TemplateScript = @TemplateScript  + '</script>'

	set @Template = @TemplateScript + @TemplateCampiHidden + @Template 

	-----------------------
	-- creo il modello agganciando il template appena creato
	-----------------------


	-- crea il modello di salvataggio e rappresentazione
	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select @Modello_Modulo as MOD_ID, @Modello_Modulo as MOD_Name, @Modello_Modulo as MOD_DescML, 1 as MOD_Type, 1 as MOD_Sys, '' as MOD_help, 'Type=posizionale&DrawMode=1&NumberColumn=2&Path=../../&PathImage=../../CTL_Library/images/Domain/' as MOD_Param, 'TEMPLATE_GARA' as MOD_Module , @Template as  MOD_Template  


	---- creare il campo del modello che contiene tutti i campi obbligatori
	--set @idx = @idx  + 1
	--insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
	--	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga as MA_DZT_Name, '' as MA_DescML, @idx as MA_Pos,  0  as   MA_Len, @idx as MA_Order, 
	--				dz.DZT_Type, 
	--				dz.DZT_DM_ID, 
	--				dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
	--				dz.DZT_Format,
	--				dz.DZT_Help, dz.DZT_Multivalue, 
	--				'TEMPLATE_GARA' as MA_Module
	--		from LIB_Dictionary dz with(nolock)  
	--		where dz.DZT_Name = 'PARAMETRO_QUESTIONARIO_' + @TipoParametroQuestionario

	--insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
	--	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Hide' as MAP_Propety , '1' as MAP_Value ,'TEMPLATE_GARA' as MA_Module




	---------------------------------------------------------------------------------------------
	-- MODELLO PER IL SALVATAGGIO
	-- genero il modello per copia dalla visualizzazione togliendo tutti gli attributi non editabili
	---------------------------------------------------------------------------------------------

	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select @Modello_Modulo + '_SAVE' as MOD_ID, @Modello_Modulo + '_SAVE' as MOD_Name, @Modello_Modulo + '_SAVE' as MOD_DescML, 1 as MOD_Type, 1 as MOD_Sys, '' as MOD_help, '' as MOD_Param, 'TEMPLATE_GARA' as MOD_Module , @Template as  MOD_Template  

	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		select MA_MOD_ID + '_SAVE' , MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module
			from CTL_ModelAttributes with(nolock) 
			where  MA_MOD_ID = @Modello_Modulo 

	
	--aggiungo nei modelli i campi per gli attributi obbligatori e le sezioni condizionate 
	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		select @Modello_Modulo + '_SAVE' as MA_MOD_ID, DZT_Name, '' as MA_DescML, 
							100 as MA_Pos, /*dz.DZT_Len*/ 0  as   MA_Len, 100 as MA_Order, 
						 dz.DZT_Type, 
						 dz.DZT_DM_ID, 
						 dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
						 dz.DZT_Format,
						 dz.DZT_Help, dz.DZT_Multivalue, 
						 'TEMPLATE_GARA' as MA_Module
					from LIB_Dictionary dz with(nolock)  
					where dz.DZT_Name in ( 'ModuloQuestionario_Obbligatori','ModuloQuestionario_SezioniCondizionate')

     insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		select @Modello_Modulo as MA_MOD_ID, DZT_Name, 'ModuloQuestionario_Obbligatori' as MA_DescML, 
							100 as MA_Pos, /*dz.DZT_Len*/ 0  as   MA_Len, 100 as MA_Order, 
						 dz.DZT_Type, 
						 dz.DZT_DM_ID, 
						 dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
						 dz.DZT_Format,
						 dz.DZT_Help, dz.DZT_Multivalue, 
						 'TEMPLATE_GARA' as MA_Module
					from LIB_Dictionary dz with(nolock)  
					where dz.DZT_Name in ( 'ModuloQuestionario_Obbligatori','ModuloQuestionario_SezioniCondizionate')


end



GO
