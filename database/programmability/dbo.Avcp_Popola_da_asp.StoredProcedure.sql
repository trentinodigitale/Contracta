USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Avcp_Popola_da_asp]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








--Versione=1&data=2014-02-10&Attivita=51444&Nominativo=Leone
--Versione=2&data=2016-10-11&Attivita=124907&Nominativo=Leone
CREATE PROCEDURE [dbo].[Avcp_Popola_da_asp] 
( 
	@codiceEstrazione varchar(100),		-- Chiave univoca per l'operazione di import
	@id_da_elaborare_start int = NULL,  --	NULL Se è la prima invocazione e quindi va effettuato il popolamento della tabella di import
										--      , avvalorato se è dalla 2a invocazione in avanti per importare nelle tab avcp lotto/gara singolarmente
	@id_da_elaborare_end int = NULL,	-- in coppia con il parametro @id_da_elaborare_start indica il range di record che si vuole importare
	@annoDiEstrazione int = NULL,  
	@idAziMittenti varchar(4000) = NULL 
	
)
AS
BEGIN

	--declare @codiceEstrazione varchar(100)
	--declare @id_da_elaborare_start int
										
	--declare @id_da_elaborare_end int
	--declare @annoDiEstrazione int
	--declare @idAziMittenti varchar(4000)

	--set @codiceEstrazione = '926123482'
	--set @id_da_elaborare_start = NULL
	--set @id_da_elaborare_end = NULL
	--set @annoDiEstrazione = 2012 
	--set @idAziMittenti = '35154854'
      
      -- SET XACT_ABORT ON
      -- begin tran

      DECLARE @debug int
      set @debug = 0

      --if @debug = 0
            --SET NOCOUNT on
            --SET ANSI_WARNINGS OFF

            /*
      DECLARE @annoDiEstrazione int   
      DECLARE @idAziMittenti varchar(4000)
      set @annoDiEstrazione  = NULL
      set @idAziMittenti  = NULL
      drop table #avcp_import_bandi

      */

	  declare @importoAggiudicato FLOAT = 0


	  IF isnull(@codiceEstrazione,'') = ''
	  BEGIN
			RAISERROR ('Parametro codiceEstrazione obbligatorio - %s',16,1, 'Avcp_Popola_da_asp')
			return 
	  END

	  IF not @id_da_elaborare_start is null and @id_da_elaborare_end is null 
	  BEGIN	
	  		RAISERROR ('Se passato @id_da_elaborare_start è obbligatorio anche @id_da_elaborare_end ',16,1)
			return 	
	  END

      declare @whereCondition varchar(1000)

      -- Le gare che mi restituisce la vista dei vecchi bandi sono : 
      --    * APERTE
      --    * ASTE
      --    * Tradizionali (cartacee)
      --    * Ristrette nella fase ad INVITO
      --    * Negoziate nella fase INVITO
	  --drop table #avcp_import_bandi

	IF NOT EXISTS (
						SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
							WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='avcp_import_bandi') 
	BEGIN

			--drop table avcp_import_bandi

			  CREATE TABLE avcp_import_bandi(
				  [Id] [int] IDENTITY(1,1) NOT NULL,
				  codiceEstrazione [varchar](100) collate DATABASE_DEFAULT,
				  idMsg [int] NOT NULL,        
				  tipodoc [varchar](1000) collate DATABASE_DEFAULT NULL,
				  statoFunzionale [varchar](500) collate DATABASE_DEFAULT NULL,
				  deleted [int] NULL,
				  JumpCheck [varchar](250) collate DATABASE_DEFAULT NULL,
				  data [datetime] NULL,
				  PrevDoc [int] NULL,
				  Fascicolo [varchar](500) collate DATABASE_DEFAULT NULL,
				  Versione [int] NULL,
				  LinkedDoc [int] NULL,
				  Oggetto [nvarchar](4000) collate DATABASE_DEFAULT NULL,
				  Note [varchar](1000) collate DATABASE_DEFAULT NULL,
				  Anno [int] NULL,
				  Cig [varchar](4000) collate DATABASE_DEFAULT NULL,
				  CFprop [varchar](1000) collate DATABASE_DEFAULT NULL,
				  Denominazione [varchar](1000) collate DATABASE_DEFAULT NULL,
				  Scelta_contraente  [varchar](250) collate DATABASE_DEFAULT NULL,
				  ImportoAggiudicazione [float] NULL,
				  DataInizio  [datetime] NULL,
				  Datafine [datetime] NULL,
				  ImportoSommeLiquidate  [float] NULL,
				  TipoBando [int] NULL,
				  iddoc [varchar](50) collate DATABASE_DEFAULT NULL,
				  AziendaMittente [int] NULL,
				  DtPubblicazione [datetime] NULL,
				  TipoProcedura [varchar](15) collate DATABASE_DEFAULT NULL,
				  iSubType [int] NULL,
				  origine [varchar](15) collate DATABASE_DEFAULT NULL,
				  CigAusiliare [varchar](500) collate DATABASE_DEFAULT NULL,
				  divisioneInLotti [varchar](2) collate DATABASE_DEFAULT NULL,
				  TipoDocBando [varchar](200) collate DATABASE_DEFAULT NULL,
				  CigOriginale [varchar](4000) collate DATABASE_DEFAULT NULL,
				  pesoGara int NULL,
				  importato tinyint default(0),
				  idPfuInCharge int NULL,
				  idAziEnteImport int NULL
			  )
			  
			  create index IX_MSG ON avcp_import_bandi ( idmsg )

	END

	
	-- Se la pagina ASP sta richiedendo alla stored il popolamento iniziale della tabella avcp_import_bandi
	IF ISNULL(@id_da_elaborare_start,'') = ''
	BEGIN

		  ---- Aggiungo come condizione il recupero di tutti i bandi dall'anno corrente a dicembre 2012 se l'intervallo
		  ---- temporale non supera 5 anni. altrimenti dall'anno corrente a 5 anni in meno.

		  if not isnull(@annoDiEstrazione,'') = ''
		  BEGIN
			  set @whereCondition = ' and datepart(year,DtPubblicazione) = ''' + cast(@annoDiEstrazione as varchar) + ''''
		  END
		  ELSE
		  BEGIN
			  set @whereCondition = ' and convert(varchar(7),DtPubblicazione, 121) >= ''2012-12'' and ( datepart(year,getdate()) - datepart(year,DtPubblicazione) ) <= 5 '
		  END

		  if not isnull(@idAziMittenti,'') = ''
		  BEGIN

				declare @codiceFiscale varchar(250) 
				declare @listaAzi varchar(8000)
				
				set @codiceFiscale = ''
				select @codiceFiscale = vatValore_FT from  Dm_Attributi dm with(nolock) where dm.lnk = @idAziMittenti and dm.dztnome = 'codicefiscale' 
				
				if @codicefiscale <> ''
				begin
					set @listaAzi  = dbo.GetIdAzi_from_CodiceFiscale( @codiceFiscale )
					set @whereCondition = @whereCondition + ' and AziendaMittente IN ( select * from dbo.split(''' + @listaAzi + ''' ,'','' ) ) '
				end 
				else
				begin
					set @whereCondition = @whereCondition + ' and AziendaMittente = ' + @idAziMittenti
				end 

		  END

		  exec ('
		  select * into #temp from AVCP_BandiDocGen where 1=1 ' + @whereCondition + ' 
		  INSERT INTO avcp_import_bandi ( 
			  codiceEstrazione,
			  idAziEnteImport,
			  idMsg,
			  tipodoc,
			  statoFunzionale,
			  deleted,
			  JumpCheck,
			  data,
			  PrevDoc,
			  Fascicolo,
			  Versione,
			  LinkedDoc,
			  Oggetto,
			  Note,
			  Anno, 
			  Cig,
			  CFprop, 
			  Denominazione, 
			  Scelta_contraente, 
			  ImportoAggiudicazione, 
			  DataInizio, 
			  Datafine, 
			  ImportoSommeLiquidate,
			  TipoBando,
			  idDoc,
			  AziendaMittente,
			  DtPubblicazione,
			  TipoProcedura,
			  iSubType,
			  origine,
			  CigAusiliare,
			  divisioneInLotti,
			  TipoDocBando 
			  )
		  SELECT ''' + @codiceEstrazione + ''' as codiceEstrazione, 
				' + @idAziMittenti + ' as idAziEnteImport,
				    idmsg,
					CASE WHEN divisioneInLotti <> ''0'' THEN ''AVCP_GARA''
					ELSE ''AVCP_LOTTO''
					END AS tipodoc,              
					''Pubblicato'',0,'''', DtScadenzaBandoTecnical,NULL,NULL,NULL,NULL,
				  Oggetto,'''',datepart(year,DtPubblicazione),
					case when isnull(cig,'''') = '''' then ''INT-'' + CigAusiliare
						  else cig 
					end as CIG,
					CFenteProponente,
					DenominazioneEnteProponente,
                  
					dbo.GetSceltaContraente ( tipodoc , CodTipoProcedura  ,TipoBando  , cast( Oggetto as varchar(8000)) )
						  AS Scelta_contraente, 
					--di_aggiudicazione,
					null as ImportoAggiudicazione,
					-- DtPubblicazione, non era correttoprendere DataInizio dalla data di pubblicazione
					DataInizio AS DataInizio, -- informazione non ancora gestita
					-- DtScadenzaBandoTecnical, 
					Datafine as Datafine, 
					null as ImportoSommeLiquidate,
					TipoBando , idDoc,      AziendaMittente,DtPubblicazione,
					TipoProcedura, iSubType, ''DOC_GEN'' as origine,CigAusiliare,divisioneInLotti
					,TipoDoc
			  FROM #temp ' )
      
      
		  ---- La vista AVCP_BandiCtl mi restitusce le gare a lotti del bando semplificato e del bando_gara ti tipo :
		  ---- * aperta
		  ---- * invito

		  exec('
		  INSERT INTO avcp_import_bandi ( 
			  codiceEstrazione,
			  idAziEnteImport,
			  idMsg,
			  tipodoc,
			  statoFunzionale,
			  deleted,
			  JumpCheck,
			  data,
			  PrevDoc,
			  Fascicolo,
			  Versione,
			  LinkedDoc,
			  Oggetto,
			  Note,
			  Anno, 
			  Cig,
			  CFprop, 
			  Denominazione, 
			  Scelta_contraente, 
			  ImportoAggiudicazione, 
			  DataInizio, 
			  Datafine, 
			  ImportoSommeLiquidate,
			  TipoBando,
			  idDoc,
			  AziendaMittente,
			  DtPubblicazione,
			  TipoProcedura,
			  iSubType,
			  origine,
			  CigAusiliare,
			  divisioneInLotti,
			  TipoDocBando 
		  )
		  SELECT ''' + @codiceEstrazione + ''' as codiceEstrazione, 
			' + @idAziMittenti + ' as idAziEnteImport,
			  idmsg, 
			  CASE WHEN divisioneInLotti <> ''0'' THEN ''AVCP_GARA''
					ELSE ''AVCP_LOTTO''
			  END AS tipodoc,              
			  ''Pubblicato'',0,'''', DtScadenzaBandoTecnical,NULL,NULL,NULL,NULL,
			  Oggetto,'''',datepart(year,DtPubblicazione),
			  case when isnull(cig,'''') = '''' then ''INT-'' + CigAusiliare
					else cig 
			  end as CIG,
			  CFenteProponente,
			  DenominazioneEnteProponente,
			  dbo.GetSceltaContraente ( tipodoc , CodTipoProcedura  ,TipoBando  , cast( Oggetto as varchar(8000)) )
				AS Scelta_contraente, 
			  di_aggiudicazione,
			  -- DtPubblicazione, non era correttoprendere DataInizio dalla data di pubblicazione
			  DataInizio AS DataInizio, -- informazione non ancora gestita
			  -- DtScadenzaBandoTecnical, 
			  Datafine as Datafine, 
			  null as ImportoSommeLiquidate,
			  TipoBando , idDoc,      AziendaMittente,
			  DtPubblicazione,TipoProcedura, iSubType, ''DOC_CTL'' as origine,CigAusiliare,divisioneInLotti,TipoDoc
		  FROM AVCP_BandiCtl where 1=1 ' + @whereCondition )

		  ------------------------------------------------------------------
		  ----- RETTIFICO LA TABELLA TEMPORANEA DEI BANDI PER I CIG DUPLICATI
		  ------------------------------------------------------------------
		  DECLARE @origine varchar(15)

		  ----- Se sono presenti dei CIG duplicati
		  if exists (
						select cig
							from avcp_import_bandi with(nolock)
							where codiceEstrazione = @codiceEstrazione
							group by cig,tipodoc
									having count(*) > 1
					  )
		  BEGIN 

			  declare @tmpCig varchar(250)       
			  declare @progressivo INT
			  declare @tmpIdmsg INT

			  set @tmpCig = ''
			  set @tmpIdmsg = NULL
			  set @progressivo = 1

            
			  DECLARE curs CURSOR STATIC FOR     
					select idmsg,imp.cig,origine from avcp_import_bandi imp with(nolock)
						  INNER JOIN (
												 select cig FROM avcp_import_bandi with(nolock)
												 where codiceEstrazione = @codiceEstrazione
												 group by cig,tipodoc
												 having count(*) > 1
										   ) tmp ON imp.cig = tmp.cig


			  OPEN curs 
			  FETCH NEXT FROM curs INTO @tmpIdmsg,@tmpCig,@origine


			  WHILE @@FETCH_STATUS = 0   
			  BEGIN  

					update avcp_import_bandi SET
						  cig = 'DUPLICATO-' + cig + '-' +  cast(@progressivo as varchar)
						  , CigOriginale = cig
					where idmsg = @tmpIdmsg and origine = @origine and codiceEstrazione = @codiceEstrazione

					set @progressivo = @progressivo + 1

					FETCH NEXT FROM curs INTO @tmpIdmsg,@tmpCig,@origine

			  END  


			  CLOSE curs   
			  DEALLOCATE curs



		  END


		  -- Resetto i contatori se erano gia stati inseriti altrimenti li creo
		  IF exists ( select * from CTL_Counters with(nolock) where idAzi = @idAziMittenti and Name = 'AVCP-ADD' )
		  BEGIN
				-- Posso resettare i contatori per idazi senza problemi perchè
				-- sulla parte asp è presente un lock dell'operazione a parità di idAzi 
				update [CTL_Counters]
					set [Counter] = 0
				where idAzi = @idAziMittenti and Name in ('AVCP-ADD','AVCP-UPD','AVCP-LOK')
		  END
		  ELSE
		  BEGIN
				
				INSERT INTO CTL_Counters( idAzi,Name,Counter)
					VALUES (@idAziMittenti, 'AVCP-ADD', 0)

				INSERT INTO CTL_Counters( idAzi,Name,Counter)
					VALUES (@idAziMittenti, 'AVCP-UPD', 0)

				INSERT INTO CTL_Counters( idAzi,Name,Counter)
					VALUES (@idAziMittenti, 'AVCP-LOK', 0)

		  END

		  -- Esco dalla stored aspettando la chiamata successiva che mi indicherà
		  -- il range di record da elaborare

		  return 


    END -- fine id per verifica se è la prima operazione di import

      -- Elimino i documenti importati dalla stored ( con idpfu = -20 )
      --delete from Document_AVCP_Lotti where idHeader in ( select id from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_LOTTO' )
      --delete from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_LOTTO'

      --delete from Document_avcp_partecipanti where idHeader in ( select id from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_OE' )
      --delete from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_OE'

      --delete from Document_avcp_partecipanti where idHeader in ( select id from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_GARA' )
      --delete from ctl_doc where idpfu = -20 and tipodoc = 'AVCP_GARA'

      DECLARE @id INT
      --DECLARE @idmsg INT 
      DECLARE @iddoc VARCHAR(50)
      DECLARE @tipoBando varchar(50)
      DECLARE @idCtlDoc int
      DECLARE @aziMittente int
      DECLARE @idDocumentLotti int
      DECLARE @TipoProcedura VARCHAR(15)
      DECLARE @subType INT
      DECLARE @fascicolo varchar(200)
      DECLARE @oggetto varchar(4000)
      DECLARE @Protocollo varchar(50)
      
      declare @cfProponente varchar(200)
      declare @denominazioneProponente varchar(1000)
      declare @cig varchar(200)
      declare @versione varchar(100)
      declare @idHeader INT
      declare @divisioneInLotti VARCHAR(2)
      declare @TipoDocBando varchar(100)
      declare @cigOriginale varchar(200)
      declare @Scelta_contraente varchar(200)


      declare @tipodoc varchar(200)
      declare @statoFunzionale varchar(200)
      declare @JumpCheck varchar(200)
      declare @data datetime
      --declare @Fascicolo  varchar(200)
      --declare @Versione varchar(200)
      declare @LinkedDoc int
      declare @Note varchar(8000)
      declare @AziendaMittente int

      declare @Anno           int
      declare @ImportoAggiudicazione  float
      declare @DataInizio datetime
      declare @Datafine datetime
      declare @ImportoSommeLiquidate float


      declare @dtPubblicazione datetime
	  declare @CigAusiliare varchar(400)

	  declare @idImport INT

      -----------------------------------------------------------------
      -- ciclo su tutti i bandi per creare i documenti in AVCP
      -----------------------------------------------------------------

      DECLARE db_cursor CURSOR STATIC FOR 
            SELECT  idmsg,iddoc,tipobando,TipoProcedura,iSubType,
                        origine,oggetto,AziendaMittente,CFprop,
                        Denominazione,CIG, divisioneInLotti, TipoDocBando,CigOriginale,DtPubblicazione , Scelta_contraente
                        ,tipodoc,statoFunzionale,JumpCheck,data,
                        LinkedDoc,Note ,AziendaMittente
                        ,Anno , ImportoAggiudicazione ,DataInizio, Datafine , ImportoSommeLiquidate,CigAusiliare, Id
                  FROM  avcp_import_bandi with(nolock) 
				  where id >= @id_da_elaborare_start and id <= @id_da_elaborare_end and codiceEstrazione = @codiceEstrazione and importato = 0

      OPEN db_cursor 

      FETCH NEXT FROM db_cursor INTO @id, @iddoc, @tipobando, @TipoProcedura, 
                                                  @subType, @origine, @oggetto,@aziMittente,  
                                                  @cfProponente,@denominazioneProponente, @cig,
                                                  @divisioneInLotti,@TipoDocBando,@cigOriginale,@dtPubblicazione , @Scelta_contraente
                                                     ,@tipodoc,@statoFunzionale,@JumpCheck,@data,
                                                     @LinkedDoc,@Note ,@AziendaMittente
                                                     ,@Anno , @ImportoAggiudicazione , @DataInizio, @Datafine , @ImportoSommeLiquidate
													 ,@CigAusiliare,@idImport


      WHILE @@FETCH_STATUS = 0   
      BEGIN   

            -----------------------------------
            ---- INSERISCO LE GARE
            -----------------------------------
   
            if @debug = 1
            begin
                  print 'Gara ' + cast(@id as varchar)
                  --print ' dbo.Avcp_Inserisco_Aggiorno_CIG( isnull(' + isnull(@cigOriginale,'NULL') + ',' + @cig + ')  )'
            end

				
            -----------------------------------------------------------------
            -- Per ogni bando inserisco i dati nella ctl_doc e nella document_avcp_lotti
            -----------------------------------------------------------------

            -- Se devo inserire una nuova entità ( verifico in base al cig )
            IF ( dbo.Avcp_Inserisco_Aggiorno_CIG( @cig, @tipodoc ) = 1 )
            BEGIN

                  if @debug = 1
                        print 'inserisco/aggiorno la gara ' +  cast(@id as varchar) + ' con cig ' + @cig

                  SET @versione = ''

                  SELECT TOP 1 @versione = versione, @idHeader=idHeader 
                        FROM Document_AVCP_Lotti lotti with(nolock)
                             INNER JOIN Ctl_doc doc with(nolock) ON doc.id = lotti.idheader and doc.tipodoc = @tipodoc
                        WHERE cig = @cig
						ORDER BY DOC.ID DESC

                  IF @versione <> '' 
                  BEGIN
                        
                        if @debug = 1
                        begin
                             print 'Per la gara ' +  cast(@id as varchar) + ' con cig ' + @cig + ' era gia presente nel sistema. cancello la vecchia '
                              print 'Cancello dalla ctl_doc con id = ' + cast(@idHeader as varchar) 
                             print 'e cancello dalla Document_AVCP_Lotti con idHeader = ' + cast(@idHeader as varchar) 
                        end

						-- Incremento il contatore di aggiornamento bandi
						update [CTL_Counters]
							set [Counter] = [Counter] + 1
						where idAzi = @idAziMittenti and Name in ('AVCP-UPD')

						  If @@error <> 0 
						  Begin
								--Rollback transaction
								CLOSE db_cursor   
								DEALLOCATE db_cursor
								return
						  end


                        -- Cancello la versione precedente del documento
                        DELETE FROM CTL_DOC WHERE id = @idHeader
                        DELETE FROM Document_AVCP_Lotti WHERE idHeader = @idHeader

                  END
				  ELSE
				  BEGIN
						-- Incremento il contatore dei bandi aggiunti
						update [CTL_Counters]
							set [Counter] = [Counter] + 1
						where idAzi = @idAziMittenti and Name in ('AVCP-ADD')
				  END

                  If @@error <> 0 
                  Begin
                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return
                  end


                  -----------------------------------------------------------------
                  -- Inserisco il record della gara
                  -----------------------------------------------------------------
                  INSERT INTO ctl_doc (tipodoc,statoFunzionale,deleted,JumpCheck,data
                                              ,PrevDoc,Fascicolo,Versione,LinkedDoc,Note,idpfu,Azienda)
                        values( @tipodoc,@statoFunzionale,0,     @JumpCheck,@data,
                                               0,         '',   '',@LinkedDoc,@Note ,-20,@AziendaMittente )

                        --SELECT             tipodoc,statoFunzionale,0, JumpCheck,data,
                        --                      0,         Fascicolo,  Versione,LinkedDoc,Note ,-20,AziendaMittente
                        --    FROM  #avcp_import_bandi 
                        --    WHERE idMsg = @id and origine = @origine

                             

                  If @@error <> 0 
                  Begin
                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return
                  end

                  IF @versione = '' 
                  BEGIN

                        if @debug = 1
                             print 'versione uguale a '''' prendo le informazioni dal recorda appena inserito'

                        SET @idCtlDoc = SCOPE_IDENTITY()
                        set @versione = @idCtlDoc
                        SET @fascicolo = 'AVCP-' + cast(@idCtlDoc as varchar ) 
                  END
                  ELSE
                  BEGIN

                        if @debug = 1
                             print 'versione uguale a ''' + @versione + ''' quindi idCtlDoc = ' + cast(@idHeader as varchar)

                        SET @idCtlDoc = SCOPE_IDENTITY()
                        SET @fascicolo = 'AVCP-' + cast(@versione as varchar ) 
                  END

                  -- Invoco la stored che mi restituisce un protocollo per il documento appena creato
                  --EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

                                         
                  if @debug = 1
                  begin
                        print 'Per la gara ' +  cast(@id as varchar) + ' con cig ' + @cig + ' Aggiorno le info sulla ctl_doc '
                        print ' versione : ' + @versione
                        print ' Fascicolo : ' + @fascicolo
                        print ' Protocollo : ' + @Protocollo
                        print ' WHERE id = ' + cast(@idCtlDoc as varchar)
                  end
                  

                  -- Aggiorno versione e fascicolo perchè dipendenti dall'id tabellare appena generato
					UPDATE ctl_doc 
						SET versione = @versione ,
						    Fascicolo = @fascicolo,
						    Protocollo = @Protocollo
						WHERE id = @idCtlDoc 

                  If @@error <> 0 
                  Begin
                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return
                  end
				  

                  --Avvaloro la tabella dei lotti avcp
                  INSERT INTO Document_AVCP_Lotti(Oggetto,idHeader,Anno, Cig,CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, 
                                                                 DataInizio,Datafine,ImportoSommeLiquidate,DataPubblicazione      )

                                                     values( left(isnull(@oggetto,''), 250),@idCtlDoc,@Anno,@cig,@cfProponente, @denominazioneProponente, @Scelta_contraente, @ImportoAggiudicazione, 
                                                               @DataInizio, @Datafine, @ImportoSommeLiquidate,@dtPubblicazione )

                             --SELECT                           Oggetto,@idCtlDoc,Anno,@cig,CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, 
                             --                               DataInizio, Datafine, ImportoSommeLiquidate,DtPubblicazione
                             --    FROM  #avcp_import_bandi 
                             --    WHERE idMsg = @id and origine = @origine

                  If @@error <> 0 
                  Begin
                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return
                  end

            END
            ELSE
            BEGIN

                  -----------------------------------------------------------------
                  -- altrimenti recuperiamo il riferimento della gara già presente
                  -- nell'eventualità è necessario collegare i lotti
                  -----------------------------------------------------------------
                                   
                  if @debug = 1
                        print 'Non aggiorno/inserisco la gara ' +  cast(@id as varchar) + ' con cig ' + @cig + ' '

                  set @versione = ''

                  SELECT TOP 1 @idCtlDoc = id , @fascicolo = fascicolo, @versione = versione
                        FROM ctl_doc doc with(nolock)
                             INNER JOIN Document_AVCP_Lotti lotti with(nolock) ON doc.id = lotti.idHeader
                        WHERE cig = @cig and doc.deleted = 0 and doc.tipodoc IN ('AVCP_GARA', 'AVCP_LOTTO') and StatoFunzionale = 'Pubblicato'
						ORDER BY DOC.ID DESC

                  If @@error <> 0 
                  Begin
                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return
                  end

					-- Incremento il contatore dei bandi non toccati
					update [CTL_Counters]
						set [Counter] = [Counter] + 1
					where idAzi = @idAziMittenti and Name in ('AVCP-LOK')

            END

            -----------------------------------------------------------------
            -- Se il bando in esame è in lotti verifichiamo la necessita di 
            -- inserire o modificare i singoli lotti del bando corrente
            -----------------------------------------------------------------
            IF @divisioneInLotti <> '0'
            BEGIN
                  
                  if @debug = 1
                        print 'La gara ' +  cast(@id as varchar) + ' con cig ' + @cig + ' è in lotti '


                  DECLARE @tabId INT
                  DECLARE @Prot varchar(50)
                  DECLARE @idLotto INT

                  -- Travaso i lotti della gara multiLotto in una tabella temporanea
                  if exists (
                             select  * from tempdb.dbo.sysobjects o
                                   where o.xtype in ('U') and o.id = object_id(N'tempdb..#import_lotti')
                        )
                  begin
                        DROP TABLE #import_lotti
                  end

                  CREATE TABLE #import_lotti
                  (
                        id [INT] NULL,                     
                        Oggetto [varchar](4000) collate DATABASE_DEFAULT NULL,
                        Cig [varchar](200) collate DATABASE_DEFAULT NULL,
                        DtPubblicazione [datetime] null
                  )

                  IF @origine = 'DOC_GEN'
                  BEGIN

					-- se cig del lotto è null o stringa vuota, come fatto per le gare
					-- creerò un cig così : INT-PROTOCOLLOGARA-NUMEROLOTTO

                        INSERT INTO #import_lotti ( id,Oggetto,cig )   
                             SELECT a.id, @oggetto + ' - ' + descrizione as oggetto, coalesce( nullif(cig,'')  , 'INT-' + @CigAusiliare + '-' + isnull( nullif(NumeroLotto,'') ,'0')   )
                                   from document_microlotti_dettagli a	with(nolock)									
							 WHERE idHeader = @id and voce = 0 and a.TipoDoc = @TipoDocBando

                  END
                  ELSE
                  BEGIN

                        INSERT INTO #import_lotti ( id,Oggetto,cig )   
                             SELECT b.id, @oggetto + ' - ' + descrizione as oggetto,  coalesce( nullif(cig,'')  , 'INT-' + @CigAusiliare + '-' + isnull( nullif(NumeroLotto,'') ,'0')   )      
                                   from document_microlotti_dettagli a with(nolock)
                                               inner join ctl_doc b with(nolock) ON b.id = a.idHeader
                             WHERE idHeader = @id and voce = 0 and b.TipoDoc = @TipoDocBando and a.tipodoc = @TipoDocBando


                  END

                  DECLARE @cigLotto varchar(800)
                  DECLARE @OggettoLotto varchar(8000)
                  DECLARE @versioneLotto varchar(100)
                  DECLARE @idHeaderLotto INT


                  -----------------------------------------------------------------
                  -- CICLO SU TUTTI I LOTTI DELLA GARA
                  -----------------------------------------------------------------

                  DECLARE db3_cursor CURSOR STATIC FOR     
                        SELECT id, cig , Oggetto FROM #import_lotti

                  OPEN db3_cursor 
                  
                  FETCH NEXT FROM db3_cursor INTO @tabId, @cigLotto , @OggettoLotto

                  WHILE @@FETCH_STATUS = 0   
                  BEGIN  

                        if @debug = 1
                             print 'Mi trovo sul lotto ' + cast(@tabId as varchar) + ' con cigLotto ' + @cigLotto

                        -----------------------------------
                        ---- INSERISCO I LOTTI DELLA GARA
                        -----------------------------------

                        IF ( dbo.Avcp_Inserisco_Aggiorno_CIG(@cigLotto, @tipodoc) = 1 )
                        BEGIN

                             if @debug = 1
                                   print 'Inserisco/aggiorno il lotto ' + cast(@tabId as varchar) + ' con cigLotto ' + @cigLotto

                             SET @versioneLotto = ''

                             -----------------------------------------------------------------
                             -- verifico se il lotto era già presente, in tal caso deve essere rimosso per reinserirlo
                             -----------------------------------------------------------------
                             SELECT TOP 1 @versioneLotto = versione, 
										  @idHeaderLotto=idHeader 
                                   FROM Document_AVCP_Lotti lotti with(nolock)
                                         INNER JOIN Ctl_doc doc with(nolock) ON doc.id = lotti.idheader and doc.tipodoc = 'AVCP_LOTTO'
                                   WHERE lotti.Cig = @cigLotto and doc.deleted = 0
								   ORDER BY DOC.ID DESC


                             IF @versioneLotto <> '' 
                             BEGIN

                                   if @debug = 1
                                         print 'Il lotto ' + cast(@tabId as varchar) + ' con cigLotto ' + @cigLotto + ' era gia presente, lo cancello'

									select lotti.Idrow into #tmp_id_to_del 
											FROM Document_AVCP_Lotti lotti  with(nolock)
													INNER JOIN Ctl_doc doc with(nolock) ON doc.id = lotti.idheader and doc.tipodoc = 'AVCP_LOTTO'
											WHERE lotti.Cig = @cigLotto and doc.deleted = 0

									-- Cancello la versione precedente del documento
								   DELETE FROM CTL_DOC WHERE ID IN ( select idheader from Document_AVCP_Lotti with(nolock) where cig = @cigLotto and tipodoc = 'AVCP_LOTTO' )
								   DELETE FROM Document_AVCP_Lotti where idrow in ( select idrow from #tmp_id_to_del )

								   drop table #tmp_id_to_del

                                   --DELETE FROM CTL_DOC WHERE id = @idHeaderLotto
                                   --DELETE FROM Document_AVCP_Lotti WHERE idHeader = @idHeaderLotto

									-- Incremento il contatore di aggiornamento bandi
									update [CTL_Counters]
										set [Counter] = [Counter] + 1
									where idAzi = @idAziMittenti and Name in ('AVCP-UPD')

                             END
							 ELSE
							 BEGIN
									-- Incremento il contatore dei bandi aggiunti
									update [CTL_Counters]
										set [Counter] = [Counter] + 1
									where idAzi = @idAziMittenti and Name in ('AVCP-ADD')
							 END

                             If @@error <> 0 
                             Begin

                                   --Rollback transaction
                                   CLOSE db_cursor   
                                   DEALLOCATE db_cursor
                                   CLOSE db3_cursor
                                   DEALLOCATE db3_cursor

                                   return
                             end


                             -----------------------------------------------------------------
                             -- Creo il documento per il lotto
                             -----------------------------------------------------------------
                             INSERT INTO ctl_doc (
                                         tipodoc,
                                         statoFunzionale,
                                         deleted,
                                         JumpCheck,
                                         data,
                                         PrevDoc,
                                         Fascicolo,
                                         Versione,
                                         LinkedDoc,
                                         Note,
                                         idpfu,
                                         Azienda
                                   )
                                   SELECT 
                                         'AVCP_LOTTO' AS tipodoc,
                                         'Pubblicato' as statoFunzionale,
                                         0,
                                         '' as JumpCheck,
                                         getdate() as data,
                                         0,
                                         '',
                                         '',
                                         @versione as LinkedDoc, -- linkedoc uguale alla versione del gruppo/gara
                                         '' as Note ,
                                         -20,
                                         @aziMittente as AziendaMittente
                                   --FROM #import_lotti 
                                   --where id = @tabId

                             If @@error <> 0 
                             Begin

                                   --Rollback transaction
                                   CLOSE db_cursor   
                                   DEALLOCATE db_cursor
                                   CLOSE db3_cursor
                                   DEALLOCATE db3_cursor

                                   return
                             end

                             declare @idCTLDOClotto INT
                             declare @fascicoloLotto varchar(200)

                             IF @versioneLotto = '' 
                             BEGIN
                                   SET @idCTLDOClotto = SCOPE_IDENTITY()
                                   set @versioneLotto = @idCTLDOClotto
                                   SET @fascicoloLotto = 'AVCP-' + cast(@idCTLDOClotto as varchar ) 
                             END
                             ELSE
                             BEGIN
                                   SET @idCTLDOClotto = SCOPE_IDENTITY()
                                   SET @fascicoloLotto = 'AVCP-' + cast(@versioneLotto as varchar ) 
                             END

                             -- Invoco la stored che mi restituisce un protocollo per il documento appena creato
                             --exec ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

                             if @debug = 1
                             begin
                                   print 'Per il lotto  ' +  cast(@tabid as varchar) + ' con cig ' + @cigLotto + ' Aggiorno le info sulla ctl_doc '
                                   print ' versione : ' + @versioneLotto
                                   print ' Fascicolo : ' + @fascicoloLotto
                                   print ' Protocollo : ' + @Protocollo
                                   print ' WHERE id = ' + cast(@idCTLDOClotto as varchar)
                             end
                  

                             -- Aggiorno versione e fascicolo perchè dipendenti dall'id tabellare appena generato
                             UPDATE ctl_doc
                                   SET versione = @versioneLotto ,
                                   Fascicolo = @fascicoloLotto,
                                   Protocollo = @Protocollo
                              where id = @idCTLDOClotto 

                             If @@error <> 0 
                             Begin

                                   --Rollback transaction
                                   CLOSE db_cursor   
                                   DEALLOCATE db_cursor
                                   CLOSE db3_cursor
                                   DEALLOCATE db3_cursor

                                   return
                             end

                             INSERT INTO Document_AVCP_Lotti(
                                   Oggetto,
                                   idHeader,
                                   Cig,
                                   CFprop, 
                                   Denominazione, 
                                   Scelta_contraente,
                                   DataPubblicazione,
								   anno
                             )
                             SELECT 
                                   left( isnull(@OggettoLotto,'') + ' - ' + isnull(@oggetto,'')   , 250),
                                   @idCTLDOClotto,
                                   @cigLotto,
                                   @cfProponente,
                                   @denominazioneProponente,
                                   @Scelta_contraente,
                                   @dtPubblicazione,
								   datepart(year, @dtPubblicazione)
                             --FROM #import_lotti where id = @tabId

                             If @@error <> 0 
                             Begin

                                   --Rollback transaction
                                   CLOSE db_cursor   
                                   DEALLOCATE db_cursor
                                   CLOSE db3_cursor
                                   DEALLOCATE db3_cursor

                                   return
                             end

							 set @idHeaderLotto = SCOPE_IDENTITY()

                        END
                        ELSE
                        BEGIN

                             -----------------------------------------------------------------
                             -- altrimenti se il lotto non è necessario crearlo
                             -- recupero le versioni e il fascicolo per eventualmente aggiornare 
                             -- i partecipanti
                             -----------------------------------------------------------------
                             if @debug = 1
                                   print 'Lotto ' + cast(@tabId as varchar) + ' con cigLotto ' + @cigLotto + ' non da inserire/aggiornare'


							-- Incremento il contatore dei bandi non toccati
							update [CTL_Counters]
								set [Counter] = [Counter] + 1
							where idAzi = @idAziMittenti and Name in ('AVCP-LOK')


                             SELECT TOP 1 @versioneLotto = versione, 
										  @idHeaderLotto=idHeader,
										  @cigLotto = cig,
										  @fascicoloLotto = fascicolo
                                   FROM Document_AVCP_Lotti lotti with(nolock)
											INNER JOIN Ctl_doc doc with(nolock) ON doc.id = lotti.idheader 
                                    WHERE cig = @cigLotto and StatoFunzionale = 'Pubblicato' and doc.tipodoc =  'AVCP_LOTTO' and doc.deleted = 0 
									ORDER BY DOC.ID DESC
                                   
                             If @@error <> 0 
                             Begin

                                   --Rollback transaction
                                   CLOSE db_cursor   
                                   DEALLOCATE db_cursor
                                   CLOSE db3_cursor
                                   DEALLOCATE db3_cursor

                                   return
                             end

                        END

                        if @debug = 1
                             print 'Chiamo la stored per i partecipanti per i lotti'

						set @importoAggiudicato = 0

                        -----------------------------------------------------------------
                        -- Per ogni lotto popolo i relativi partecipanti
                        -----------------------------------------------------------------
                        exec Avcp_PopolaPartecipanti @cigLotto, @versioneLotto , @fascicoloLotto , @tabId,    @TipoDocBando , @TipoProcedura, 1, @idDoc, @importoAggiudicato output
                        
						UPDATE document_AVCP_lotti
								set ImportoAggiudicazione = @importoAggiudicato
							where idheader = @idCTLDOClotto

                        If @@error <> 0 
                        Begin

                             --Rollback transaction
                             CLOSE db_cursor   
                             DEALLOCATE db_cursor
                             CLOSE db3_cursor
                             DEALLOCATE db3_cursor

                             return
                        end

                        -----------------------------------------------------------------
                        -- esegue un controllo formale dei dati caricati
                        -----------------------------------------------------------------
                        EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @idCTLDOClotto

                        FETCH NEXT FROM db3_cursor INTO @tabId, @cigLotto , @OggettoLotto

                  END

                  

                  CLOSE db3_cursor    
                  DEALLOCATE db3_cursor 


            END 
            ELSE
            BEGIN
                  
                  
                  -- SE LA GARA NON E' A LOTTI

                  if @debug = 1
                        print 'La gara ' + cast(@id as varchar) + ' con cig ' + @cigOriginale + ' non è a lotti. chiamo la stored dei partecipanti. versione: ' + @versione

			      set @importoAggiudicato = 0

                  -- Se il cig era duplicato e quindi è avvallorata la colonna cigOriginale. userò quella essendo chiave per aflink
                  if not @cigOriginale is null
                        exec Avcp_PopolaPartecipanti @cigOriginale  , @versione , @fascicolo , @id, @TipoDocBando , @TipoProcedura, 0, @idDoc, @importoAggiudicato output
                  else
                        exec Avcp_PopolaPartecipanti @cig  , @versione , @fascicolo , @id, @TipoDocBando , @TipoProcedura, 0, @idDoc, @importoAggiudicato output

				  update document_AVCP_lotti
						set ImportoAggiudicazione = @importoAggiudicato						
					where idheader = @idCtlDoc

                  If @@error <> 0 
                  Begin

                        --Rollback transaction
                        CLOSE db_cursor   
                        DEALLOCATE db_cursor
                        return

                  end

                  -----------------------------------------------------------------
                  -- esegue un controllo formale dei dati caricati
                  -----------------------------------------------------------------
                  EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @idCtlDoc

            END

			
			-- IMPOSTO IL FLAG DI IMPORTATO AD 1 PER RIPRENDERE DA QUELLI ANCORA DA IMPORTARE IN CASO DI ERRORE
			UPDATE avcp_import_bandi
					set importato = 1
				where Id = @idImport

			FETCH NEXT FROM db_cursor INTO   @id, @iddoc, @tipobando, @TipoProcedura, 
                                                  @subType, @origine, @oggetto,@aziMittente,  
                                                  @cfProponente,@denominazioneProponente, @cig,
                                                  @divisioneInLotti,@TipoDocBando,@cigOriginale,@dtPubblicazione , @Scelta_contraente,
                                                  @tipodoc,@statoFunzionale,@JumpCheck,@data,
                                                  @LinkedDoc,@Note ,@AziendaMittente,
                                                  @Anno , @ImportoAggiudicazione , @DataInizio, @Datafine , @ImportoSommeLiquidate,
												  @CigAusiliare,@idImport

      END

      CLOSE db_cursor   
      DEALLOCATE db_cursor

      --If @@error <> 0 
      --Begin
      --    Rollback transaction
      --end
      --else
      --begin
      --    COMMIT TRANSACTION
      --end

            
      SET NOCOUNT OFF

END -- Fine stored





GO
