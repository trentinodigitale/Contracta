USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DECODIFICA_LOG]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[OLD2_DECODIFICA_LOG] ( @id int )
as
begin
	declare @CriterioDecodifica  as varchar(MAX) 
	declare @paginaDiArrivo as varchar(MAX) 
	declare @paginaDiPartenza as varchar(MAX) 
	declare @querystring as nvarchar(max)
	declare @form as varchar(MAX)
    declare @browserusato as nvarchar(max)
	declare @descrizione as nvarchar(max)

	declare @idMsg  int
	--declare @idMsg varchar(100)

	declare @Ret nvarchar(MAX)
	declare @lItypePar varchar(MAX)
	declare @lISubTypePar varchar(MAX)
	declare @DocName varchar(MAX)
    declare @IdAzienda int
    declare @Azione varchar(MAX)
    declare @Sezione varchar(MAX)
	declare @nodo varchar(MAX)

	declare @DocPartenza varchar(MAX) 
	declare @Titolo varchar(MAX) 
	
    declare @TempApp as varchar(MAX)
	declare @idpfu as int

	declare @SOURCE varchar(max)
	declare @IDDOC varchar(100)
     

--	select @paginaDiArrivo = paginaDiArrivo , @CriterioDecodifica  = CriterioDecodifica  from dbo.CTL_LOG_UTENTE_LAVORO l
--			inner join CTL_LOG_DECODIFICA d on paginaDiArrivo = URL
--	where l.id = @id
--
--	if isnull( @CriterioDecodifica , '' ) <> '' 
--	begin
--
--		set @CriterioDecodifica  = replace( @CriterioDecodifica  , '<ID_DOC>' , cast( @id as varchar ))
--
--		exec (@CriterioDecodifica )
--	end

	-- recupera lo step da decodificare
	select 
		@paginaDiArrivo =  cast(paginaDiArrivo as varchar(MAX)),
		@paginaDiPartenza =  cast(paginaDiPartenza as varchar(MAX)),
		@querystring = cast(  querystring as varchar(MAX)),
		--@form = dbo.GetValue( 'FORM',cast(  form as varchar(MAX))),	
		@form = case when dbo.GetValue( 'FORM',cast(  form as varchar(MAX))) = '' then form else dbo.GetValue( 'FORM',cast(  form as varchar(MAX))) end,
		@idpfu = idpfu,      
		@browserusato  = cast(  browserusato as varchar(MAX)),
		@descrizione= dbo.GetValue( 'DESC',cast(  form as varchar(MAX)))
		from 
			dbo.CTL_LOG_UTENTE_LAVORO l with (nolock)
		where id = @id
    
	--RECUPERO IL NODO E LO METTO NEL FORM
	if CHARINDEX('IP-SERVER:',@descrizione)>0
	BEGIN

		select @nodo='NODO: ' + substring(@descrizione,11,CHARINDEX('SESSIONFIXATION',@descrizione)-12)
		update CTL_LOG_UTENTE_LAVORO set form=@nodo + ISNULL(cast(@form as nvarchar(max)),'') where id=@id

	END


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/NewDoc.asp'
	begin

		set  @lItypePar = dbo.GetValue( 'lItypePar' ,@querystring) 
		set  @lISubTypePar = dbo.GetValue( 'lISubTypePar' ,@querystring) 
		set  @Ret = dbo.GetValue( 'lIdMsgSource' ,@querystring) 

		if isnumeric(@Ret) = 1
		begin
			-- se ha trovato l'id del messaggio di partenza recupera il tipo
			set @idMsg = cast( @Ret as int )

			select @Ret = ' messaggio sorgente ''' + cast( mlngDesc_I as varchar(MAX)) + ''' - Protocollo : ' + protocollobando  from TAB_MESSAGGI_FIELDS  with (nolock)
					inner join dbo.Document with (nolock) on iType = dcmIType and   iSubType = dcmIsubType and IdMsg = @idMsg
					inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng


			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
					from Document with (nolock)
						inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
					where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 

		end

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Nuovo documento ''' + @DocName + '''' + @Ret where id = @id
	
	end 


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Aflcommon/FolderGeneric/SaveDoc.asp'
	begin

		set  @Ret = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza) 

		if isnumeric(@Ret) = 1
		begin
			-- se ha trovato l'id del messaggio recupera il tipo
			set @idMsg = cast( @Ret as int )

			select @Ret = '''' + cast( mlngDesc_I as varchar(MAX)) + ''' - Protocollo : ' + protocollobando  
				from TAB_MESSAGGI_FIELDS  with (nolock)
					inner join dbo.Document with (nolock) on iType = dcmIType and   iSubType = dcmIsubType
					inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
				where  IdMsg = @idMsg


			if dbo.GetValue( 'strCommandPar' , @querystring ) = 'SEND'
			begin
				update CTL_LOG_UTENTE_LAVORO set descrizione = 'Invio del documento ' + @Ret where id = @id
			end
			else
			begin
				update CTL_LOG_UTENTE_LAVORO set descrizione = 'Salvataggio del documento ' + @Ret where id = @id
			end

		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/SendDoc.asp'
	begin

		set  @Ret = dbo.GetValue( 'lIdMsgPar' ,@querystring) 

		if isnumeric(@Ret) = 1
		begin
			-- se ha trovato l'id del messaggio recupera il tipo
			set @idMsg = cast( @Ret as int )

			select @Ret = '''' + cast( mlngDesc_I as varchar(MAX)) + ''' - Protocollo : ' + protocollobando  from TAB_MESSAGGI_FIELDS with (nolock)
					inner join dbo.Document with (nolock) on iType = dcmIType and   iSubType = dcmIsubType and IdMsg = @idMsg
					inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng

		end

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Invio del documento ' + @Ret where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/AllegatiNew.asp'
	begin
                
		set  @Ret = dbo.GetValue( 'elementoArea' ,@querystring) 

		if isnumeric(@Ret) = 1
		begin
			if @paginaDiPartenza like '%/Application/aflcommon/foldergeneric/UploadScript1.asp%'
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'aggiunto allegato ' + @Ret where id = @id        
			else        
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'apertura finestra per selezionare allegato ' + @Ret where id = @id
		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/UploadScript1.asp'
	begin
                
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Salva allegato '  where id = @id        

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Aflcommon/FolderGeneric/PrintDoc.asp'
	begin

		set  @Ret = dbo.GetValue( 'lIdMsgPar' ,@querystring) 

		if isnumeric(@Ret) = 1
		begin
			-- se ha trovato l'id del messaggio recupera il tipo
			set @idMsg = cast( @Ret as int )

			select @Ret = '''' + cast( mlngDesc_I as varchar(MAX)) + ''' - Protocollo : ' + protocollobando  
				from TAB_MESSAGGI_FIELDS with (nolock)
					inner join dbo.Document with (nolock)on iType = dcmIType and   iSubType = dcmIsubType
					inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
				where  IdMsg = @idMsg

		end

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Dettaglio del documento ' + @Ret where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLCommon/FolderGeneric/OpenDoc.asp'
	begin

		set  @Ret = dbo.GetValue( 'lIdMsgPar' ,@querystring) 

		if isnumeric(@Ret) = 1
		begin
			-- se ha trovato l'id del messaggio recupera il tipo
			set @idMsg = cast( @Ret as int )

			select @Ret = '''' + cast( mlngDesc_I as varchar(MAX)) + ''' - Protocollo : ' + protocolloofferta + ' - Protocollo Bando : ' + protocollobando
				from TAB_MESSAGGI_FIELDS with (nolock)
					inner join dbo.Document with (nolock) on iType = dcmIType and   iSubType = dcmIsubType
					inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
				where  IdMsg = @idMsg
		end

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura del documento ' + @Ret where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/ExecDocProcess.asp'
	begin

		set  @Ret = dbo.GetValue( 'PROCESS_PARAM' ,@querystring) 

		if @Ret = 'LOAD_MICROLOTTI,OFFERTA' 
		begin
			-- se ha trovato il parametro
			set @Ret = 'Verifica coerenza dei lotti importati'

		end

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Esecuzione processo :' + @Ret where id = @id


	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Functions/errore.asp'
	begin

		set @Ret = dbo.GetValue( 'strErrore' ,@querystring) 

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzato errore :' + @Ret where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/Viewer.asp'
	begin

			if exists( select * from lib_dictionary where dzt_name = 'SYS_ACCESSIBLE' and DZT_ValueDef <> 'YES' )
			begin

				set @Ret = ''
				select @Ret = @Ret + LFN_CaptionML + ','
					from dbo.LIB_Functions with (nolock)
					where replace( LFN_paramTarget , '&amp;' , '&' ) like '%' + left( @querystring ,200) + '%'

		--		if @Ret = '' 
		--		begin

					select @Ret = @Ret + cast( mlngDesc_I as varchar(4000)) + ','
						from MPCommands with (nolock)
							inner join multilinguismo with (nolock) on mpcName = IdMultiLng
						where mpcLink like '%' + left( @querystring ,200) + '%'


		--		end
			end
			else
			begin
					set @Ret = dbo.UrlDecodeUTF8( dbo.CNV( dbo.GetValue('Caption' , @querystring) , 'I' ) )
			end

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Cartella per la ricerca e visualizzazione liste documenti - ' + @Ret where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/ViewerFiltro.asp'
	begin

			set @Ret = ''
			select @Ret = @Ret + LFN_CaptionML + ','
				from dbo.LIB_Functions with (nolock)
				where LFN_paramTarget like '%' + left( @querystring ,200) + '%'

	--		if @Ret = '' 
	--		begin

				select @Ret = @Ret + cast( mlngDesc_I as varchar(4000)) + ','
					from MPCommands with (nolock)
						inner join multilinguismo with (nolock) on mpcName = IdMultiLng
					where mpcLink like '%' + left( @querystring ,200) + '%'


	--		end

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Richiamo area filtro per documenti - ' + @Ret where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/ViewerGriglia.asp'
	begin

		if dbo.GetValue( 'Table' ,@querystring)  = 'Document_MicroLotti_Dettagli'
		begin

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzo righe lotti del documento' where id = @id

		end
		else
		begin
		
			set @Ret = ''
			select @Ret = @Ret + LFN_CaptionML + ','
				from dbo.LIB_Functions with (nolock)
				where LFN_paramTarget like '%' + left( @querystring ,200) + '%'

	--		if @Ret = '' 
	--		begin

				select @Ret = @Ret + cast( mlngDesc_I as varchar(4000)) + ','
					from MPCommands with (nolock)
						inner join multilinguismo with (nolock) on mpcName = IdMultiLng
					where mpcLink like '%' + left( @querystring ,200) + '%'

	--		end

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Richiamo lista documenti - ' + @Ret where id = @id
		end

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CheckAttivita.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Controllo Lista Attività all''Avvio '  where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Dashboard/MainView.asp'
	begin

		set @Ret = replace(dbo.GetValue( 'FilterHide' ,@querystring) , '%20' , ' ' )
		if charindex(  'Fascicolo' ,@Ret ,1 ) > 0 
		begin

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Lista documenti collegati :' + REPLACE(  @Ret , '%27' , '''' )   where id = @id
	
		end
		else
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Pagina Principale - Gruppo : ' + dbo.GetValue( 'GROUP' ,@querystring) + ' - Cartella : ' + dbo.GetValue( 'FOLDER' ,@querystring)   where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/SaveDocBackoffice.asp'
	begin

		set  @Ret = dbo.GetValue( 'TABNAME' ,@querystring) + dbo.GetValue( 'PDF_NAME' ,@querystring) 
		if @Ret <> '' 
		begin

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Genera PDF - Sezione : ' +  dbo.GetValue( 'TABNAME' ,@querystring) + ' - Nome file : ' + dbo.GetValue( 'PDF_NAME' ,@querystring)  where id = @id

		end

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/MessageBoxWin.asp'
	begin

		set @Ret = dbo.GetValue( 'MSG' ,@querystring)
		--set @Ret = REPLACE(  @Ret , '%20' , ' ' )
		set @Ret=dbo.UrlDecode_OK (@ret)

		set @TempApp = dbo.GetValue( 'ML' ,@querystring)
		
		--se chiesto ml lo applico
		if @TempApp = 'YES'
		 set @Ret = dbo.CNV(@Ret,'I')
					

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Messaggio utente - ' + @Ret where id = @id
	
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/AFLCommon/FolderGeneric/UpdateArrayProducts.asp'
	begin

        declare  @tempdesc as varchar(MAX)       
		set @Ret = dbo.GetValue( 'flaginserisci' ,@querystring)
		
                  
                    if  @Ret='1'  
                        --'sto inserendo un articolo personalizzato
                        set @tempdesc='sto inserendo un articolo personalizzato + vista=' +  dbo.GetValue( 'TABLE_FROMADD' ,@querystring) + ' IDROW_FROMADD=' +  dbo.GetValue( 'IDROW_FROMADD' ,@querystring) + ' sulla sezione ' + dbo.GetValue( 'strAreaName' ,@querystring)
                        
                    if @Ret='2' 
                        --'inserimento articoli dal catalogo
                        set @tempdesc='inserimento articoli dal catalogo articolo=' +  dbo.GetValue( 'IdArtFromCatalog' ,@querystring) + ' sulla sezione ' + dbo.GetValue( 'strAreaName' ,@querystring)
                        
                    if @Ret='3' 
                        --'Copia Articolo/i
                        set @tempdesc='Copia Articolo riga=' +  dbo.GetValue( 'IdCopia' ,@querystring) + ' sulla sezione ' + dbo.GetValue( 'strAreaName' ,@querystring)
                        
                    if @Ret='4' 
                        --'elimina Articolo/i
                        set @tempdesc='elimina Articolo righe:' +  dbo.GetValue( 'IdElimina' ,@querystring) + ' sulla sezione ' + dbo.GetValue( 'strAreaName' ,@querystring)
                         
                    if @Ret='5'     
                        --'sto inserendo un articolo personalizzato
                        set @tempdesc='sto inserendo un articolo personalizzato sulla sezione ' + dbo.GetValue( 'strAreaName' ,@querystring)
                
                update CTL_LOG_UTENTE_LAVORO set descrizione = @tempdesc where id = @id        

	end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @querystring = 'TRACE-INFO' --and @paginaDiArrivo <> '/AF_WebFileManager/proxy/1.0/uploadattach'
    begin        
        update CTL_LOG_UTENTE_LAVORO 
		  set descrizione = 'la pagina' + @paginaDiArrivo + ' ha completato l''elaborazione'
		  where id = @id                    
    end 
    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @querystring = 'TRACE-ERROR'
    begin

		if @paginaDiArrivo <> '/application/ctl_library/messageboxwin.asp'
		begin

			update CTL_LOG_UTENTE_LAVORO 
				set descrizione = 'la pagina' + @paginaDiArrivo + ' è andata in errore per ulteriori dettagli consultare il campo form.'
				where id = @id                    

		end
		else
		begin

			update CTL_LOG_UTENTE_LAVORO 
				set descrizione = 'Salvataggio del messaggio di errore nel log'
				where id = @id   

		end

    end 
            
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @querystring = 'TRACE-ESITO'
    begin
        set  @Ret = dbo.GetValue( 'lIdMsgPar' ,@querystring)     
        update CTL_LOG_UTENTE_LAVORO 
		  set descrizione = 'riepilogo dettaglio dopo invio del documento ' + @Ret
		  where id = @id                    
    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/document/Document.asp' or @paginaDiArrivo = '/Application/ctl_library/document/userdocument.asp'
	begin

		declare @Command varchar(255)
		declare @Processo varchar(500)
		declare @DocNameTec varchar(255)
		declare @riga as varchar(15)
		
		--declare @Sezione as varchar(255)

		set @Ret = dbo.GetValue( 'MODE' ,@querystring)
		set @Command = dbo.GetValue( 'COMMAND' ,@querystring)
		
		--se nel command è contenuto il "." la prima parola è la sezione
		set @Sezione=''
		if @Command like '%.%'
			set @Sezione = dbo.GetPos(@Command,'.',1)
		
		
		set @DocNameTec = dbo.URL_Decode( dbo.GetValue( 'DOCUMENT' ,@querystring) )

		set @riga = dbo.GetValue( 'IDROW' ,@querystring)

		
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
				where DOC_ID = @DocNameTec
		
		if @Sezione <> ''
		begin
			
			select @Sezione = cast( isnull(ML_Description,DSE_DescML) as varchar(255))  from LIB_Documentsections d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DSE_DescML and ML_LNG = 'I' and ML_Context = 0
				where dse_DOC_ID = @DocNameTec and DSE_ID = @Sezione
			
		end

		if @Ret = 'REMOVE_FROM_MEM' 
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Rimozione dalla memoria del documento ' + @DocName where id = @id

		--if @Ret = 'OPEN' 
		--	update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura documento ' + @DocName where id = @id

		if @Ret = 'CREATEFROM'
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Creazione documento ' + @DocName where id = @id


		if @Ret = 'NEW'
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Creazione nuovo documento ' + @DocName where id = @id


		IF @Ret IN ( 'SHOW', 'OPEN' )
		BEGIN

				declare @docTable varchar(500)
				declare @protocollo varchar(MAX)
				declare @fascicolo varchar(MAX)
				declare @rifProt varchar(MAX)

				set @docTable = ''
				set @rifProt = ''

				select @docTable = DOC_Table
					 from LIB_Documents with(nolock) 
					 where doc_id = @DocNameTec

				IF @docTable IN ( 'CTL_DOC', 'CTL_DOC_VIEW_CAPTION', 'CTL_DOC_SIGN_VIEW','CTL_DOC_VIEW','CTL_DOC_VIEW_COMMISSIONE', 'CTL_DOC_VIEW_OE', 'Document_Bando_Semplificato_view','SCRITTURA_PRIVATA_DOCUMENT_VIEW' )
				BEGIN

					IF ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring )) = 1
					BEGIN
						
						set @idMsg  = dbo.GetValue( 'IDDOC' ,@querystring )
						set @protocollo = ''
						set @fascicolo  = ''

						select @protocollo = protocollo, @fascicolo = fascicolo from ctl_doc with(nolock) where id = @idMsg

						IF isnull(@protocollo,'') <> ''
							set @rifProt = ' - Protocollo : ' + @protocollo	
					
						IF isnull(@fascicolo,'') <> ''
						BEGIN
							set @rifProt = @rifProt + ' - Fascicolo : ' + @fascicolo

							--Inserisco il fascicolo nella colonna Fascicolo della CTL_LOG_UTENTE_LAVORO
							update CTL_LOG_UTENTE_LAVORO set Fascicolo = @fascicolo where id = @id
						END
						
						IF isnull(@protocollo,'') <> ''
						BEGIN
							--Inserisco il protocollo nella colonna protocollo della CTL_LOG_UTENTE_LAVORO
							update CTL_LOG_UTENTE_LAVORO set Protocollo = @protocollo where id = @id
						END

					END

				END


				IF @Command = 'PROCESS'
				BEGIN

					set @Processo = dbo.GetValue( 'PROCESS_PARAM' ,@querystring)
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Esecuzione processo ' + @Processo + ' per il documento ' + @DocName + @rifProt where id = @id

				END
				ELSE IF @Command = 'RELOAD'
				BEGIN

					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Ricarica documento ' + @DocName + @rifProt where id = @id

				END
				

				ELSE IF @Command like '%.ADDFROM%'
				BEGIN

					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Aggiunta riga sulla Sezione ' + @Sezione  + ' del documento ' + @DocName + @rifProt where id = @id

				END
				ELSE IF @Command like '%.ADDNEW%'
				BEGIN

					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Aggiunta riga ' + @riga + ' sulla Sezione ' + @Sezione  + ' del documento ' + @DocName + @rifProt where id = @id

				END
				ELSE IF @Command like '%.DELETE_ROW%'
				BEGIN
					
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Cancellazione riga ' + @riga + ' sulla Sezione ' +@Sezione  + ' del documento ' + @DocName + @rifProt where id = @id

				END
				
				ELSE IF @Command = 'SAVE'
				BEGIN
					
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Salvataggio dati nel DB e successiva riapertura del documento ' + @DocName + @rifProt
						where id = @id

				END	
								
				ELSE
				BEGIN

					update CTL_LOG_UTENTE_LAVORO 
						set descrizione = 'Apertura documento ' + @DocName + @rifProt
					where id = @id

				END
				
		END

		if dbo.URL_Decode( dbo.GetValue( 'DOCUMENT' ,@querystring) ) = 'VERIFICA_FIRMA_INFO' 
		begin
			if isnumeric(dbo.GetValue( 'IDDOC' ,@querystring)) = 1
			begin
				select @DocName = nomeFile from  CTL_SIGN_ATTACH_INFO with (nolock)  where id = dbo.GetValue( 'IDDOC' ,@querystring) 
				update CTL_LOG_UTENTE_LAVORO set descrizione = descrizione + ' per l''allegato :' + @DocName  where id = @id
			end
		end

	END
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/pdf/pdf.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Generazione file PDF' where id = @id

	end

	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/CauzioneOffertaMicroLotti.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Stampa documento di cauzione per i lotti' where id = @id
				
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/OffertaMicrolotti.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Stampa offerta economica per i lotti' where id = @id
				
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/HomeLightAFS.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione' where id = @id
				
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/LogoAfs.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzazione del logo' where id = @id
				
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/InfoMain.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzazione gruppi di cartelle' where id = @id
				
	end
        
    if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/CompanyDes/FormExecuteSearch.asp'
	begin
	    set  @lItypePar = dbo.GetValue( 'iTypeMes' ,@querystring) 
		set  @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@querystring) 

		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@querystring)) = 1
			set @idMsg  = dbo.GetValue( 'IdMsg' ,@querystring) 

		select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
					from Document with (nolock)
						inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
					where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Form Ricerca Destinatari Documento ' + @DocName where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneArchivi/EsitoRicercaAziExcel.asp'
	begin

	      set @DocName =  dbo.GetValue( 'strTipoRicerca' ,@paginaDiPartenza) 
		  update CTL_LOG_UTENTE_LAVORO set descrizione = 'Esporta Excel archivio tipo ricerca = ' + @DocName where id = @id
				
	end
	
	if @paginaDiArrivo = '/application/AFLAdmin/aree.asp'
	begin

	    set @DocName =  dbo.GetValue( 'StrDescGerarchia' ,@querystring) 
	                
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Gerarchia ' + @DocName where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLAdmin/dati_opzionali.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@paginaDiPartenza)) = 1
		begin
			set @IdAzienda =  dbo.GetValue( 'idAzi' ,@paginaDiPartenza) 

			select 	@DocName = 	aziragionesociale
					from aziende with (nolock)
					where IdAzi=@IdAzienda
					       
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Scheda Anagrafica visualizzazione attributi opzionali azienda ' + @DocName where id = @id
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/application/Report/StampaVerbaleGara.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring)) = 1
		begin

			set @idMsg =  dbo.GetValue( 'IDDOC' ,@querystring) 
			select 	@DocName = 	ProtocolloRiferimento
				from ctl_doc with (nolock)
				where tipodoc='verbalegara' and id=@idMsg  
					    
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Stampa Verbale Protocollo Bando ' + @DocName where id = @id
		
		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/RisultatoDiGaraEnte.asp'
	begin

	    set @DocName =  dbo.GetValue( 'PROTOCOLLOBANDO' ,@querystring) 
	        			    
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizza Risultati di gara Protocollo Bando ' + @DocName where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/ConfirmComputeScore.asp'
	begin

	    set  @lItypePar = dbo.GetValue( 'iTypeMes' ,@querystring) 
		set  @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@querystring) 

		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@querystring)) = 1
			set  @idMsg  = dbo.GetValue( 'IdMsg' ,@querystring) 

		select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
					from Document  with (nolock)
						inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Calcola Punteggio Economico documento ' + @DocName where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/Discard_Enable_Message.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'iSubTypeMes' ,@querystring)) = 1)
		begin

			set  @lItypePar = dbo.GetValue( 'iTypeMes' ,@querystring) 
			set  @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@querystring) 
			set  @ret  = dbo.GetValue( 'nIndRowMsg' ,@querystring) 
			set  @Azione = dbo.GetValue( 'strTypeOperation' ,@querystring)
		 
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
							 where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 

			if @Azione='DISCARDMESSAGE'			
					set @Azione='Apertura Form Motivazioni di Scarto Offerta relativa'
			else
					set @Azione='Apertura Form Motivazioni Riammissione Offerta relativa'
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione + ' alla riga ' + @ret + ' del documento ' + @DocName where id = @id
		
		end		
	end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/FolderGeneric.asp'
	begin

	    set  @DocName = dbo.GetValue( 'Descrizione' ,@querystring) 
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Lista documenti ' + @DocName where id = @id
				
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/Confirm_Discard_Enable_Message.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'iSubTypeMes' ,@querystring)) = 1)
		begin

			set  @lItypePar = dbo.GetValue( 'iTypeMes' ,@querystring) 
			set  @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@querystring) 
			set  @ret  = dbo.GetValue( 'nIndRowMsg' ,@querystring) 
			set  @Azione = dbo.GetValue( 'strTypeOperation' ,@querystring)
		 
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
							 where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
			if @Azione='DISCARDMESSAGE'			
					set @Azione='Conferma Scarto Offerta relativa'
			else
					set @Azione='Conferma Riammissione Offerta relativa'
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione + ' alla riga ' + @ret + ' del documento ' + @DocName where id = @id
		
		end		
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Event/Open.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'lISubType' ,@querystring)) = 1)
	    begin
			set  @lItypePar = dbo.GetValue( 'lItype' ,@querystring) 
			set  @lISubTypePar = dbo.GetValue( 'lISubType' ,@querystring) 
			set  @idMsg  = dbo.GetValue( 'lIdMsg' ,@querystring) 
			set  @Azione = dbo.GetValue( 'StrNameControl' ,@querystring)
		
			select @TempApp=ProtocolloOfferta from tab_messaggi_fields with (nolock) where idmsg=@idMsg
		 
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
							 where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
		
			set @Azione = 'Evento Open sulla sezione ' + @Azione + ' del documento ' + @DocName  + ' con Protocollo:' + @TempApp
		
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Home/RefreshNumMsg.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Aggiornamento contatori messaggi non letti sui folder' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/NewHomeAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/CodaGruppi.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Funzioni Principali ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/LogoGruppiAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Logo ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Home/NewGruppiAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Gruppi Funzionali ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Home/NewFolderAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Area Centrale ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/NewLogoAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Area in basso logo ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Home/NewToolbarAfs.asp'
	begin
	       	
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Home Page dell''applicazione lato Ente - Area in alto Esci ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLCommon/FolderGeneric/FormInserisciArticolo.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'lISubType' ,@querystring)) = 1)
		begin
			set  @lItypePar = dbo.GetValue( 'IType' ,@querystring) 
			set  @lISubTypePar = dbo.GetValue( 'ISubType' ,@querystring) 
			set  @idMsg  = dbo.GetValue( 'lIdMsg' ,@querystring) 
			set  @Azione = dbo.GetValue( 'strKeyCaptionForm' ,@querystring)
			set  @Sezione = dbo.GetValue( 'strAreaName' ,@querystring)
		 
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
					   		where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
		
			set @Azione =  'Apertura form per ' + REPLACE(  @Azione , '%20' , ' ' ) + ' sulla sezione ' + @Sezione + ' del documento ' +  @DocName
		
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/InserisciArticolo.asp'
	begin
			
		if (ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'lISubType' ,@querystring)) = 1)
	    begin
			set  @lItypePar = dbo.GetValue( 'IType' ,@querystring) 
			set  @lISubTypePar = dbo.GetValue( 'ISubType' ,@querystring) 
			set  @idMsg  = dbo.GetValue( 'lIdMsg' ,@querystring) 
			set  @Azione = dbo.GetValue( 'strKeyCaptionForm' ,@querystring)
			set  @Sezione = dbo.GetValue( 'strAreaName' ,@querystring)
		 
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
							where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
		
			set @Azione = 'Apertura form per ' + REPLACE(  @Azione , '%20' , ' ' ) + ' sulla sezione ' + @Sezione + ' del documento ' +  @DocName
		
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end		
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/FolderTableGeneric.asp'
	begin

		set @Azione = dbo.GetValue( 'strGruppo' ,@querystring)
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura gruppo funzionale ' + @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Home/documenticollegati.asp'
	begin

		set @Ret = replace(dbo.GetValue( 'FilterHide' ,@querystring) , '%20' , ' ' )
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Lista documenti collegati :' +  REPLACE(  @Ret , '%27' , '''' )  where id = @id
	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/FolderGenericBar.asp'
	begin

		set @Azione = dbo.GetValue( 'strGruppo' ,@querystring)
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Toolbar Gruppo funzionale ' + @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/command/document/Search_Open_Create.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'SUBTYPEDOC' ,@querystring)) = 1
		begin

			set @lISubTypePar = dbo.GetValue( 'SUBTYPEDOC' ,@querystring)
			set @lItypePar = 55
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
					   		where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
		  
		
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura/Creazione documento ' + @DocName where id = @id
		
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLAdmin/document.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring)) = 1
		begin
			set @Azione = dbo.GetValue( 'DOCUMENT' ,@querystring) 
			set @IdAzienda = dbo.GetValue( 'IDDOC' ,@querystring) 
				select 	@DocName = 	aziragionesociale
						from aziende with (nolock)
						where IdAzi=@IdAzienda 
		
			if @Azione='AZI_STORICO'
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzazione Storico Azienda ' + isnull(@DocName,'') where id = @id
			else
					update CTL_LOG_UTENTE_LAVORO set descrizione = 'Visualizzazione Comunicazioni Azienda ' + isnull(@DocName,'') where id = @id		
		end     
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/CompanyDes/FormSearchResult.asp'
	begin
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Form Ricerca Destinatari ' where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLAdmin/OpenDatiAzi.asp' or @paginaDiArrivo = '/application/AFLAdmin/intestazione_DatiAzienda.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@querystring)) = 1
		begin
			set @IdAzienda =  dbo.GetValue( 'idAzi' ,@querystring) 
				select 	@DocName = 	aziragionesociale
						from aziende with (nolock)
						where IdAzi=@IdAzienda 
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Anagrafica azienda ' + @DocName where id = @id
		end		
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLAdmin/dati_azienda.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@querystring)) = 1
		begin
			set @IdAzienda =  dbo.GetValue( 'idAzi' ,@querystring) 
				select 	@DocName = 	aziragionesociale
						from aziende with (nolock)
						where IdAzi=@IdAzienda 
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Apertura Dati Fissi Anagrafica azienda ' + @DocName where id = @id
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/GestioneArchivi/EsitoRicercaAzi.asp'
	begin

		set @Azione =  dbo.GetValue( 'strTipoRicerca' ,@querystring) 
		
		if @Azione = 'GestioneAziende'
		        set @Azione = 'Esito ricerca aziende dal dossier'
		
	        if @Azione = 'Prodotti' or @Azione = 'Listino'
		        set @Azione = 'Esito ricerca articoli dal dossier'
		
		 if @Azione = 'Documenti' or @Azione = 'DocumentiSeller'
		        set @Azione = 'Esito ricerca articoli dal dossier'
		
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneArchivi/FormRicAzi.asp'
	begin

		set @Azione = 'Apertura form per ricerca nel dossier'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/chiarimenti.asp'
	begin

		set @Azione = 'Apertura Lista Chiarimenti'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/first_login.asp'
	begin

		set @Azione = 'Controllo primo login'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_Library/functions/RetrievePath.asp'
	begin

		set @Azione = 'Costruzione Path "Ti trovi in" quando viene fatto "Partecipa" dal portale '
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Document/LinkedMessage.asp'
	begin

		set @Azione = 'Lista messaggi collegati '
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Functions/Calendario.asp'
	begin

		set @Azione = ' Visualizzazione controllo calendario per le date'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/RisultatoDiGara.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'lISubTypePar' ,@paginaDiPartenza )) = 1
		begin

			set @lISubTypePar = dbo.GetValue( 'lISubTypePar' ,@paginaDiPartenza )
			set @lItypePar = 55
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
			set @Azione = ' Visualizzazione risultati di gara documento ' + @DocName
				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		
		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/CompanyDes/UpdateSearch.asp'
	begin

		if(ISNUMERIC(dbo.GetValue( 'TypeOperation' ,@querystring  )) = 1 and ISNUMERIC(dbo.GetValue( 'ISubType' ,@querystring )) = 1)
	    begin

			set @ret = dbo.GetValue( 'TypeOperation' ,@querystring  )
			set @lISubTypePar = dbo.GetValue( 'ISubType' ,@querystring )
			set @lItypePar = dbo.GetValue( 'IType' ,@querystring )
		
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with (nolock)
							inner join multilinguismo with (nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
			if @ret='I'			
					set @Azione = ' Inserimento Azienda sezione destinatari documento ' +  @DocName
		        
			if @ret='D'			
					set @Azione = ' Cancellazione Azienda sezione destinatari documento ' +  @DocName
		
			if @ret='U'			
					set @Azione = ' Aggiornamento Azienda sezione destinatari documento ' +  @DocName
		
			if @ret='R'			
					set @Azione = ' Sostituzione Azienda sezione destinatari documento ' +  @DocName
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/cambio_password.asp'
	begin

		set @Azione = 'Cambio Password'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/FormRicercaAvanzata.asp' or @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/FrameFormRicercaAvanzata.asp'
	begin

		set @Azione = 'Apertura form per ricerca su una cartella'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/report/light_RisultatoDiGara_int.asp' or @paginaDiArrivo = '/Application/report/RisultatoDiGara.asp'
	begin

		set @Ret  = dbo.GetValue( 'PROTOCOLLOBANDO' ,@querystring  )
					
		set @Azione = ' Visualizzazione risultati di gara protocollo bando ' + @Ret
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/MotoreRicercaAvanzata.asp'
	begin

		set @Ret  = dbo.GetValue( 'TypeCatalogo' ,@paginaDiPartenza   )
		
		if @Ret='M'			
		        set @Azione = ' Esito ricerca articoli nel catalogo marketplace'
		        
		if @Ret='C'			
		        set @Azione = ' Esito ricerca articoli nel catalogo azienda loggata'
		
		if @Ret='S'			
		        set @Azione = ' Esito ricerca articoli nel catalogo fornitore'
		
		        
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/application/aflcommon/foldergeneric/Command/document/search_createLight.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'SUBTYPESEARCH' ,@querystring  )) = 1
		begin

			set @lISubTypePar   = dbo.GetValue( 'SUBTYPESEARCH' ,@querystring  )
			set @lItypePar =55
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
				
			set @Azione = ' Apertura/Creazione documento ' + @DocName 
		
		        
				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_Library/document/OpenDocFromDossier.asp'
	begin

		set @Azione = 'Apertura documento dal dossier'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLAdmin/SaveDati.asp'
	begin

		set @Azione = 'Salvataggio dati azienda'
	        update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Common/Formula.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'lISubType' ,@querystring  )) = 1
		begin

			set @lISubTypePar = dbo.GetValue( 'lISubType' ,@querystring  )
			set @lItypePar = 55
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
				
			set @Azione = ' Gestione Formule documento ' + @DocName 
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLPublicFolder/PublicFolder/PublicFolder.asp' or @paginaDiArrivo ='/application/AFLPublicFolder/PublicFolder/PublicFolderBar.asp' or @paginaDiArrivo ='/application/AFLPublicFolder/PublicFolder/PublicFolderTable.asp'
	begin

		set @ret   = dbo.GetValue( 'Descrizione' ,@querystring  )
				
		set @Azione = ' Apertura folder pubblici ' + @ret 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/AlertComputeScore.asp'
	begin

		set @Azione = ' Visualizzazione calcolo punteggio economico PDA ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Functions/MoveMessage.asp'
	begin

		set @ret   = dbo.GetValue( 'tipooperazione' ,@querystring  )
		
		if @Ret='1' 		
		        set @Azione = ' Sposta i documenti nel cestino '
		
		if @Ret='2' 		
		        set @Azione = ' Ripristina i documenti dal cestino '
		
		if @Ret='3' 		
		        set @Azione = ' Cancella i documenti '
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/report/chiarimenti_I.asp'
	begin

		set @Azione = ' Visualizzazione lista chiarimenti ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/OpenHistoryMotivation.asp'
	begin
	        
		set @Azione = ' Visualizzazione storia delle motivazioni dalla pda ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Products/UDAattrib.asp'
	begin
	        
		set @Azione = ' Apertura Form per la gestione attributi personalizzati ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Event/CanOpen.asp'
	begin

		if(ISNUMERIC(dbo.GetValue( 'lItype' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'lISubType' ,@querystring)) = 1)
		set  @lItypePar = dbo.GetValue( 'lItype' ,@querystring) 
		set  @lISubTypePar = dbo.GetValue( 'lISubType' ,@querystring) 
		set  @idMsg  = dbo.GetValue( 'lIdMsg' ,@querystring) 
		set  @Azione = dbo.GetValue( 'StrNameControl' ,@querystring)
		 
		select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
					from Document with(nolock)
						inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
					where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
		
		set @Azione = 'Evento Can Open sulla sezione ' + @Azione + ' del documento ' + @DocName 
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Products/ManageAttributesAllArea.asp'
	begin
	        
		set @Azione = ' Gestione attributi della griglie e area comune ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Functions/CopiaDocumento.asp'
	begin
		
		set  @ret = dbo.GetValue( 'Descrizione' ,@querystring)
	        
		set @Azione = ' Copia documento ' + @ret
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLCommon/FolderGeneric/StampaLista.asp'
	begin

		set @Azione = ' Stampa lista documenti '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/EditScore.asp'
	begin

		set @Azione = ' Visualizzazione form per il punteggio tecnico PDA ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLSupplier/FolderRDOArrivo/Attach.asp'
	begin

		--Nf=Disciplinare.pdf&Fd=46&Id=53416&NameField=BANDO_griglia_1_4

		if ISNUMERIC(dbo.GetValue( 'Id' ,@querystring) ) = 1
		begin

			set @idMsg  = dbo.GetValue( 'Id' ,@querystring) 
			set @Ret = dbo.GetValue( 'Fd' ,@querystring) 
			set @TempApp = dbo.GetValue( 'Nf' ,@querystring) 
			set @Azione = dbo.GetValue( 'NameField' ,@querystring) 

		
			set @TempApp = @TempApp + ' dalla Busta\Area\Riga:' + replace(@Azione,'_','\') 

			select @lItypePar = itype, @lISubTypePar=isubtype, @Azione = ProtocolloOfferta from tab_messaggi_fields with (nolock) where idmsg=@idMsg


			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType
		
		
			select  @Azione = ' Download Allegato ' +  @TempApp + ' del documento ' + @DocName + ' con Protocollo:' +  @Azione  + ' (Pos. File:' + @Ret + ') '


			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end		
	end

	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------	
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/ExecCommandAttributes.asp'
	begin

		set @Azione = ' Gestione attributi aree griglia e area comune ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneImmagine/SelezionaLogo.asp' or @paginaDiArrivo = '/application/GestioneImmagine/FrameImmagineLogo.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IDDZT' ,@querystring)) = 1
		begin
			set @IdAzienda =  dbo.GetValue( 'IDDZT' ,@querystring) 
			select 	@DocName = 	aziragionesociale
					from aziende with(nolock)
					where IdAzi=@IdAzienda 

			set @Azione = ' Apertura form per selezionare il logo per l''azienda ' +  @DocName
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------	
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/AlertComputeAbnormal.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@paginaDiPartenza)) = 1
		begin

			set @idMsg  = dbo.GetValue( 'IdMsg' ,@paginaDiPartenza)
		
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS  with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Apertura form calcolo offerte anomale PDA protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/quesiti/grigliaquesiti.asp'
	begin
		
		--if exists( select * from lib_dictionary where dzt_name = 'SYS_ACCESSIBLE' and DZT_ValueDef <> 'YES' )
		
		if ISNUMERIC(dbo.GetValue( 'GUID_DOC' ,@querystring)) = 1
		begin
			set @DocName=dbo.GetValue( 'DOCUMENT' ,@querystring) 
			set @ret  =  dbo.GetValue( 'GUID_DOC' ,@querystring) 

			if @DocName=''
			begin
				--documento generico
				if ISNUMERIC(dbo.GetValue( 'SUBTYPE_ORIGIN' ,@querystring)) = 1
				begin
					set @lItypePar =55
					set @lISubTypePar  =  dbo.GetValue( 'SUBTYPE_ORIGIN' ,@querystring) 
                
					select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
							from Document with(nolock)
								inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
							where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
                
					set @Azione = ' Visualizzazione quesiti del documento ' + isnull( @DocName  , '' ) 
				end
			end
			else
			begin

				--nuovi documenti
				select @DocPartenza = cast( isnull(ML_Description,DOC_DescML) as varchar(255)) , @titolo = titolo 
					from ctl_doc b with (nolock)
						inner join LIB_Documents d with (nolock) on b.tipodoc = d.DOC_ID
						left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
				where b.id = @ret
		

      			set @Azione =  ' Visualizzazione quesiti del documento  ''' + @DocPartenza + ''' titolo: ' + @Titolo  

			end
		
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneImmagine/UploadScript1.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IDDZT' ,@querystring)) = 1
		begin

			set @IdAzienda =  dbo.GetValue( 'IDDZT' ,@querystring) 
			select 	@DocName = 	aziragionesociale
					from aziende with(nolock)
					where IdAzi=@IdAzienda 

			set @Azione = ' Caricamento logo per l''azienda ' +  @DocName
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneImmagine/UploadScript1.asp'
	begin
	
		set @Azione = ' Visualizzazione criteri di ricerca nel dossier  '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Cover/FormExecuteSearch_Company.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iSubTypeMes' ,@querystring )) = 1 and ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring )) = 1)
		begin

			set @ret = dbo.GetValue( 'strTypeAzi' ,@querystring )
			set @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@querystring )
			set @lItypePar = dbo.GetValue( 'iTypeMes' ,@querystring )
		
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
			if @ret='DEST'			
					set @Azione = ' Apertura form per ricerca Azienda destinataria sulla copertina del documento ' +  @DocName
			if @ret='MITT'			
					set @Azione = ' Apertura form per ricerca Azienda mittente sulla copertina del documento ' +  @DocName
		        
				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Cover/FormSearch_CompanyResult.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'iSubTypeMes' ,@querystring )) = 1 and ISNUMERIC(dbo.GetValue( 'iTypeMes' ,@querystring )) = 1)
		begin
		
			set @ret = dbo.GetValue( 'strTypeAzi' ,@paginaDiPartenza  )
			set @lISubTypePar = dbo.GetValue( 'iSubTypeMes' ,@paginaDiPartenza  )
			set @lItypePar = dbo.GetValue( 'iTypeMes' ,@paginaDiPartenza  )
		
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
			if @ret='DEST'			
					set @Azione = ' Esito ricerca Azienda destinataria sulla copertina del documento ' +  @DocName
			if @ret='MITT'			
					set @Azione = ' Esito ricerca Azienda mittente sulla copertina del documento ' +  @DocName
		        
				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		
		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Cover/UpdateSearch_Company.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'ISubType' ,@querystring )) = 1 and ISNUMERIC(dbo.GetValue( 'IType' ,@querystring )) = 1)
		begin

			set @ret = dbo.GetValue( 'strTypeAzi' ,@querystring   )
			set @lISubTypePar = dbo.GetValue( 'ISubType' ,@querystring   )
			set @lItypePar = dbo.GetValue( 'IType' ,@querystring   )
		
		
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
	       
			if @ret='DEST'			
					set @Azione = ' Inserimento Azienda destinataria sulla copertina del documento ' +  @DocName
			if @ret='MITT'			
					set @Azione = ' Inserimento Azienda mittente sulla copertina del documento ' +  @DocName
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/ComEsclusione.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set @idMsg  = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)
		
			select 	@DocName = 	 ProtocolloBando  
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Apertura comunicazione di esclusione protocollo bando ' +  @DocName
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Aflcommon/FolderGeneric/command/CompanyDes/insertazifromquery.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set @idMsg  = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza    )

			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	        
			set @Azione = ' Inserimento azienda nei destinatari dalle manifestazioni di interesse protocollo bando ' +  @DocName
		        
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/ConfirmComputeAbnormal.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@paginaDiPartenza)) = 1
		begin

			set @idMsg  = dbo.GetValue( 'IdMsg' ,@paginaDiPartenza)
		
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Conferma calcolo offerte anomale PDA protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Report/agg_prov_55_169.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin
			set @idMsg  = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza    )
		
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Report aggiudicazione provvisoria PDA protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/PreCreaVerbaleGara.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set @idMsg  = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)
		
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Apertura lista template per creazione verbale PDA  protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/CreaVerbaleGara.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@querystring )) = 1
		begin

			set @idMsg  = dbo.GetValue( 'lIdMsgPar' ,@querystring )
		
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Creazione verbale PDA  protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------	
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Evaluate/InVerifica_Message.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@querystring )) = 1
		begin

			set @idMsg  = dbo.GetValue( 'IdMsg' ,@querystring )
			set @Ret = dbo.GetValue( 'nIndRowMsg' ,@querystring )
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Apertura form in verifica per offerta della riga ' + @Ret + ' PDA  protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end	
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Aflcommon/FolderGeneric/Command/Evaluate/Sorteggio.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IdMsg' ,@querystring )) = 1
		begin

			set @idMsg  = dbo.GetValue( 'IdMsg' ,@querystring )
			select 	@DocName = 	 protocollobando 
						from TAB_MESSAGGI_FIELDS with(nolock)
						where IdMsg=@idMsg
	       
			set @Azione = ' Apertura form sorteggio PDA  protocollo bando ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_LIBRARY/DOCUMENT/xml.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring )) = 1
		begin

			set @idMsg  = dbo.GetValue( 'IDDOC' ,@querystring )
			set @ret  = dbo.GetValue( 'DOCUMENT' ,@querystring )
	        
			select top 1 @DocName = cast(ML_Description as varchar(MAX)) 	  	 
						from LIB_Documents with(nolock), LIB_Multilinguismo with(nolock) 
						where doc_id=@ret and doc_descml = ML_KEY and ML_LNG='I'
	       
			set @Azione = ' Conversione XML del documento ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/ViewerCommand.asp'
	begin
	
	        
		set @ret  = dbo.GetValue( 'PROCESS_PARAM' ,@querystring )
	        
		set @Azione = ' Esecuzione Processo ' +  @ret
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_Library/LoadExtendedAttrib.asp'
	begin
	
		set @ret  = dbo.GetValue( 'titoloFinestra' ,@querystring )
	        
		set @Azione = ' Apertura form per attributo ' + replace( @ret , '%20' , ' ' ) 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/dashboard/ViewerPrint.asp'
	begin
	
		set @Azione = ' Stampa lista '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CTL_Library/functions/field/DisplayAttach.ASP'
	begin
	
		set @ret = dbo.GetValue( 'TECHVALUE' ,@querystring )
		--set @ret = replace( @ret , '%2A' , '*' )
		set @ret = dbo.URL_Decode( @ret )
		set @Azione = ' Visualizza allegato :' + dbo.getPos( @ret , '*' , 1 )  + ' - KEY : [' + dbo.getPos( @ret , '*' , 4 ) +']'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/ViewerExecProcess.asp'
	begin
	
	    set @ret  = dbo.GetValue( 'CAPTION' ,@querystring )
	    set @command  = dbo.GetValue( 'PROCESS_PARAM' ,@querystring )
	        
		set @Azione = ' Esecuzione Processo ' +  replace( @ret , '%20' , ' ' ) 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo like '/%/CTL_Library/functions/field/SaveAttach.asp' or @paginaDiArrivo like '/%/CTL_Library/CTL_Library/functions/field/SaveAttach.asp'
	begin
	
	    set @Azione = ' Inserimento allegato nel database ed associazione al campo [' + dbo.GetValue( 'FIELD' ,@querystring)  + ']'
		if @querystring = 'TRACE-INFO'
			set @Azione = ' Termine operazione richiesta di inserimento allegato nel database'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/CONVENZIONE.asp'
	begin
	
	    set @Azione = ' Stampa Convenzione '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/viewerExcel.asp'
	begin
	
		set @Azione = ' Esporta in excel lista '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CTL_Library/functions/field/UploadAttach.asp' or @paginaDiArrivo = '/application/CTL_Library/CTL_Library/functions/field/UploadAttach.asp'
	begin
	
	    --set @Azione = ' Upload allegato '
	    set @Azione = ' Pagina di seleziona allegato '
		if dbo.GetValue( 'FIELD' ,@querystring) <> ''
			set @Azione = @Azione + ' per il campo [' + dbo.GetValue( 'FIELD' ,@querystring)  + ']'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = 'UploadAttach.asp'
	begin

		if ( len (@querystring) > 100 )
			set @Azione = ' Generazione HASH del file Caricato andata in errore'
		else
			set @Azione = ' Generazione HASH del file Caricato [' + @querystring + ']'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/viewerinfo.asp'
	begin
	
		set @Azione = ' Area riepilogo Lista '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/DASHBOARD/ViewerRubrica.asp'
	begin
	
		set @Azione = ' Visualizzazione rubrica '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/CUBEGrid.asp' or  @paginaDiArrivo = '/Application/DASHBOARD/Cube.asp'
	begin
	
		set @Azione = ' Visualizzazione lista multidimensione '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/CubeFilter.asp'
	begin
	
		set @Azione = ' Visualizzazione area filtro lista multidimensione'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_Library/document/MakeDocFrom.asp'
	begin

	    set @ret  = dbo.GetValue( 'TYPE_TO' ,@querystring )
	    set @command  = dbo.GetValue( 'TYPEDOC' ,@querystring )
	    set @command  = dbo.GetValue( 'IDDOC' ,@querystring )
	        
	    --set @Azione = ' Creazione / Apertura documento ' + @ret + ' dal documento '  + @command
	    set @Azione = ' Creazione / Apertura documento ' + @ret + ' dal riferimento '  + @command
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Ctl_Library/document/ToPrintDocument.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'DOCUMENT' ,@querystring )) = 1
		begin

			set @ret  = dbo.GetValue( 'DOCUMENT' ,@querystring )
	        
			select top 1 @DocName = cast(ML_Description as varchar(MAX)) 	  	 
						from LIB_Documents with(nolock), LIB_Multilinguismo  with(nolock)
						where doc_id=@ret and doc_descml = ML_KEY and ML_LNG='I'
	       
			set @Azione = ' Stampa del documento ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Document/Create_SaveDoc.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'lItypePar' ,@querystring )) = 1
		begin

			set @lItypePar    = dbo.GetValue( 'lItypePar' ,@querystring )
			set @lISubTypePar = dbo.GetValue( 'lItypePar' ,@querystring )
			select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
					from Document with(nolock)
						inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
					where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
					
			set @Azione = ' Crea salva ed apre documento ' +  @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/getMessaggioScaricato.asp'
	begin
	
		set @Azione = ' Controllo se documento già scaricato '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLPost/FolderCestino/FolderCestino.asp' or @paginaDiArrivo = '/application/AFLPost/FolderCestino/FolderCestinoBar.asp' or @paginaDiArrivo = '/application/AFLPost/FolderCestino/FolderCestinoTable.asp'
	begin
	
		set @Azione = ' Visualizzazione lista del cestino '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/FIELD/viewCertificato.asp'
	begin
	
		set @Azione = ' Visualizzazione dettaglio della busta firmata '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/Esito_PDA.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@paginaDiPartenza )) = 1
		begin

			set @idMsg =  dbo.GetValue( 'IDDOC' ,@paginaDiPartenza ) 
			select 	@DocName = 	protocolloriferimento
					from ctl_doc with(nolock)
					where TipoDoc='pda_microlotti' and id=@idMsg
					
			set @Azione = ' Esito PDA Microlotti protocollo riferimento ' + @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_library/document/Excel.asp'
	begin

		if (ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring)) = 1 and ISNUMERIC(dbo.GetValue( 'DOCUMENT' ,@querystring)) = 1)
		begin

			set @idMsg =  dbo.GetValue( 'IDDOC' ,@querystring)
			set @Ret=dbo.GetValue( 'DOCUMENT' ,@querystring) 
	        
			select top 1 @DocName = cast(ML_Description as varchar(MAX)) 	  	 
					from LIB_Documents with(nolock), LIB_Multilinguismo with(nolock)
					where doc_id=@ret and doc_descml = ML_KEY and ML_LNG='I'
								
			set @Azione = ' Esporta excel documento ' + @DocName
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Functions/ServerLibrary/Common/AssegnaDocumento.asp'
	begin

	    set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Apertura form per Assegna documento ' + REPLACE(  @Ret , '%20' , ' ' )
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/infoCurrentUser.asp'
	begin

	    --set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Recupero informazioni utente loggato ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneArchivi/Inoltra.asp'
	begin

	    --set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Inoltra documento dal dossier ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneArchivi/InfoFiltri.asp'
	begin

	    --set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Visualizzazione criteri di ricerca del dossier ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/Functions/ServerLibrary/Common/InviaAssegnaDocumento.asp'
	begin

	    set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Assegna documento ' + REPLACE(  @Ret , '%20' , ' ' )
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CTL_Library/functions/field/scanner.asp'
	begin

	    --set @Ret=dbo.GetValue( 'Descrizione' ,@querystring) 
								
	    set @Azione = ' Apertura pagina per scansione ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/BManager/TabellaUtente.asp' or @paginaDiArrivo = '/Application/BManager/FormProfiloUtente.asp' or @paginaDiArrivo = '/Application/BManager/NascostoProfiliUtente.asp' or  @paginaDiArrivo = '/Application/BManager/TreeProfili.asp'
	
	begin
	        						
	    set @Azione = ' Apertura profilo utente ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/BManager/FolderProfiliBar.asp' or @paginaDiArrivo = '/Application/BManager/FolderTableProfili.asp'
	
	begin
	        						
	    set @Azione = ' Apertura lista utenti ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/BManager/SaveDati.asp'
	
	begin
	        						
	    set @Azione = ' Salvataggio profilo utente ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/GestioneImmagine/visualizzalogo.asp'
	
	begin
	        						
	    set @Azione = ' Visualizza logo azienda documento ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLAdmin/nascosto.asp'
	begin
	
		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@paginaDiPartenza )) = 1
		begin

			set @IdAzienda =  dbo.GetValue( 'idAzi' ,@paginaDiPartenza ) 
			select 	@DocName = 	aziragionesociale
					from aziende with(nolock)
					where IdAzi=@IdAzienda 

			set @Azione = ' Visualizza dati azienda ' +  @DocName
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLSupplier/Catalogo/BarraCatalogo.asp' or @paginaDiArrivo ='/Application/AFLSupplier/Catalogo/Catalogo.asp' or @paginaDiArrivo ='/Application/AFLSupplier/Catalogo/TabellaCatalogo.asp'
	begin
	        						
	    set @Azione = ' Visualizza catalogo articoli ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/ViewerAddNew.asp'
	
	begin
	        						
	    set @Azione = ' Apertura pagina per aggiungere elemento ad una lista ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AFLAdmin/StrutturaAziendale/strutture.asp' or @paginaDiArrivo ='/Application/AFLAdmin/StrutturaAziendale/strutture_nas.asp' 
	
	begin

		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@querystring )) = 1
		begin
			set @IdAzienda =  dbo.GetValue( 'idAzi' ,@querystring ) 
			select 	@DocName = 	aziragionesociale
					from aziende with(nolock)
					where IdAzi=@IdAzienda 
											
			set @Azione = ' Visualizza struttura aziendale dell''azienda ' + @DocName  
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo ='/Application/AFLAdmin/StrutturaAziendale/strutture_pulsanti.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'idAzi' ,@paginaDiPartenza )) = 1
		begin

			set @IdAzienda =  dbo.GetValue( 'idAzi' , @paginaDiPartenza ) 
			select 	@DocName = 	aziragionesociale
					from aziende with(nolock)
					where IdAzi=@IdAzienda 
											
			set @Azione = ' Visualizza struttura aziendale dell''azienda ' + @DocName  
		         
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/report/DisplayProroga.asp'
	begin
	        						
		set @Azione = ' Stampa proroga ' 
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/newodc.asp'
	begin
	
		set @Azione = ' Nuovo Ordine da contratto ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id   
		
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AVCP/test_Path.asp'
	begin
	
		set @Azione = ' AVCP - Testa se un percorso di rete (come cartella) è valido ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id   
		
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AVCP/AVCP_CSV.asp'
	begin
	
		set @Azione = ' AVCP - Importa un csv  ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id  
		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/avcp/AVCP_ProduciXML.asp'
	begin
	
		set @Azione = ' AVCP - Produce gli XML da pubblicare  ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id   
		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AVCP/AVCP_AGGIORNA_DA_PORTALE.asp'
	begin
	       
		if ISNUMERIC(dbo.GetValue( 'ENTE' , @querystring)) = 1
		begin

			set @ret =  dbo.GetValue( 'ENTE' , @querystring  ) 
			set @Azione = dbo.GetValue( 'ANNO' ,  @querystring  )  
			set @DocName=''

			select 	@DocName = 	aziragionesociale
			from aziende with(nolock)
			where IdAzi=@ret 
								
			set @Azione = ' AVCP - Verifica le condizioni della toolbar della lista avcp ente ' + @DocName + ' anno ' + @Azione 
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id 

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/PDA_ListaMicrolotti.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,  @paginaDiPartenza) ) = 1
		begin

			set @idMsg = dbo.GetValue( 'IDDOC' ,  @paginaDiPartenza) 
			select 	@DocName = 	protocolloriferimento
					from ctl_doc  with(nolock)
					where TipoDoc='pda_microlotti' and id=@idMsg
					
			set @Azione = ' PDA microlotti  protocollo riferimento ' +  @DocName
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id  
			
		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/Graph.asp'
	begin
	        			
		set @Azione = ' Apertura grafo ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id    
		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/aflcommon/foldergeneric/displayTempAttach.asp'
	begin
	        			
		set @Azione = ' Visualizzazione allegato ' 
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id  
		
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/DASHBOARD/CubeExcel.asp'
	begin
	
		set @Azione = ' Esporta excel lista multidimensione '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/Crea_Verbale_Seduta.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,  @querystring) ) = 1
		begin

			set @idMsg = dbo.GetValue( 'IDDOC' ,  @querystring) 
			select 	@DocName = 	protocolloriferimento
					from ctl_doc  with(nolock)
					where TipoDoc='pda_microlotti' and id=@idMsg
					
			set @Azione = ' PDA microlotti  creazione verbale protocollo riferimento ' +  @DocName
			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id  

		end
	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/DASHBOARD/CubePrint.asp'
	begin
	
		set @Azione = ' Stampa lista multidimensione '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/Update_Key_Multilinguismo.asp'
	begin
	
		set @Azione = ' Aggiorna il valore di un multilinguismo in memoria '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CustomDoc/AssEsecLavori.asp'
	begin
	
		set @Azione = ' PDA - Apertura documento esecutrici lavori '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/AFLCommon/FolderGeneric/Command/Folder/Content_LinkedDocument.asp'
	begin
	
		set @Azione = ' Visualizza pagina Quesito - Risposta '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/document/UploadExcel.asp'
	begin
	
		set @Azione = ' Import di un foglio excel  '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_library/functions/FIELD/SaveAttachSigned.asp'
	begin
	
		set @Azione = ' Upload e salvataggio allegato firmato '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_Library/functions/FIELD/UploadAttachSigned.asp'
	begin
	
		set @Azione = ' Apertura pagina per selezionare un allegato firmato '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/Functions/FIELD/uploadDaScanner.asp'
	begin
	
		set @Azione = ' Upload e salvataggio allegato da scanner '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/AVCP/import_from_db.asp'
	begin
	
		set @Azione = ' AVCP - importa i dati da aflink per l''ente selezionato '
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Report/BANDO_ASTA.asp'  
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = ' Pagina per la stampa del dettaglio dell''asta ' where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Report/BANDO_GARA.asp'
	begin
	
		if ISNUMERIC(dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ))) = 1
		begin

      		set @Azione = ' Pagina per la stampa del dettaglio del Bando di Gara '

			set @idMsg = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ) )
			select @fascicolo = Fascicolo, @protocollo = Protocollo from CTL_DOC with (nolock) where id = @idMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione, Fascicolo = @fascicolo, Protocollo = @protocollo where id = @id
		
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/BANDO_SDA.asp'
	begin

		if ISNUMERIC(dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ))) = 1
		begin

      		set @Azione = ' Pagina per la stampa del dettaglio del Bando SDA '

			set @idMsg = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ) )
			select @fascicolo = Fascicolo, @protocollo = Protocollo from CTL_DOC with (nolock) where id = @idMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione, Fascicolo = @fascicolo, Protocollo = @protocollo where id = @id
		
		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/BANDO_SEMPLIFICATO_INVITO.asp'
	begin

      	set @Azione = ' Pagina per la stampa del dettaglio del Bando Semplificato Invito '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/BANDO_SEMPLIFICATO_INVITO.asp'
	begin

      	set @Azione = ' Pagina per la stampa del dettaglio del Bando Semplificato Invito '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/Genera_CSV.ASP'
	begin

      	set @Azione = ' Pagina per generazione foglio CSV prodotti '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/OFFERTA_BUSTA_ECO.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF offerta busta economica documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/OFFERTA_BUSTA_TEC.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF offerta busta tecnica documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/OFFERTA_CAUZIONE.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF cauzione offerta documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/OFFERTA_PRODOTTI.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF prodotti offerta - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/prn_ISTANZA_SDA_FARMACI.ASP'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF SDA FArmaci documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/prn_ISTANZA_SDA_2.ASP'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF Istanza SDA documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/prn_ISTANZA_SDA_3.ASP'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF Istanza SDA documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end															 
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/report/prn_ISTANZA_SDA_IC.ASP'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Pagina per generazione PDF Abilitazione SDA documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/report/COM_STIPULA_CONTRATTO.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Stampa documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/CTL_LIBRARY/functions/getXslt.asp'
	begin

		set @DocName = dbo.GetValue( 'ML_XSLT' ,@querystring)
		set @Azione = ' Rappresentazione dal portale'
		if @DocName='XSLT_ESITO_BANDO_JOOMLA'
			set @Azione = ' Rappresentazione dettaglio Esito Gara dal portale '
		else
			set @Azione = ' Rappresentazione dettaglio Gara dal portale '

		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_LIBRARY/DOCUMENT/xml.asp'
	begin

		set @DocName = dbo.GetValue( 'TYPEDOC' ,@querystring)
		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
				left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
		where DOC_ID = @DocName  
		
      	set @Azione = ' Recupero dati del documento - ' + @DocName
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/report/COM_ESITO_GARA_V2.asp'
	begin
		
		set @Azione = ' Visualizzazione Esito Gara '
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/Ctl_Library/Document/Partecipa.asp'
	begin

		if ISNUMERIC(dbo.GetValue( 'IdMsgPar' ,@querystring)) = 1
		begin

			set @DocName = dbo.GetValue( 'TIPODOC' ,@querystring)
			select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
					left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
			where DOC_ID = @DocName  

			if rtrim( isnull( @DocName , '' ) ) = '' 
				set @DocName = 'Istanza di iscrizione'


			select @DocPartenza = cast( isnull(ML_Description,DOC_DescML) as varchar(255)) , @titolo = titolo 
				from ctl_doc b with (nolock)
					inner join LIB_Documents d with (nolock) on b.tipodoc = d.DOC_ID
					left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
			where b.id = dbo.GetValue( 'IdMsgPar' ,@querystring)
		
      		set @Azione = 'Partecipo al documento ''' + @DocPartenza + ''' titolo: ' + @Titolo + '  con  [' + @DocName + ']' 

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if left( @paginaDiArrivo , 16 ) = 'APERTURA BUSTA ['
	begin

		update CTL_LOG_UTENTE_LAVORO set descrizione = @paginaDiArrivo where id = @id

	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_library/document/DocumentCurFolder.asp'
	begin

		set @DocName = dbo.GetValue( 'FOLDER' ,@querystring)

      	set @Azione = 'Visualizzata la busta ['  + @DocName + ']'

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = @Azione 
			where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/SbloccoBusteSuccessive.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set  @idMsg = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza) 
		
			--recupero protocollo bando relativo alla PDA
			select @Azione = 'Valutazione gara - Sblocco Buste Successive - Protocollo Bando:' + ProtocolloBando from tab_messaggi_fields with (nolock) where idmsg=@IdMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end
	

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/ChiudiValutazioneTecnica.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set  @idMsg = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza) 
		
			--recupero protocollo bando relativo alla PDA
			select @Azione = 'Valutazione gara - Attiva Valutazione Economica - Protocollo Bando:' + ProtocolloBando from tab_messaggi_fields with (nolock) where idmsg=@IdMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/customdoc/AttivaValutazioneTecnica.asp'
	begin
		
		if ISNUMERIC(dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza)) = 1
		begin

			set  @idMsg = dbo.GetValue( 'lIdMsgPar' ,@paginaDiPartenza) 
		
			--recupero protocollo bando relativo alla PDA
			select @Azione = 'Valutazione gara - Attiva Valutazione Tecnica - Protocollo Bando:' + ProtocolloBando from tab_messaggi_fields  with (nolock) where idmsg=@IdMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_library/path.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Pagina intermedia per far entrare la richiesta nelle molliche di pane' 
			where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/dashboard/groupsview.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Apertura documenti collegati' 
			where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_library/functions/gotofun.asp'
	begin

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Pagina intermedia per aprire una funzione' 
			where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @querystring = 'firmaDigitale()'
	begin

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Risposta Hash Firma Digitale =' + REPLACE(@form,'Output da pdf.aspx:','')
			where id = @id 

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/CTL_LIBRARY/Abandon.asp' or @paginaDiArrivo ='/Application/logout.asp'
    begin
  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Logout utente ' 
			where id = @id 

    end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_library/functions/infoNodoGeo.asp'
    begin
  
		declare @fldname as varchar(500)
	  
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'fldname' ,@querystring  ) )
		set @DocNameTec = dbo.URL_Decode( dbo.GetValue( 'DOCUMENT' ,@paginaDiPartenza ) )

		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  
			from LIB_Documents d with (nolock)
			left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
			where DOC_ID = @DocNameTec

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Apertura Dominio geografico per ' + @fldname + ' geografica dal documento ' + @DocName
			where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/Ctl_Library/gerarchici.asp'
    begin
	   
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'fldname' ,@querystring  ) )
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Apertura Dominio geografico per ' + @fldname 
			where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/CTL_LIBRARY/GetDomValue.asp'
    begin
	   
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'DOMAIN' ,@querystring  ) )
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Recupero Descrizione domini estesi per ' + @fldname 
			where id = @id 

    end
    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/CTL_LIBRARY/GetFilteredField.asp'
    begin
	  
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'FIELD' ,@querystring  ) )
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Recupero dominino filtrato per ' + @fldname 
			where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_library/pdf/pdf_stamp.asp'
    begin
	   
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'FILE-NAME' ,@querystring  ) )
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Genera pdf per ' + @fldname 
			where id = @id 
    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_library/refresh.asp'
    begin
	   
		set @fldname = dbo.URL_Decode( dbo.GetValue( 'COSA' ,@querystring  ) )
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Refresh metadati per ' + @fldname 
			where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/home/main.asp'
    begin
	  
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Apertura home utente ' 
			where id = @id 
    end


--TABLE=ctl_doc&IDDOC=77063&OPERATION=INSERTSIGN&CF=FRRSBT69H08I862R&IDENTITY=Id&AREA=&DOMAIN=FileExtention&FORMAT=&UFP=45094

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/attachsign/CTL_LIBRARY/functions/FIELD/SaveAttachSigned.asp'
    begin
	  
		set @Azione = ' Inserimento allegato firmato nel database CF [' + dbo.GetValue( 'CF' ,@querystring)  + ']'
		if @querystring = 'TRACE-INFO'
			set @Azione = ' Termine operazione richiesta di inserimento allegato firmato nel database'
		         
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/attachsign/CTL_LIBRARY/MessageBoxWin.asp'
    begin
	  
		set @Azione = dbo.GetValue( 'MSG' ,@querystring)  	  
		set @Azione=dbo.UrlDecode_OK(@Azione)
	  

		if @querystring = 'TRACE-INFO'
			set @Azione = dbo.GetValue( 'MSG' ,@form)  

		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
	  
    end
    
   
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_library/functions/InfoAziFromCF.asp'
    begin
	  
		set @Azione = dbo.GetValue( 'CodiceFiscale' ,@querystring)  

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'recupero info azienda dal codice fiscale ' + @Azione where id = @id
	  
    end

   
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_library/functions/InfoUserFromCF.asp'
    begin

		if ISNUMERIC(dbo.GetValue( 'utenteidpfu' ,@querystring)) = 1
		begin

			set @Azione = ' dal codice fiscale '
			set @tempdesc = ''
			set @tempdesc = dbo.GetValue( 'CodiceFiscale' ,@querystring)  
			set @Azione = @Azione + @tempdesc

			if @tempdesc = ''
			begin

				set @idpfu = 0
				set @idpfu = dbo.GetValue( 'utenteidpfu' ,@querystring)  

				select @tempdesc = pfunome from profiliutente with (nolock) where idpfu=@idpfu

				set @Azione = ' dall''identificativo dell''utente ' + @tempdesc
		  
			end

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'recupero info utente a partire ' +  @Azione where id = @id

		end
    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/InfoCurrentUser.asp'
	begin
	  
		if ISNUMERIC(dbo.GetValue( 'Utente' ,@querystring)) = 1
		begin
			set @idpfu = 0
			set @idpfu = dbo.GetValue( 'Utente' ,@querystring)  

			select @tempdesc = pfunome from profiliutente with (nolock) where idpfu=@idpfu

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'recupero info dell''utente ' + @tempdesc where id = @id
		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/ctl_Library/document/Excel.asp'
    begin
	  
		set @DocNameTec = dbo.URL_Decode( dbo.GetValue( 'DOCUMENT' ,@querystring  ) )

		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  
			from LIB_Documents d with (nolock)
			left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
			where DOC_ID = @DocNameTec

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'esporta in excel documento ' + @DocName where id = @id
	  
    end


--key=ATC&level=0&father=ATC&mode=all&dominio=A_ATC&format=J&editable=&filter=&_=1458560975722
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/getLazyNodes.asp'
    begin
	  
		set @DocNameTec = dbo.URL_Decode( dbo.GetValue( 'dominio' ,@querystring ) )

		select @DocName = cast( isnull(ML_Description,DM_DescML ) as varchar(255))  
			from LIB_Domain  d with (nolock)
			left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DM_DescML and ML_LNG = 'I' and ML_Context = 0
			where  dm_id = @DocNameTec

		  

		update CTL_LOG_UTENTE_LAVORO set descrizione = 'apertura ramo dominio gerarchico ' + @DocNameTec where id = @id
	  
    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--PAGE=../../pdf/importa_zip_pdf.asp&ID=73225&VIEW=SEDUTA_SDA_3_CLICK_SIGNATURE&PDF_URL=1%261%26TABLE%3Dctl_doc%26IDENTITY%3DId%26AREA%3D%261%3D1
    if @paginaDiArrivo = '/application/ctl_Library/pdf/importa_zip_pdf.asp'
    begin
	  
	   update CTL_LOG_UTENTE_LAVORO set descrizione = 'importazione zip file firmati' + @DocNameTec where id = @id
	  
    end
    
    
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/application/CTL_LIBRARY/pdf/pulisciSessioneBuste.asp'
    begin
	   
		if @paginaDiPartenza like '%genera_buste.asp%'

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'chiusura Processo di Generazione PDF delle buste' where id = @id
	  
		else

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'chiusura del processo di importazione zip file firmati ' where id = @id

    end

    --if @paginaDiArrivo = '/application/CTL_LIBRARY/pdf/pulisciSessioneBuste.asp'
    --begin
	   
	--   update CTL_LOG_UTENTE_LAVORO set descrizione = 'chiusura del processo di importazione zip file firmati ' where id = @id
	  
    --end
    
    
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/application/CTL_LIBRARY/pdf/zip_pdf.asp'
    begin
	   
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'produzione zip con pdf da firmare ' where id = @id
	  
    end
    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/login_conferma.asp'
    begin
	   
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'avviso per informare di una sessione già in uso' where id = @id
	  
    end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    --IDDOC=83582&TYPEDOC=BANDO&lo=base
    --select tipobando, * from ctl_doc inner join document_bando on idheader=id where id=83582
    if @paginaDiArrivo = '/Application/Report/BANDO.asp'
    begin

		if @querystring = 'TRACE-INFO' and @paginaDiArrivo ='/Application/Report/BANDO.asp'
		begin      
		
			update CTL_LOG_UTENTE_LAVORO 
				set descrizione = 'la pagina' + @paginaDiArrivo + ' ha completato l''elaborazione'
				where id = @id  
			
		end  
		
		if ISNUMERIC(dbo.URL_Decode(dbo.GetValue( 'IDDOC' ,@querystring ))) = 1
		begin

			set @idMsg = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ) )
	   
			select 
				 @tempdesc  = isnull(jumpcheck,'Mercato Elettronico')
				,@TempApp = protocollo
				,@fascicolo = Fascicolo
				,@protocollo = Protocollo
				from 
					ctl_doc with (nolock) 
				where id=@idMsg

			update CTL_LOG_UTENTE_LAVORO set descrizione = 'apertura dettaglio bando ' +  @tempdesc + ' - ' + @TempApp where id = @id

			if isnull(@fascicolo,'') <> ''
			begin
				--Inserisco il fascicolo nella colonna Fascicolo della CTL_LOG_UTENTE_LAVORO
				update CTL_LOG_UTENTE_LAVORO set Fascicolo = @fascicolo where id = @id
			end

			if isnull(@protocollo,'') <> ''
			begin
				--Inserisco il protocollo nella colonna protocollo della CTL_LOG_UTENTE_LAVORO
				update CTL_LOG_UTENTE_LAVORO set Protocollo = @protocollo where id = @id
			end
		end

    end
    
	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    --IDDOC=62049&TIPODOC=LISTINO_CONVENZIONE&HIDECOL=TipoDoc&OPERATION=&DOCUMENT=LISTINO_CONVENZIONE&MODEL=MODELLO_BASE_CONVENZIONI_ALTRIBENI_MOD_PerfListino
    if @paginaDiArrivo = '/Application/Report/CSV_LOTTI.asp'
    begin
	    
		if ISNUMERIC(dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring ))) = 1
		begin

			set @idMsg = dbo.URL_Decode(dbo.GetValue('IDDOC' ,@querystring))

			select @tempdesc  = protocollo, @Titolo=titolo from ctl_doc with (nolock) where id=@idMsg
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'esporta xlsx sul documento con Protocollo:' + @tempdesc + ' - Titolo:' + @Titolo where id = @id
		
		end
    end

    
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if (@paginaDiArrivo = '/Application/ctl_library/document/DownloadAttach.asp' or @paginaDiArrivo='/attachSign/CTL_LIBRARY/document/DownloadAttach.asp')
    begin

		set @DocNameTec = dbo.URL_Decode( dbo.GetValue( 'DOCUMENT' ,@querystring) )
		set @IDDOC = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring) )
		set @SOURCE = dbo.URL_Decode( dbo.GetValue( 'SOURCE' ,@querystring) )
		

		select @DocName = cast( isnull(ML_Description,DOC_DescML) as varchar(255))  from LIB_Documents d with (nolock)
			left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
			where DOC_ID = @DocNameTec	
			
		if (@paginaDiArrivo = '/Application/ctl_library/document/DownloadAttach.asp')
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Download tutti gli allegati del documento in unico ZIP - Documento = ' + @DocName + ' - ID = ' + @IDDOC + ' -  SORGENTE = ' + @SOURCE where id = @id
		else
			update CTL_LOG_UTENTE_LAVORO set descrizione = 'Download tutti gli allegati del documento in unico ZIP - Documento = ' + @DocName + ' - ID = ' + @IDDOC  where id = @id

    end

    
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/application/CTL_LIBRARY/pdf/genera_buste.asp'
    begin

		set @IDDOC = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring) )
	   
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Generazione PDF da firmare in unico ZIP del documento Offerta' + case when @IDDOC <> '' then ' - IDDOC = ' + @IDDOC else ' - iterazione successiva ' end
			where id = @id
	  
    end

    
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/customdoc/PresenzaInfoAggiuntive.asp'
    begin

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Pagina invocata sulla scelta delle classi per capire se richieste o meno le informazioni aggiuntive'	where id = @id
	  
    end
    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/NoTIER/lista.asp'
    begin

	   update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Pagina per recuperare la lista documenti da NOTIER'	where id = @id
	  
    end

  
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
    if @paginaDiArrivo = '/Application/report/prn_OrdinativoFornitura.asp'
    begin

	   update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Pagina per generazione PDF degli Ordinativi'	where id = @id
	  
    end
    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/application/ctl_Library/pdf/importaBusteFirmate.asp'
    begin

	   set @form= replace(@form,'<td>',' ')
	   set @form= replace(@form,'</tr>',' - ')

	   update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Importa Buste Firmate - ' + 
				case 
					when @querystring ='TRACE-INFO' then + 'fine importazione - '	+ dbo.StripHTML(@form)
					when @querystring ='ID_OFFERTA=' then + 'importazione in corso'	
					else 'inizio importazione'
				end
			where id = @id
	  
    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CustomDoc/SEDUTA_VIRTUALE.asp'
    begin
	
		--IDDOC=1615832&COMMAND=INFO_AMM&LOTTO=&nocache=1558518481243		
		if ISNUMERIC(dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring) )) = 1
		begin

			set @SOURCE = dbo.URL_Decode( dbo.GetValue( 'COMMAND' ,@querystring) )
			set @IDDOC = dbo.URL_Decode( dbo.GetValue( 'IDDOC' ,@querystring) )

			select @tempdesc= sv.Protocollo
				from ctl_doc sv with(NOLOCK) 
					inner join ctl_doc DOC with(NOLOCK) on DOC.LinkedDoc=SV.LinkedDoc and DOC.TipoDoc='PDA_MICROLOTTI' and DOC.Deleted=0
				where sv.id=@IDDOC

			if @SOURCE = 'INFO_AMM'
			begin
				set @tempdesc = @tempdesc + '" - Recupero Informazioni amministrative'
			end

			if @SOURCE = 'INFO_LOTTO'
			begin
				set @tempdesc = @tempdesc + '" - Recupero Informazioni tecnico ecnomico Lotto'
			end

			if @SOURCE = 'INFO_LOTTI'
			begin
				set @tempdesc = @tempdesc + '" - Recupero Informazioni tecnico ecnomico Lotti'
			end
		
			update CTL_LOG_UTENTE_LAVORO 
				set descrizione = 'Seduta Virtuale Gara  "' + @tempdesc  
				where id = @id

		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_Library/CHAT/Chat.asp'
    begin

		if ISNUMERIC(dbo.URL_Decode( dbo.GetValue( 'ROOM' ,@querystring) )) = 1
		begin

			set @tempdesc = 'Live Chat '
			set @SOURCE = dbo.URL_Decode( dbo.GetValue('ROOM',@querystring))
			set @DocName = dbo.URL_Decode( dbo.GetValue('ACTION',@querystring))
	    
			IF @SOURCE='' AND @DocName=''
				set @tempdesc= 'Apertura Elenco Chat di pertinenza'

			if @SOURCE <> '' 
			begin
				select @SOURCE = title  from CTL_CHAT_ROOMS with (nolock) where idheader =@SOURCE
				set @tempdesc  = @tempdesc + ' - "' + @SOURCE + '"'
			end

			if @DocName = 'NEW_MSG'
				set @tempdesc = @tempdesc + ' - Nuovo Messaggio '
		
			if @SOURCE <> '' and @DocName = ''
			begin
				set @tempdesc = @tempdesc + ' - Recupero Messaggi '
			end
	
			update 
				CTL_LOG_UTENTE_LAVORO 
					set descrizione = @tempdesc
				where id = @id

		end
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/quesiti/GetHtmlQuesiti.asp'
	begin
		--EXPIRYDATE=2019-08-31T23:59:00&DOCUMENT=BANDO_GARA&IDDOC_GUID=87267&PROTOCOLLOBANDO=&SUBTYPE_ORIGIN=&FASCICOLO=FE000979&QUESITOANONIMO=1&nocache=1568099054558

		set @DocName=dbo.GetValue( 'DOCUMENT' ,@querystring) 

		if @DocName=''
		begin

			--documento generico
			if ISNUMERIC(dbo.GetValue( 'SUBTYPE_ORIGIN' ,@querystring)) = 1
			begin
				set @lItypePar =55
				set @lISubTypePar  =  dbo.GetValue( 'SUBTYPE_ORIGIN' ,@querystring)
                
				select 	@DocName = 	cast( mlngDesc_I as varchar(MAX)) 
						from Document with(nolock)
							inner join multilinguismo with(nolock) on dcmDescription = IdMultiLng
						where @lItypePar = dcmIType and   @lISubTypePar = dcmIsubType 
                
				set @Azione = ' Recupero quesiti del documento ' + isnull( @DocName  , '' ) 

				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

			end
		end
		else
		begin

			--nuovi documenti
			if ISNUMERIC(dbo.GetValue( 'IDDOC_GUID' ,@querystring)) = 1
			begin

				set @ret  =  dbo.GetValue( 'IDDOC_GUID' ,@querystring) 

				select @DocPartenza = cast( isnull(ML_Description,DOC_DescML) as varchar(255)) , @titolo = titolo , @protocollo = Protocollo
					from ctl_doc b with (nolock)
						inner join LIB_Documents d with (nolock) on b.tipodoc = d.DOC_ID
						left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
				where b.id = @ret
		

      			set @Azione =  ' Lista quesiti del ''' + @DocPartenza + ''' titolo:"' + @Titolo  + '" - Protocollo: ' + @protocollo
			
				update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
				
			end

		end
		
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/dashboard/reportDocument.asp'
	begin
		
		--lo=base&IDDOC=301278&DOCUMENT=BANDO_GARA
		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@querystring)) = 1
		begin

			set @DocName=dbo.GetValue( 'DOCUMENT' ,@querystring) 
		
			select @DocPartenza = cast( isnull(ML_Description,DOC_DescML) as varchar(255)) , @titolo = titolo , @protocollo = Protocollo
					from ctl_doc b with (nolock)
						inner join LIB_Documents d with (nolock) on b.tipodoc = d.DOC_ID
						left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
				where b.id = dbo.GetValue( 'IDDOC' ,@querystring)

      		set @Azione = ' Pagina intermedia per la stampa del dettaglio del '''  + @DocPartenza + ''' titolo: "' + @Titolo  + '" - Protocollo: ' + @protocollo

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end

	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/quesiti/InserisceQuesito.asp'
	begin
		
		--lo=base&IDDOC=301278&DOCUMENT=BANDO_GARA
		if ISNUMERIC(dbo.GetValue( 'IDDOC' ,@paginaDiPartenza)) = 1
		begin

			select @DocPartenza = cast( isnull(ML_Description,DOC_DescML) as varchar(255)) , @titolo = titolo , @protocollo = Protocollo
				from ctl_doc b with (nolock)
					inner join LIB_Documents d with (nolock) on b.tipodoc = d.DOC_ID
					left outer join LIB_Multilinguismo m with (nolock) on ML_KEY = DOC_DescML and ML_LNG = 'I' and ML_Context = 0
				where b.id = dbo.GetValue( 'IDDOC' ,@paginaDiPartenza)

      		set @Azione = ' sul documento '  + @DocPartenza + ' con Protocollo "' + @protocollo + '"'
		
			if @querystring=''
				set @Azione = ' Inserimento Quesito ' + @Azione
		
			if @querystring = 'TRACE-ERROR'
				set @Azione = ' Errore  Inserimento Quesito ' + @Azione
		
			if @querystring = 'TRACE-INFO'
				set @Azione = @form + @Azione  

			update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

		end
	end

	
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	--decodifica schedulazione decifratura di un allegato 
	if left(@paginaDiArrivo,19) = 'APERTURA ALLEGATO ['
	begin
		
		set @protocollo=REPLACE(@paginaDiArrivo,'APERTURA ALLEGATO [','')
		set @protocollo=REPLACE(@protocollo,']','')

		select @DocPartenza = att_name
			from CTL_Attach with (nolock)
			where ATT_Hash=@protocollo

      	set @Azione = ' Schedulazione Decifratura Allegato "'  + @DocPartenza + '"'
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	--decodifica fine sessione/fine applicazione
	if @paginaDiArrivo = 'gloabal.asa'
	begin
		
		select @tempdesc = pfunome from profiliutente with (nolock) where idpfu=@idpfu

		if @querystring ='Session_onEnd'
			set @Azione = 'Fine Sessione - Utente:' + @tempdesc

		if @querystring ='Application_OnEnd'
			set @Azione = 'Fine Applicazione'
		
		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	--nuova gestione degli allegati
	if @paginaDiArrivo = '/AF_WebFileManager/proxy/1.0/uploadattach'  
	begin
		
		if  @querystring in ('TRACE-INFO' , 'TRACE-ERROR' )
		begin
			set @Azione = @form 
		end
		
		--acckey=F699A2F0%2DEA83%2D4ED8%2D8F6B%2DD813DB16698B&OPERATION=INSERT&FIELD=R0_CampoAllegato_1&PATH=%2E%2E%2F%2E%2E%2F&TECHVALUE=&FORMAT=HINTVCEXT:pdf,p7m,zip,rar,7z-&DOMAIN=FileExtention&IDDOC=402327&CIF=1&idPfu=45573
		if @querystring like 'acckey=%'
	    begin
			set @Azione = 'AVVIO UPLOAD per il campo [' + dbo.GetValue( 'FIELD' ,@querystring)  + ']'
		end
		
		if @browserusato = 'HASH'
			set  @Azione =  'HASH SHA256 :' + @form 

		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = 'Richiesta Chiave Cifratura Allegati'  
	begin
		update CTL_LOG_UTENTE_LAVORO set descrizione = @paginaDiArrivo where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo in ('LETTURA BUSTA [BUSTA_ECONOMICA]','LETTURA BUSTA [PRODOTTI]','LETTURA BUSTA [BUSTA_TECNICA]','LETTURA BUSTA [DOCUMENTAZIONE]','LETTURA BUSTA [TOTALI]','LETTURA BUSTA [BUSTA_AMMINISTRATIVA]','LETTURA BUSTA [OFFERTA_BUSTA_ECO]') 
	begin
		update CTL_LOG_UTENTE_LAVORO set descrizione = @paginaDiArrivo where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_LIBRARY/DOCUMENT/ElencoRilanci.asp'  
	begin
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'avvia l''aggiornamento dell''area Elenco Rilanci' where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/functions/Trace_in_log_utente.asp'  
	begin
		set @Azione = replace(dbo.GetValue( 'azione' ,@querystring) , '%20' , ' ' )  

		if @Azione='richiesta chiusura browser'
			set @Azione='L''utente ha provato a chiudere/ricaricare il browser ed ha ricevuto un messaggio di sistema per confermare oppure no l''azione.'

		update CTL_LOG_UTENTE_LAVORO set descrizione = @Azione where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = 'VerificaBaseAstaOffertaLotto'
	begin
		update CTL_LOG_UTENTE_LAVORO set descrizione = 'Verifica valore offerta con quanto richiesto nella gara' where id = @id
	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/ctl_library/accessBarrier.asp'
	begin

		set @Azione = dbo.GetValue( 'LINK' ,@querystring)

		if @Azione=''
			set @descrizione = 'gestione GUID per controllo di sessione '
		else
			set @descrizione = 'generazione GUID per passaggio ad applicazione esterna (' +  @Azione + ')'
		update CTL_LOG_UTENTE_LAVORO set descrizione =  @descrizione where id = @id

	end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_LIBRARY/GetField.asp'
    begin
	   
	  set @fldname = dbo.URL_Decode( dbo.GetValue( 'FIELD' ,@querystring  ) )
	  
	   update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Recupero HTML per ' + @fldname 
		where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/CTL_Library/functions/GetInfoCertificato.asp'
    begin
	  
		set @TempApp = dbo.URL_Decode( dbo.GetValue( 'VALUE' ,@querystring  ) )
		
		declare   @t table( Allegato  nvarchar(1000) )
		
		insert into @t
			(allegato)
		select *
			from dbo.split( replace( @TempApp, '&','&amp;') ,'***')


		declare @lista_allegati as nvarchar(max)
		set @lista_allegati=''

		select 
			@lista_allegati = @lista_allegati + ', ' + left( allegato,CHARINDEX('*',allegato)-1 )
			from @t

		if @lista_allegati <> ''
			set @lista_allegati = substring(@lista_allegati , 3,len(@lista_allegati))

		

		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Recupero Informazioni del Certificato per gli allegati ' + @lista_allegati 
		where id = @id 

    end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
	if @paginaDiArrivo = '/Application/blocked.asp'
    begin
		update CTL_LOG_UTENTE_LAVORO 
			set descrizione = 'Blocco di sicurezza'
		where id = @id 
	end

	--Setto la colonna fascicolo a vuota se non è valorizzata per tener traccia dei record già decodificati
	update CTL_LOG_UTENTE_LAVORO set Fascicolo = '' where id = @id and Fascicolo is null

end     


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

















GO
