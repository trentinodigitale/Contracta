USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANALISI_LOG_TAB_COMPILAZIONE_OFFERTA ]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--------------------------------------------------------------

--@STEP
	--1 TEMPO LAVORATO SULL'OFFERTA COME MINUTI AL GIORNO SUll'OFFERTA
	--2 ALLEGATI RICHIESTI BUSTA DOCUMETAZIONE
	--3 ALLEGATI INSERITI NELLA BUSTA DOCUMETAZIONE 
	--4 ALLEGATI RICHIESTI BUSTA TECNICA e BUSTA ECONOMICA
	--5 ALLEGATI INSERITI NELLA BUSTA TECNICA e BUSTA ECONOMICA
	--6 CONTROLLO SE HA ALLEGATO LE BUSTE TECNICA ED ECONOMICA FIRMATE
	--7 ERRORI TRACCIATI NEL LOG
---------------------------------------------------------------
CREATE proc [dbo].[OLD_ANALISI_LOG_TAB_COMPILAZIONE_OFFERTA ]
(
	@IdOfferta as int,
	@STEP as int,
	@DI as datetime = null ,
	@DF as datetime = null 
)
as
begin
	
	SET NOCOUNT ON

	declare @DataCreazione as datetime
	declare @DataScadenza as datetime
	declare @IdBando as int
	declare @IdModelloGara as int

	declare @IdPfu as int
	declare @TempString as nvarchar(1000)
	declare @nPos as int
	declare @RowCurr as int
	declare @AttribCurr as nvarchar(1000)
	declare @IndRowCanc as int
	declare @RowCurrString as varchar(100)
	declare @BustaCurr varchar(100)
	declare @NumAllegatiTecnica as int
	declare @NumAllegatiEconomica as int
	declare @DivisioneLotti as int

	--creo le tabelle temporanee per contare il numero di allegati inseriti 
	--nelle buste
	create table #TempAttachMem
			(
			Busta  varchar(100),
			Riga int, 
			Attributo nVarchar(500),
			)
	create table #TempAttachDB
			(
			Busta  varchar(100),
			Riga int, 
			Attributo nVarchar(500),
			)
	
	--compilatore offerta


	if exists (select * from ctl_doc with (nolock) where id =@IdOfferta  and tipodoc in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE'))
	begin
		select @IdPfu = idpfu , @DataCreazione =convert(varchar(19),data,121) , @IdBando=LinkedDoc   
			from CTL_DOC with (nolock) where Id = @IdOfferta 



		--data scadenza
		select  @DataScadenza = convert(varchar(19),DataScadenzaOfferta,121)  ,
				@DivisioneLotti = isnull(Divisione_lotti,0)
				from 
				CTL_DOC O with (nolock)  
				inner join Document_Bando WITH (NOLOCK) on  O.LinkedDoc = idHeader 
					where O.id = @IdOfferta
	
		--select @DataCreazione
		--select @DataScadenza
		--set @DataScadenza = DATEADD(hour,1,@DataScadenza)


		--print '----------ID DOC OFFERTA		= ' + cast(@IdOfferta as varchar)
		--print '----------COMPILATORE OFFERTA	= ' +  cast(@IdPfu as varchar)
		--print '----------DATA CREAZIONE OFFERTA = ' +  convert(varchar(19),@DataCreazione,121) + '-----------------'
		--print '----------DATA SCADENZA OFFERTA  = ' +  convert(varchar(19),@DataScadenza,121) + '-----------------'

		------------ID DOC OFFERTA		 = 2418938
		------------COMPILATORE OFFERTA	 = 56776
		------------DATA CREAZIONE OFFERTA = 2020-02-12 12:09:06-----------------
		------------DATA SCADENZA OFFERTA  = 2020-03-03 12:00:00-----------------

		----select * from ctl_doc with (nolock) where Id= 2418938


		----------POPOLO CTL_LOG_UTENTE_LAVORO
		delete CTL_LOG_UTENTE_LAVORO where idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza

		insert into CTL_LOG_UTENTE_LAVORO 
			(id, ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
			select id, ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID 
				from 
					CTL_LOG_UTENTE with (nolock)
				where idpfu  = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza --order by datalog

	
		--if @DI is null 
		--	set @DI = @DataCreazione
	
		--if @DF is null
		--	set @DF = @DataScadenza	



		if @STEP=1
		BEGIN
			-------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------1. TEMPO LAVORATO SULL'OFFERTA COME MINUTI AL GIORNO SUll'OFFERTA------------------------------------
			-------------------------------------------------------------------------------------------------------------------------------------------
			--select '1. TEMPO LAVORATO SULL''OFFERTA COME MINUTI AL GIORNO SUll''OFFERTA'
		
			select 
				convert(varchar(5),datalog,110) as Giorno, datediff (MINUTE, MIN(datalog),MAX (datalog)) as "Tempo Lavorato (Minuti Al Giorno)"
				from 
					CTL_LOG_UTENTE_LAVORO with (nolock)
				where idpfu = @IdPfu 
						and datalog >=@DataCreazione and datalog <=@DataScadenza
						and querystring like '%' + CAST(@IdOfferta as varchar)  + '%'
				group by convert(varchar(5),datalog,110) 
				order by convert(varchar(5),datalog,110) 
			
				
			--select 
			--	convert(varchar(16),datalog,121)  as Data, datediff (second, MIN(datalog),MAX (datalog)) as "Tempo Lavorato (Secondi)"--COUNT(*) as "Operazioni Sul Documento"
			--	from 
			--		CTL_LOG_UTENTE_LAVORO with (nolock)
			--	where idpfu = @IdPfu 
			--			and datalog >=@DI and datalog <=@DF
			--			and querystring like '%' + CAST(@IdOfferta as varchar)  + '%'
			--	group by convert(varchar(16),datalog,121) 
			--	order by convert(varchar(16),datalog,121)
			 

				
		END

	

	
		
		if @STEP=2
		BEGIN

			---------ALLEGATI RICHIESTI SUL BANDO------------------------------------------------------------------------------------------------------
			--select 'ALLEGATI RICHIESTI BUSTA DOCUMETAZIONE'
			select COUNT(*) as 'ALLEGATI RICHIESTI BUSTA DOCUMETAZIONE' from Document_Bando_DocumentazioneRichiesta with (nolock) where idHeader=@idBando and Obbligatorio=1
		END



		if @STEP = 3
		BEGIN	
			--3.1 ALLEGATI INSERITI NELLA BUSTA DOCUMETAZIONE 
			--CONTROLLO SE HA CARICATO E/O SALVATO GLI ALLEGATI OBBLIGATORI
			
			
			--select querystring ,form,browserUsato
			--		from 
			--			CTL_LOG_UTENTE_LAVORO with (nolock)
			--		where  
			--			idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza
			--			and 
			--				(
			--					( paginaDiArrivo like '%saveattach.asp%' and querystring like '%FIELD=RDOCUMENTAZIONEGrid%Allegato%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
			--					or
			--					( paginaDiArrivo like '%UploadAttach.asp%' and browserUsato ='HASH' )
			--					or 
								
			--					( paginaDiArrivo like '%saveattach.asp%' and querystring like 'TRACE-INFO' and form like 'TerminatePage. QueryString:OPERATION=INSERT&%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
								
			--					or 
			--					( paginaDiArrivo like '%document.asp%' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%' and dbo.getvalue('COMMAND',querystring ) <> '' )
			--					or 
			--					( paginaDiArrivo like '%functions/field/UploadAttach.asp' and  querystring like  '%FIELD=RDOCUMENTAZIONEGrid%' + CAST(@IdOfferta as varchar)  + '%' )
			--					--or 
			--					--( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%'  )
			--					or 
			--					( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  'TRACE-INFO' and cast(form as nvarchar(max)) <> '' )
							

			--				)
			--				order by datalog

			--faccio un cursore sulle righe del log che riguardano il caricamento degli allegati sulla busta di 
			--documentazione dell'offerta
			
			declare @Querystring as nvarchar(max)
			declare @Form as nvarchar(max)
			declare @BrowserUsato as nvarchar(max)
			declare @paginaDiArrivo as  nvarchar(max)
			declare @Allegato as varchar(1000)
			declare @NumAllegatiInseriti as int
			declare @UploadOk as int
			declare @HashOk as int
			declare @JobComplete as int
			declare @Comando as varchar (1000)
			declare @nSave as int

			set @UploadOk=0
			set @HashOk=0
			set @JobComplete=0
			set @NumAllegatiInseriti=0
			set @Allegato = ''
			set @Comando =''
			set @nSave = 0

			


			DECLARE crsAllegatiDocumentazione CURSOR STATIC FOR 
				
				select querystring ,form,browserUsato,paginaDiArrivo 
					from 
						CTL_LOG_UTENTE_LAVORO with (nolock)
					where  
						idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza
						and 
							(
								( paginaDiArrivo like '%saveattach.asp%' and querystring like '%FIELD=RDOCUMENTAZIONEGrid%Allegato%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
								or
								( paginaDiArrivo like '%UploadAttach.asp%' and browserUsato ='HASH' )
								or 
								
								( paginaDiArrivo like '%saveattach.asp%' and querystring like 'TRACE-INFO' and form like 'TerminatePage. QueryString:OPERATION=INSERT&%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
								
								or 
								( paginaDiArrivo like '%document.asp%' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%' and dbo.getvalue('COMMAND',querystring ) <> '' )
								or 
								( paginaDiArrivo like '%functions/field/UploadAttach.asp' and  querystring like  '%FIELD=RDOCUMENTAZIONEGrid%' + CAST(@IdOfferta as varchar)  + '%' )
								--or 
								--( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%'  )
								or 
								( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  'TRACE-INFO' and cast(form as nvarchar(max)) <> '' )
							

							)
							order by datalog

			OPEN crsAllegatiDocumentazione

			FETCH NEXT FROM crsAllegatiDocumentazione INTO @querystring,@Form,@BrowserUsato,@paginaDiArrivo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				set @Comando = dbo.getvalue('COMMAND',@querystring )


				--se una CANCEllazione DI UNA RIGA
				if @Comando ='DOCUMENTAZIONE.DELETE_ROW'
				begin
					--dalla tabella di memoria elimino tutte le entrate con quella riga
					--e decremento le entrate che hanno la riga maggiore di quella cancellata
					set @IndRowCanc = dbo.getvalue('IDROW',@querystring )
					
					delete from #TempAttachMem where  riga = @IndRowCanc and Busta ='DOCUMENTAZIONE'

					update #TempAttachMem
						set riga = riga -1 
							where riga > @IndRowCanc and Busta ='DOCUMENTAZIONE'

				end


				--nuovo allegato inserito
				if dbo.getvalue('FIELD',@querystring ) <> ''
				begin
					set @UploadOk = 0
					set @HashOk = 0
					set @JobComplete = 0
					set @Allegato = dbo.getvalue('FIELD',@querystring )
					
					--ricavo la riga ed il nome del campo
					set @TempString=''
					set @nPos = 0
					set @AttribCurr = ''
					set @TempString = replace (@Allegato,'RDOCUMENTAZIONEGrid_','')
					set @nPos =  charindex('_', @TempString)
					set @RowCurr = left ( @TempString , @nPos -1 )
					set @AttribCurr = right (@TempString, len (@TempString) - @nPos)

					if not exists(select * from #TempAttachMem where riga = @RowCurr and Attributo =@AttribCurr)
					begin
						insert into #TempAttachMem
							(Busta,riga,attributo)
							values
							('DOCUMENTAZIONE',@RowCurr,@AttribCurr)
					end

				end
				
				if @Allegato like '%DOCUMENTAZIONEGrid%' and @querystring='TRACE-INFO'
				begin
					--controllo che ci siano le tracce per upload avvenuto con successo
					--Upload completato, richiesto il job per lavorare il file : #Cauzione.p7m# (93547)
					if @Form like 'Upload completato, richiesto il job per lavorare il file :%'
						set @UploadOk = 1
					
					
					--Calcolo hash binario completato--5ED8B52166F927F00133FC4040FC1D03D40E931030286C6270BA5677D0712F5C
					if @BrowserUsato='HASH'
						set  @HashOk = 1

					--checkprogress--Job d98e652a8c224b0cb_20201027142007767 Completato con successo
					--'TerminatePage.%' per la vecchia gestione
					if @Form like 'Job %Completato con successo%' 
						set @JobComplete = 1
					

					--per la vecchia gestione
					if @Form like 'TerminatePage.%&FIELD=RDOCUMENTAZIONE%'
					begin
						set @UploadOk = 1
						set  @HashOk = 1
						set @JobComplete = 1
					end

				end	
				
				
				if @Allegato like '%DOCUMENTAZIONEGrid%' and @UploadOk = 1 and @HashOk = 1 and @JobComplete = 1
					
				begin
					set @NumAllegatiInseriti = @NumAllegatiInseriti + 1
					set @Allegato=''
				end
				
				--se ho salvato oppure eseguito processi sull'offerta allora gli allegati sono statiresi persistenti
				if @NumAllegatiInseriti >0 and @Comando in ('SAVE','PROCESS')	
				begin
					set @nSave=1
					delete from #TempAttachDB 
					insert into #TempAttachDB 
						(Busta,riga,attributo)
						select Busta,riga,attributo from #TempAttachMem 
				end

				FETCH NEXT FROM crsAllegatiDocumentazione INTO @querystring,@Form,@BrowserUsato,@paginaDiArrivo
			END

			CLOSE crsAllegatiDocumentazione 
			DEALLOCATE crsAllegatiDocumentazione 

			--if @nSave = 1 
			--	select @NumAllegatiInseriti as 'ALLEGATI INSERITI E SALVATI NELLA BUSTA DOCUMETAZIONE'
			--else
			--	select 0 as 'ALLEGATI INSERITI E SALVATI NELLA BUSTA DOCUMETAZIONE'
			--select * from #TempAttachMem 
			--select * from #TempAttachDB 

			select count(*) as 'ALLEGATI INSERITI E SALVATI BUSTA DOCUMETAZIONE' 
				from #TempAttachDB  where busta ='DOCUMENTAZIONE'
		END
	
	
			
		if @STEP=4
		begin
		
			--recupero gli allegati richiesti nella busta  economica
			--select 'ALLEGATI RICHIESTI BUSTA TECNICA\ECONOMICA'

			select @idModelloGara=id 
				from 
					CTL_DOC with (nolock) 
				where LinkedDoc = @IdBando and TipoDoc='config_modelli_lotti' and Deleted=0
		
				select 
					T.DZT_Name as 'BUSTA ECONOMICA', 
						count(t1.value) as 'ALLEGATI RICHIESTI'
					--T1.Value as 'Attributo', 
					--T2.Value as 'Descrizione' 

						from CTL_DOC_Value T with (nolock) 
							inner join CTL_DOC_Value T1 with (nolock) on T1.idheader = T.IdHeader and T1.Row=T.row and T1.DZT_Name ='DZT_Name'
							inner join CTL_DOC_Value T2 with (nolock) on T2.idheader = T.IdHeader and T2.Row=T.row and T2.DZT_Name ='descrizione'
							inner join LIB_Dictionary L on L.DZT_Name =  T1.Value and L.DZT_Type = 18
						where T.IdHeader = @idModelloGara 
							and T.DZT_Name ='MOD_Offerta'
							and T.Value='obblig' 
							group by T.DZT_Name
							--order by T.DZT_Name desc
				
		end



		if @STEP=5
		BEGIN
			
			select @idModelloGara=id 
				from 
					CTL_DOC with (nolock) 
				where LinkedDoc = @IdBando and TipoDoc='config_modelli_lotti' and Deleted=0
		
				select 
					case when T.DZT_Name='MOD_Offerta' then 'ECONOMICA' else 'TECNICA' end  as Busta, 
						--count(t1.value) as 'NumeroAllegati Richiesti' 
					T1.Value as 'Attributo'--, 
					--T2.Value as 'Descrizione' 
							into #AllegatiTecnicaEconomica
						from CTL_DOC_Value T with (nolock) 
							inner join CTL_DOC_Value T1 with (nolock) on T1.idheader = T.IdHeader and T1.Row=T.row and T1.DZT_Name ='DZT_Name'
							inner join CTL_DOC_Value T2 with (nolock) on T2.idheader = T.IdHeader and T2.Row=T.row and T2.DZT_Name ='descrizione'
							inner join LIB_Dictionary L on L.DZT_Name =  T1.Value and L.DZT_Type = 18
						where T.IdHeader = @idModelloGara 
							and T.DZT_Name in ('MOD_OffertaTec','MOD_Offerta') 
							and T.Value='obblig' 
							--group by T.DZT_Name

			--3.1 BUSTA TECNICA\ECONOMICA 
			--CONTROLLO SE HA CARICATO E/O SALVATO GLI ALLEGATI OBBLIGATORI

			--select 'ALLEGATI RICHIESTI BUSTA TECNICA\ECONOMICA'
			
			--select 
			--		case 
			--			when dbo.getvalue('FIELD',querystring ) <>'' then 'Inserimemto allegato campo tecnico ' + dbo.getvalue('FIELD',querystring )
			--			when paginaDiArrivo like '%/proxy/1.0/uploadattach'  then cast(descrizione as varchar(max)) + '--' + cast(form as varchar(max)) 
			--		end	
			--		as Allegato,
			--		dbo.getvalue('COMMAND',querystring ) as Comando , 
			--		dbo.getvalue('PROCESS_PARAM',querystring ) as Processo, 
			--		datalog ,
			--		PaginadiArrivo, 
			--		paginadipartenza, 
			--		querystring,
			--		form,
			--		descrizione,
			--		browserUsato 
			--		from 
			--			CTL_LOG_UTENTE_LAVORO with (nolock)
			--		where  
			--			idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza
			--			and 
			--				(
			--					( paginaDiArrivo like '%saveattach.asp%' and querystring like '%CampoAllegato_%&IDDOC=' + cast(@IdOfferta as varchar) + '%' )
			--					or
			--					( paginaDiArrivo like '%UploadAttach.asp%' and browserUsato ='HASH' )
			--					or 
			--					( paginaDiArrivo like '%saveattach.asp%' and querystring like 'TRACE-INFO' and form like 'TerminatePage. QueryString:OPERATION=INSERT&%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
			--					or 
			--					( paginaDiArrivo like '%saveattach.asp%' and paginaDiPartenza like'%CampoAllegato_%&IDDOC=' + CAST(@IdOfferta as varchar)  +' %' )
			--					or 
			--					( paginaDiArrivo like '%document.asp%' and  querystring like '%' + CAST(@IdOfferta as varchar)  + '%'  and dbo.getvalue('COMMAND',querystring ) <> '' )
			--						or 
			--						( paginaDiArrivo like '%functions/field/UploadAttach.asp' and  querystring like  '%CampoAllegato_%' + CAST(@IdOfferta as varchar)  + '%' )
			--						--or 
			--						--( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%'  )
			--						or 
			--						( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  'TRACE-INFO' and cast(form as nvarchar(max)) <> '' )
							

			--				)
			--	order by datalog


			set @UploadOk=0
			set @HashOk=0
			set @JobComplete=0
			set @NumAllegatiInseriti=0
			set @Allegato = ''

			DECLARE crsAllegatiTecnicaEconomica CURSOR STATIC FOR 
				
				select querystring ,form,browserUsato
					from 
						CTL_LOG_UTENTE_LAVORO with (nolock)
					where  
						idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza
						and 
							 
						(
							( paginaDiArrivo like '%saveattach.asp%' and querystring like '%CampoAllegato_%&IDDOC=' + cast(@IdOfferta as varchar) + '%' )
							or 
							( paginaDiArrivo like '%saveattach.asp%' and paginaDiPartenza like'%CampoAllegato_%&IDDOC=' + CAST(@IdOfferta as varchar)  +' %' )
							or
							( paginaDiArrivo like '%UploadAttach.asp%' and browserUsato ='HASH' )
							or 
								
							( paginaDiArrivo like '%saveattach.asp%' and querystring like 'TRACE-INFO' and form like 'TerminatePage. QueryString:OPERATION=INSERT&%IDDOC=' + cast(@IdOfferta as varchar) + '%' )
							
							or 
							( paginaDiArrivo like '%document.asp%' and  querystring like '%' + CAST(@IdOfferta as varchar)  + '%'  and dbo.getvalue('COMMAND',querystring ) <> '' )
								or 
								( paginaDiArrivo like '%functions/field/UploadAttach.asp' and  querystring like  '%CampoAllegato_%' + CAST(@IdOfferta as varchar)  + '%' )
								--or 
								--( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  '%' + CAST(@IdOfferta as varchar)  + '%'  )
								or 
								( paginaDiArrivo like '%/proxy/1.0/uploadattach' and  querystring like  'TRACE-INFO' and cast(form as nvarchar(max)) <> '' )
							

						) order by datalog

			OPEN crsAllegatiTecnicaEconomica

			FETCH NEXT FROM crsAllegatiTecnicaEconomica INTO @querystring,@Form,@BrowserUsato

			WHILE @@FETCH_STATUS = 0
			BEGIN
				

				set @Comando = dbo.getvalue('COMMAND',@querystring )


				----se una CANCEllazione DI UNA RIGA
				----sulla griglia prodotti non si può fare
				--if @Comando ='DOCUMENTAZIONE.DELETE_ROW'
				--begin
				--	--dalla tabella di memoria elimino tutte le entrate con quella riga
				--	--e decremento le entrate che hanno la riga maggiore di quella cancellata
				--	set @IndRowCanc = dbo.getvalue('IDROW',@querystring )
					
				--	delete from #TempAttachMem where  riga = @IndRowCanc

				--	update #TempAttachMem
				--		set riga = riga -1 
				--			where riga > @IndRowCanc

				--end

				--occorre gestire quando si fa pulisci selezione su un campo allegato


				--nuovo allegato inserito
				if dbo.getvalue('FIELD',@querystring ) <> ''
				begin

					set @UploadOk = 0
					set @HashOk = 0
					set @JobComplete = 0
					set @Allegato = dbo.getvalue('FIELD',@querystring ) 

					--ricavo la riga ed il nome del campo
					set @TempString=''
					set @nPos = 0
					set @AttribCurr = ''
					set @BustaCurr=''
					--set @TempString = replace (@Allegato,'RDOCUMENTAZIONEGrid_','')
					set @TempString = @Allegato
					set @nPos =  charindex('_', @TempString)
					set @RowCurrString = left ( @TempString , @nPos -1 )

					set @RowCurr = replace (@RowCurrString,'R','')
					set @AttribCurr = right (@TempString, len (@TempString) - @nPos)

					--determino in quale busta si trova l'allegato TECNICA oppure ECONOMICA
					select @BustaCurr =busta from #AllegatiTecnicaEconomica where attributo = @AttribCurr

					if not exists(select * from #TempAttachMem where riga = @RowCurr and Attributo =@AttribCurr)
					begin
						insert into #TempAttachMem
							(Busta,riga,attributo)
							values
							(@BustaCurr,@RowCurr,@AttribCurr)
					end

				end
				
				if @Allegato <> '' and @querystring='TRACE-INFO'
				begin
					
					--controllo che ci sianole tracce per upload avvenuto con successo
					--Upload completato, richiesto il job per lavorare il file : #Cauzione.p7m# (93547)
					if @Form like 'Upload completato, richiesto il job per lavorare il file :%'
						set @UploadOk = 1
					--Calcolo hash binario completato--5ED8B52166F927F00133FC4040FC1D03D40E931030286C6270BA5677D0712F5C
					if @BrowserUsato='HASH'
						set  @HashOk = 1
					--checkprogress--Job d98e652a8c224b0cb_20201027142007767 Completato con successo
					if @Form like 'Job %Completato con successo%'
						set @JobComplete = 1

					--per la vecchia gestione
					if @Form like 'TerminatePage.%&FIELD=R%_campoallegato_%'
					begin
						set @UploadOk = 1
						set  @HashOk = 1
						set @JobComplete = 1
					end
							
				end	
				
						 
				if @Allegato <>'' and @UploadOk = 1 and @HashOk = 1 and @JobComplete = 1
				begin
					set @NumAllegatiInseriti = @NumAllegatiInseriti + 1
					set @Allegato=''
				end
				
				
				
				--se ho salvato oppure eseguito processi sull'offerta allora gli allegati sono statiresi persistenti
				if @NumAllegatiInseriti >0 and @Comando in ('SAVE','PROCESS')	
				begin
					
					set @nSave=1

				
					delete from #TempAttachDB 
					insert into #TempAttachDB 
						(busta,riga,attributo)
						select busta,riga,attributo from #TempAttachMem 
				end
									

				FETCH NEXT FROM crsAllegatiTecnicaEconomica INTO @querystring,@Form,@BrowserUsato
			END

			CLOSE crsAllegatiTecnicaEconomica 
			DEALLOCATE crsAllegatiTecnicaEconomica 


			--select * from #TempAttachMem  --where busta ='TECNICA'
			--select * from #TempAttachDB   --where busta ='ECONOMICA'
		
			select @NumAllegatiTecnica = count(*) 
				from #TempAttachDB where busta ='TECNICA'
			select @NumAllegatiEconomica = count(*) 
				from #TempAttachDB where busta ='ECONOMICA'

			select @NumAllegatiTecnica as  'ALLEGATI INSERITI E SALVATI BUSTA TECNICA' 
					, @NumAllegatiEconomica as 'ALLEGATI INSERITI E SALVATI BUSTA ECONOMICA' 
		END


		if @STEP=6
		BEGIN
			
			--3.3 BUSTE FIRMATE
			--select 
			--	dbo.getvalue('FIELD',querystring ) as Allegato, dbo.getvalue('BUSTA',querystring ) as BUSTA, dbo.getvalue('PROCESS_PARAM',querystring )as Processo,  * 
			--	from 
			--		CTL_LOG_UTENTE_LAVORO  with (nolock)
			--	where  
			--		idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza
			--		and
			--			(
			--				( paginaDiArrivo like '%pdf.asp%' and querystring like '%IDDOC=' + CAST(@IdOfferta as varchar)  + '%BUSTA=BUSTA_%' )
			--				or 
			--				( paginaDiArrivo like '%pdf_stamp.asp%' and querystring like '%FILE-PATH=%' + CAST(@IdPfu as varchar)  + '%' )
			--				or 
			--				( paginaDiArrivo like '%Signed.asp%' and querystring like '%IDDOC=' + CAST(@IdOfferta as varchar)  + '%AREA=F%' )
			--				or 
			--				( paginaDiArrivo like '%document.asp%' and  querystring like '%IDDOC=' + CAST(@IdOfferta as varchar)  + '%' and dbo.getvalue('COMMAND',querystring ) <> '' )
			--			)
			--order by datalog

			--se monolotto 
			if @DivisioneLotti = 0
			 
				select * from ctl_doc_sign with (nolock) where idheader = @IdOfferta
			
			else
			--se multilotto 
				select 
					 DO.Numerolotto,Firme.* 
					from 
						document_microlotti_dettagli DO with (nolock) 
							left join Document_Microlotto_Firme  Firme with (nolock) on Firme.idHeader = DO.id
					where DO.idheader = @IdOfferta and TipoDoc in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE') and voce =0  order by cast(Numerolotto as int)

		END

		if @STEP=7
		begin

			-------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------2. ERRRORI TRACCIATI NEL LOG--------------------------------------------------------------------------
			-------------------------------------------------------------------------------------------------------------------------------------------
			--select 'ERRRORI TRACCIATI NEL LOG'
			select 
				datalog as Data , descrizione as Nodo ,form as DettaglioErrore  
				from 
					CTL_LOG_UTENTE_LAVORO with (nolock) 
				where idpfu = @IdPfu and datalog >=@DataCreazione and datalog <=@DataScadenza	and querystring like '%ERROR%' order by datalog

		end
		if @STEP=8
		begin
		
			--recupero gli allegati richiesti nella busta tecnica 
			--select 'ALLEGATI RICHIESTI BUSTA TECNICA\ECONOMICA'

			select @idModelloGara=id 
				from 
					CTL_DOC with (nolock) 
				where LinkedDoc = @IdBando and TipoDoc='config_modelli_lotti' and Deleted=0
		
				select 
					T.DZT_Name as 'BUSTA', 
						count(t1.value) as 'ALLEGATI RICHIESTI'
					--T1.Value as 'Attributo', 
					--T2.Value as 'Descrizione' 

						from CTL_DOC_Value T with (nolock) 
							inner join CTL_DOC_Value T1 with (nolock) on T1.idheader = T.IdHeader and T1.Row=T.row and T1.DZT_Name ='DZT_Name'
							inner join CTL_DOC_Value T2 with (nolock) on T2.idheader = T.IdHeader and T2.Row=T.row and T2.DZT_Name ='descrizione'
							inner join LIB_Dictionary L on L.DZT_Name =  T1.Value and L.DZT_Type = 18
						where T.IdHeader = @idModelloGara
							and T.DZT_Name = 'MOD_OffertaTec'
							and T.Value='obblig' 
							group by T.DZT_Name
							--order by T.DZT_Name desc
				
		end
	end
	else
	begin
		select 'il documento non è una OFFERTA' as Esito
	end
end









GO
