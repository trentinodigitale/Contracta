USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_Avcp_Popola_da_DOC_START]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[OLD2_Avcp_Popola_da_DOC_START] 
( 
	@idDoc int	
)
AS
BEGIN


	if exists( select id from CTL_DOC with(nolock) where id = @idDoc and StatoFunzionale = 'InLavorazione' )
	begin

		declare @codiceEstrazione varchar(100)		-- Chiave univoca per l'operazione di import
		declare @whereCondition varchar(max)
		declare @idAziMittenti varchar(100)
		declare @annoDiEstrazione varchar(10)
		


		-- recupero le informazioni per l'elaborazione
		select @codiceEstrazione = [GUID] , @annoDiEstrazione = NumeroDocumento , @idAziMittenti = azienda  from CTL_DOC with(nolock) where id = @idDoc



		  set @whereCondition = ' and datepart(year,DtPubblicazione) = ''' + cast(@annoDiEstrazione as varchar) + ''''

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


		--if exists (
	 --       select  * from tempdb.dbo.sysobjects o
	 --               where o.xtype in ('U') and o.id = object_id(N'tempdb..#avcp_import_bandi')
		--)
		--begin
	 --       DROP TABLE #avcp_import_bandi
		--end






		CREATE TABLE #avcp_import_bandi(
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
					  Oggetto [nvarchar](max) collate DATABASE_DEFAULT NULL,
					  Note [varchar](max) collate DATABASE_DEFAULT NULL,
					  Anno [int] NULL,
					  Cig [varchar](4000) collate DATABASE_DEFAULT NULL,
					  CFprop [varchar](1000) collate DATABASE_DEFAULT NULL,
					  Denominazione [varchar](max) collate DATABASE_DEFAULT NULL,
					  Scelta_contraente  [varchar](250) collate DATABASE_DEFAULT NULL,
					  ImportoAggiudicazione [float] NULL,
					  DataInizio  [datetime] NULL,
					  Datafine [datetime] NULL,
					  ImportoSommeLiquidate  [float] NULL,
					  TipoBando [int] NULL,
					  iddoc [varchar](50) collate DATABASE_DEFAULT NULL,
					  AziendaMittente [int] NULL,
					  DtPubblicazione [datetime] NULL,
					  TipoProcedura [varchar](100) collate DATABASE_DEFAULT NULL,
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
			  

	
		exec (  '
			  --select * into #temp from AVCP_BandiDocGen where 1=1 ' + @whereCondition + ' 
			  --INSERT INTO #avcp_import_bandi ( 
				 -- codiceEstrazione,
				 -- idAziEnteImport,
				 -- idMsg,
				 -- tipodoc,
				 -- statoFunzionale,
				 -- deleted,
				 -- JumpCheck,
				 -- data,
				 -- PrevDoc,
				 -- Fascicolo,
				 -- Versione,
				 -- LinkedDoc,
				 -- Oggetto,
				 -- Note,
				 -- Anno, 
				 -- Cig,
				 -- CFprop, 
				 -- Denominazione, 
				 -- Scelta_contraente, 
				 -- ImportoAggiudicazione, 
				 -- DataInizio, 
				 -- Datafine, 
				 -- ImportoSommeLiquidate,
				 -- TipoBando,
				 -- idDoc,
				 -- AziendaMittente,
				 -- DtPubblicazione,
				 -- TipoProcedura,
				 -- iSubType,
				 -- origine,
				 -- CigAusiliare,
				 -- divisioneInLotti,
				 -- TipoDocBando 
				 -- )
			  --SELECT ''' + @codiceEstrazione + ''' as codiceEstrazione, 
					--' + @idAziMittenti + ' as idAziEnteImport,
					--    idmsg,
					--	CASE WHEN divisioneInLotti <> ''0'' THEN ''AVCP_GARA''
					--	ELSE ''AVCP_LOTTO''
					--	END AS tipodoc,              
					--	''Pubblicato'',0,'''', DtScadenzaBandoTecnical,NULL,NULL,NULL,NULL,
					--  Oggetto,'''',datepart(year,DtPubblicazione),
					--	case when isnull(cig,'''') = '''' then ''INT-'' + CigAusiliare
					--		  else cig 
					--	end as CIG,
					--	CFenteProponente,
					--	DenominazioneEnteProponente,
                  
					--	dbo.GetSceltaContraente ( tipodoc , CodTipoProcedura  ,TipoBando  , cast( Oggetto as varchar(8000)) )
					--		  AS Scelta_contraente, 
					--	--di_aggiudicazione,
					--	null as ImportoAggiudicazione,
					--	-- DtPubblicazione, non era correttoprendere DataInizio dalla data di pubblicazione
					--	DataInizio AS DataInizio, -- informazione non ancora gestita
					--	-- DtScadenzaBandoTecnical, 
					--	Datafine as Datafine, 
					--	null as ImportoSommeLiquidate,
					--	TipoBando , idDoc,      AziendaMittente,DtPubblicazione,
					--	TipoProcedura, iSubType, ''DOC_GEN'' as origine,CigAusiliare,divisioneInLotti
					--	,TipoDoc
				 -- FROM #temp  
      
      
			  -------- La vista AVCP_BandiCtl mi restitusce le gare a lotti del bando semplificato e del bando_gara ti tipo :
			  -------- * aperta
			  -------- * invito

		  
			  INSERT INTO #avcp_import_bandi ( 
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
			  FROM AVCP_BandiCtl where 1=1 ' + @whereCondition 
			  )




		------------------------------------------------------------------------
		-- Rettifico la scelta del contraente se trovo una richiesta CIG con il SIMOG
		------------------------------------------------------------------------
		UPDATE g 
			SET Scelta_contraente = right( '0' + COALESCE( ss.codiceProceduraSceltaContraente  ,  sg.id_scelta_contraente , Scelta_contraente ) , 2 )
			from #avcp_import_bandi G with(nolock) 
				left join CTL_DOC S with(nolock ) on S.LinkedDoc = G.idmsg and S.TipoDoc in ( 'RICHIESTA_CIG' , 'RICHIESTA_SMART_CIG' ) and S.StatoFunzionale = 'Inviato'
				left join Document_SIMOG_GARA SG with(nolock ) on SG.idheader = S.id	
				left join Document_SIMOG_SMART_CIG SS with(nolock ) on SS.idheader = S.id	
			where  ss.codiceProceduraSceltaContraente  is not null or  sg.id_scelta_contraente is not null



			
		------------------------------------------------------------------------
		-- Recupero tutti LE GARE con lotti per inserire il contenitore dei lotti
		------------------------------------------------------------------------

		insert into [dbo].[document_AVCP_lotti] 
				( [idheader],[idBando],[NumeroLotto],[StatoElaborazione],[Cig] 
					,[Anno], [CFprop], [Denominazione], [Scelta_contraente], [ImportoAggiudicazione], [DataInizio], [Datafine], [ImportoSommeLiquidate], [Oggetto], [DataPubblicazione], [Warning],GUIDBandoGen , tipobandogara, TipoDocBando, LastUpdate
				)
			SELECT 
					@idDoc as [idheader],
					B.idmsg as [idBando],
					'GARA' as NumeroLotto,
					0 as [StatoElaborazione],
					B.Cig

					, B.[Anno]
					, B.[CFprop]
					, B.[Denominazione]
					, B.[Scelta_contraente]
					, null as [ImportoAggiudicazione]
					, B.[DataInizio]
					, B.[Datafine]
					, null as [ImportoSommeLiquidate]
						
					--,case when divisioneInLotti = 0 
					--		then B.[Oggetto] 
					--		else B.oggetto + ' - ' + L.Descrizione
					--	end as [Oggetto]
					, B.[Oggetto]
					, DtPubblicazione as [DataPubblicazione]
					, null as [Warning]
					, B.idDoc as GUIDBandoGen 
					,b.TipoProcedura
					, B.TipoDoc
					, BA.datainvio as LastUpdate
				from #avcp_import_bandi B -- elenco bandi da gestire
					inner join ctl_doc BA WITH(NOLOCK) on BA.id = B.idmsg  
					inner join Document_Bando G  with(nolock) on G.idheader = B.idmsg  
					--left join document_microlotti_dettagli L with(nolock) on L.idheader = B.IdMsg and B.TipoDocBando = L.TipoDoc and L.Voce = 0 -- Lotti del bando
				where G.Divisione_lotti <> 0
	

		------------------------------------------------------------------------
		-- Recupero tutti i lotti dei bandi 
		------------------------------------------------------------------------

		insert into [dbo].[document_AVCP_lotti] 
				( [idheader],[idBando],[NumeroLotto],[StatoElaborazione],[Cig] 
					,[Anno], [CFprop], [Denominazione], [Scelta_contraente], [ImportoAggiudicazione], [DataInizio], [Datafine], [ImportoSommeLiquidate], [Oggetto], [DataPubblicazione], [Warning],GUIDBandoGen , [tipobandogara], [TipoDocBando] , LastUpdate
				)
			SELECT 

					@idDoc as [idheader],
					B.idmsg as [idBando],
					case when divisioneInLotti = 0  then '1' else isnull( L.NumeroLotto, '1' ) end as NumeroLotto ,
					0 as [StatoElaborazione],
			
					case when divisioneInLotti = 0 
							then B.[Cig] 
							else   coalesce( nullif(L.CIG,'')  , 'INT-' + B.CigAusiliare + '-' + isnull( nullif(L.NumeroLotto,'') , '0'  ))
						end as CIG 		


					, B.[Anno]
					, B.[CFprop]
					, B.[Denominazione]
					, B.[Scelta_contraente]
					, null as [ImportoAggiudicazione]
					, B.[DataInizio]
					, B.[Datafine]
					, null as [ImportoSommeLiquidate]
					,case when divisioneInLotti = 0 
							then left( B.[Oggetto] , 250 )
							else 
								case when len( B.oggetto + ' - ' + L.Descrizione ) < = 250 
									then left( B.oggetto + ' - ' + L.Descrizione , 250 ) 
									else left( G.CIG + ' - ' + L.Descrizione , 250 ) 
								end
						end as [Oggetto]
					, DtPubblicazione as [DataPubblicazione]
					, null as [Warning] 
					, B.idDoc as GUIDBandoGen 
					,b.TipoProcedura
					, B.TipoDoc
					, BA.datainvio as LastUpdate

				from #avcp_import_bandi B -- elenco bandi da gestire
					inner join ctl_doc BA WITH(NOLOCK) on BA.id = B.idmsg  
					left join Document_Bando G  with(nolock) on G.idheader = B.idmsg  
					left join document_microlotti_dettagli L with(nolock) on L.idheader = B.IdMsg and B.TipoDocBando = L.TipoDoc and L.Voce = 0 -- Lotti del bando
	

		-- cerco nelle gara la massima data di aggiornamento fra rettifica / revoca / modifica / 
		update R 
			set LastUpdate	= isnull( MaxD.DataInvio, R.LastUpdate )
			from [document_AVCP_lotti] as R
				inner join (	-- aggiornamenti successivi all'invio
								select B.idMsg as idBando , max( D.DataInvio ) as DataInvio
									from #avcp_import_bandi B

										left join ctl_doc D with(nolock) on B.idMsg = D.LinkedDoc and D.deleted = 0 and D.StatoFunzionale <> 'InLavorazione'
																			and D.tipodoc in (
																				'BANDO_MODIFICA'
																				,'BANDO_REVOCA_LOTTO'
																				,'PROROGA_BANDO'
																				,'RETTIFICA_BANDO'
																				,'REVOCA_BANDO'
																			)
									group by B.idMsg
							) as MaxD on MaxD.idBando = R.idBando
			where idheader = @idDoc




		------------------------------------------------------------------
		----- RETTIFICO LA TABELLA  PER I CIG DUPLICATI
		------------------------------------------------------------------
		DECLARE @origine varchar(15)

		select idRow , cig into #T from [document_AVCP_lotti] where idheader = @idDoc  order by CIG , idrow
		update [document_AVCP_lotti] SET CigOriginale = cig  where idheader = @idDoc

		----- Se sono presenti dei CIG duplicati
		if exists (
					select cig
						from #T with(nolock)
						group by cig
						having count(*) > 1
					)
		BEGIN 

			declare @tmpCig varchar(250)       
			declare @curCig varchar(250)       
			declare @progressivo INT
			declare @tmpIdmsg INT

			set @tmpCig = ''
			set @tmpIdmsg = NULL
			set @progressivo = 1

            
			DECLARE curs CURSOR STATIC FOR     
				select idrow , cig
					from #T order by cig , idrow


			OPEN curs 

			FETCH NEXT FROM curs INTO @tmpIdmsg,@tmpCig
			set @curCig = ''

			WHILE @@FETCH_STATUS = 0   
			BEGIN  
						
				if @curCig = @tmpCig
				begin

					update [document_AVCP_lotti] SET
						cig = 'DUPLICATO-' + cig + '-' +  cast(@progressivo as varchar)
						--, CigOriginale = cig
						where idrow = @tmpIdmsg 
						
					set @progressivo = @progressivo + 1
				end
				else
					set @progressivo =  1

				set @curCig = @tmpCig

				FETCH NEXT FROM curs INTO @tmpIdmsg,@tmpCig

			END  


			CLOSE curs   
			DEALLOCATE curs

		END



	end


	--declare @Result nvarchar(max)
	--declare @TotRow int
	--declare @RowElab int
	--declare @NextRow int

	--select @TotRow = count(*) from document_AVCP_lotti with(nolock) where idheader = @idDoc
	--select @RowElab = count(*) from document_AVCP_lotti with(nolock) where idheader = @idDoc and [StatoElaborazione] = 0
	--select top 1 @NextRow = idRow from document_AVCP_lotti with(nolock) where idheader = @idDoc and [StatoElaborazione] = 0 order by Idrow
	--set @NextRow = isnull( @NextRow , 0 )
		
	--update CTL_DOC 
	--	set Body = '{ "TotRow":"' + cast ( @TotRow as varchar ) + '","RowElab":"' + cast( @RowElab as varchar) + '","NextRow":"' + cast( @NextRow as varchar ) + '" }' 
	--		, StatoFunzionale = case when @RowElab = 0 then 'Pubblicato' else 'Elaborazione' end
	--	where id = @idDoc

end

GO
