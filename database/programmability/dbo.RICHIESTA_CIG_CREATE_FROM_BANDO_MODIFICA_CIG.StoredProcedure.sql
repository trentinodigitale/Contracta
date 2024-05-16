USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_BANDO_MODIFICA_CIG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_BANDO_MODIFICA_CIG] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Bando as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int

	declare @TYPE_TO varchar(200)
	declare @bloccaOutput int
	declare @TipoAppaltoGara as varchar(50)

	declare @versioneSimog varchar(100)
	declare @docVersione varchar(100)
	declare @statoFunzDoc varchar(100)
	declare @Tipo_Rup as varchar(100)

	set @TYPE_TO = 'RICHIESTA_CIG'
	set @bloccaOutput = 0
	set @Errore=''	

	set @versioneSimog = '3.4.2' 

	select top 1 @versioneSimog = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'
	

	---CERCO UNA RICHIESTA di modifica IN CORSO CREATA DA QUEL DOCUMENTO
	select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato','Invio_con_errori' )  and JumpCheck = 'MODIFICA'
	
	-- SE NON C'E' UNA RICHIESTA_CIG PROVO A CERCARE UNA RICHIESTA_SMART_CIG
	IF @newId is null
	BEGIN

		select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato' ) and JumpCheck = 'MODIFICA'

		IF @newId is not null
			set @TYPE_TO = 'RICHIESTA_SMART_CIG'

	END
		

	IF @newId is null
	BEGIN

		IF EXISTS ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale = 'Inviato'  )
		BEGIN
				
				EXEC RICHIESTA_SMART_CIG_CREATE_FROM_BANDO @idDoc , @IdUser , 1
				set @bloccaOutput = 1
				
		END
		ELSE
		BEGIN

				set @Bando = @idDoc

				-- prima di creare il documento verifico i requisiti necessari:
				-- deve esistere un precedente documento di richiesta cig nello stato inviato


					--1) Trovare prodotti senza errori
					--2) Sia stato selezionato luogo istat e cpv
					--3) Sia stato inserito l'oggetto
					--4) Sia presente il RUP
			
		
				-- errore nei prodotti
				if not exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale in ( 'Inviato' ,'Invio_con_errori') )
					set @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che prima sia stata eseguita una richiesta CIG'

				if exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale = 'InvioInCorso' )
					set @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che la richiesta CIG abbia terminato l''invio dei dati al SIMOG'

				-- verifica luogo istat non selezionato
				if @Errore = ''
				begin
					select @COD_LUOGO_ISTAT = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 
					if isnull( @COD_LUOGO_ISTAT , '' ) = '' 
						set @Errore = 'Per effettuare la modifica della richiesta dei CIG Occorre aver indicato il Luogo ISTAT nella scheda "Informazioni Tecniche"'
				end

				-- verifica CPV non selezionata
				if @Errore = ''
				begin
					select @CODICE_CPV = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 
					if isnull( @CODICE_CPV , '' ) = '' 
						set @Errore = 'Per effettuare la modifica della richiesta dei CIG Occorre aver indicato il Codice identificativo corrispondente al sistema di codifica CPV nella scheda "Informazioni Tecniche"'
				end

				-- verifica Oggetto
				if @Errore = ''
				begin
					select @Body = body from CTL_DOC with(nolock) where id = @Bando
					if isnull( @Body , '' ) = '' 
						set @Errore = 'Per effettuare la modifica della richiesta dei CIG Occorre aver inserito l''oggetto della gara'
				end

				if @Errore = ''
				begin

					if exists ( select idrow from ctl_doc_value with(nolock) where idheader = @Bando and dse_id = 'TESTATA_PRODOTTI'  and dzt_name='esitoRiga' and value like '%State_ERR%' )
						set @Errore = 'Operazione non consentita in quanto sono presenti anomalie da correggere nell''Elenco Prodotti. Prima di procedere con la richiesta, dopo aver cliccato su ok...'
				end

				-- verifica rup non selezionato
				if @Errore = ''
				begin
					select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

					if @Tipo_Rup='UserRUP'
						select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
					else
						select @Rup = RupProponente from document_bando  with(nolock) where idheader = @Bando 

					if isnull( @Rup , '' ) = '' 
					begin
						if @Tipo_Rup='UserRUP'	
							set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'
						else
							set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente'
					end
				end

				if @Errore = ''
				begin

					if exists ( select idrow from Document_Bando with(nolock) where idHeader = @Bando and isnull(importoBaseAsta,0) = 0 )
						set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato l''Importo Appalto'
				end

				-- se non sono presenti errori
				if @Errore = ''
				begin

					declare @OldRichiesta int
					declare @importoBaseAsta2 float
					declare @Divisione_lotti varchar(20)
					declare @CIG varchar(50)
					declare @Oggetto nvarchar(max)
					declare @OldOggetto nvarchar(max)

					-- recupero la precedente richiesta inviata
					select @OldRichiesta = id,
							@docVersione = isnull(Versione,'')
						from CTL_DOC with(nolock)
						where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale in( 'Inviato' ,'Invio_con_errori')

					-- EP condiviso con FL e SF per gestire la modifica con la nuova versione
					-- se il documento precedente non era stato creato con l'ultima versione del simog, 
					-- la modifica cig la continuiamo a fare con la versione precedente
					--IF @docVersione <> @versioneSimog
					--BEGIN
					--	set @versioneSimog = @docVersione
					--END

					-- CREO IL DOCUMENTO
					INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc ,JumpCheck , PrevDoc , Caption, versione )
						select  @IdUser,'RICHIESTA_CIG' , @IdUser ,Azienda,body,@idDoc  , 'MODIFICA' , @OldRichiesta , 'Modifica - Richiesta CIG', @versioneSimog
							from ctl_doc with(nolock)
							where id=@idDoc		

					set @newId = SCOPE_IDENTITY()

					IF @versioneSimog < '3.4.6'
					BEGIN

						INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
							VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

						INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
							VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )

					END


					--se la versione è 3.4.6 oppure 3.4.7 metto altri modelli
					if @versioneSimog in ( '3.4.6' , '3.4.7')
					begin

						INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
							VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_6_7' )

						INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
							VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_6_7' )
					
					end

					-- recupero il codice fiscale dell'ente
					select @CF_AMMINISTRAZIONE = vatValore_FT 
						from ctl_doc with(nolock) 
								inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
						where id = @Bando

					-- recupero il CF del RUP
					select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 
					select @Oggetto = Body from CTL_DOC with(nolock)  where id = @Bando
					select @OldOggetto = Body from CTL_DOC with(nolock)  where id = @OldRichiesta
			
					select @NumLotti = count(*) from ctl_doc b with(nolock) inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 where b.id = @Bando
					
					if isnull( @NumLotti, 0 ) = 0 
						set @NumLotti = 1

					select  --@importoBaseAsta2 = importoBaseAsta2	, 
							@importoBaseAsta2 = importoBaseAsta,
							@Divisione_lotti = Divisione_lotti ,
							@CIG = CIG ,
							@TipoAppaltoGara= case when TipoAppaltoGara = '1' then 'F'
												   when TipoAppaltoGara = '2' then 'L'
												   when TipoAppaltoGara = '3' then 'S'
												   else ''
											  end			
						from document_bando with(nolock) 
						where idHeader = @Bando
				

					-- inserisco i dati base della gara
					insert into Document_SIMOG_GARA
						(	[idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], 
							[CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], 
							[ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup] , [MOTIVAZIONE_CIG] , 
							[STRUMENTO_SVOLGIMENTO]	,[ESTREMA_URGENZA],[MODO_INDIZIONE]
							, ALLEGATO_IX
							, DURATA_ACCQUADRO_CONVENZIONE
							, CIG_ACC_QUADRO
							, DATA_PERFEZIONAMENTO_BANDO
							, AzioneProposta
							, LINK_AFFIDAMENTO_DIRETTO)
						select 
								@newId				as [idHeader], 
								[indexCollaborazione], 
								[ID_STAZIONE_APPALTANTE], 
								[DENOM_STAZIONE_APPALTANTE], 
								[CF_AMMINISTRAZIONE], 
								[DENOM_AMMINISTRAZIONE], 
								[CF_UTENTE], 
								@importoBaseAsta2	as [IMPORTO_GARA], 
								[TIPO_SCHEDA], 
								[MODO_REALIZZAZIONE], 
								@NumLotti			as [NUMERO_LOTTI], 
								[ESCLUSO_AVCPASS], 
								[URGENZA_DL133], 
								[CATEGORIE_MERC], 
								[ID_SCELTA_CONTRAENTE], 
								[StatoRichiestaGARA], 
								[EsitoControlli], 
								[id_gara], 
								[idpfuRup] ,
								[MOTIVAZIONE_CIG],
								[STRUMENTO_SVOLGIMENTO]	,
								[ESTREMA_URGENZA],
								[MODO_INDIZIONE]
								, ALLEGATO_IX
								, DURATA_ACCQUADRO_CONVENZIONE
								, CIG_ACC_QUADRO
								, DATA_PERFEZIONAMENTO_BANDO
								, case 

									when 
										@OldOggetto <> @Oggetto or
										dbo.AFS_ROUND(@importoBaseAsta2,2) <> dbo.AFS_ROUND(IMPORTO_GARA,2) or 
										@NumLotti <> NUMERO_LOTTI 
										then 'Update' 
									else 'Equal' 

								end as AzioneProposta
								, LINK_AFFIDAMENTO_DIRETTO

							from Document_SIMOG_GARA with(nolock) 
							where idHeader = @OldRichiesta

					-- inserisco i dati dei lotti
					insert into Document_SIMOG_LOTTI
						( [idHeader], [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], 
							[ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], 
							[FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], [EsitoControlli], [StatoRichiestaLOTTO], [CIG] , AzioneProposta,MODALITA_ACQUISIZIONE,
							TIPOLOGIA_LAVORO,[ID_ESCLUSIONE], [Condizioni], [ID_AFF_RISERVATI], [FLAG_REGIME], [ART_REGIME], [FLAG_DL50], [PRIMA_ANNUALITA], 
							[ANNUALE_CUI_MININF] ,[ID_MOTIVO_COLL_CIG], [CIG_ORIGINE_RIP], IMPORTO_OPZIONI, SYNC_LUOGO_NUTS, SYNC_LUOGO_ISTAT,  DURATA_ACCQUADRO_CONVENZIONE, DURATA_RINNOVI,CUP
							,FLAG_PNRR_PNC, ID_MOTIVO_DEROGA,FLAG_MISURE_PREMIALI,ID_MISURA_PREMIALE,FLAG_PREVISIONE_QUOTA,QUOTA_FEMMINILE,QUOTA_GIOVANILE,FLAG_DEROGA_ADESIONE,FLAG_USO_METODI_EDILIZIA, DEROGA_QUALIFICAZIONE_SA
						 )
						select 
								@newId							as [idHeader], 
								d.NumeroLotto, 
								Descrizione						as [OGGETTO], 
								[SOMMA_URGENZA], 
								--d.ValoreImportoLotto			as [IMPORTO_LOTTO], 
								d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) as [IMPORTO_LOTTO],
								isnull( [IMPORTO_SA] , 0 )		as [IMPORTO_SA] , 
								isnull( [IMPORTO_IMPRESA] , 0 ) as [IMPORTO_IMPRESA], 
								isnull(  l.[CPV] , @CODICE_CPV)	as [CPV], 
								[ID_SCELTA_CONTRAENTE], 
								[ID_CATEGORIA_PREVALENTE], 
								case when ISNULL([TIPO_CONTRATTO],'') = '' then  @TipoAppaltoGara else [TIPO_CONTRATTO] end , 
								[FLAG_ESCLUSO], 
								isnull(  [LUOGO_ISTAT] , @COD_LUOGO_ISTAT)				as [LUOGO_ISTAT], 
								d.[IMPORTO_ATTUAZIONE_SICUREZZA], 
								[FLAG_PREVEDE_RIP], 
								[FLAG_RIPETIZIONE], 
								[FLAG_CUP], 
								[CATEGORIA_SIMOG], 
								[EsitoControlli], 
								[StatoRichiestaLOTTO], 
								case when @Divisione_lotti = 0 then @CIG else d.CIG end as CIG ,
						
								case 
									when isnull( case when @Divisione_lotti = 0 then @CIG else d.CIG end , '' ) = '' 
										then 'Insert' 
									when 
										d.Descrizione <> l.OGGETTO or
										dbo.AFS_ROUND(d.ValoreImportoLotto,2) <> ( dbo.AFS_ROUND(l.IMPORTO_LOTTO,2) - isnull(l.IMPORTO_OPZIONI,0) - isnull(l.IMPORTO_ATTUAZIONE_SICUREZZA,0) ) or
										--@CODICE_CPV <> l.CPV or
										--@COD_LUOGO_ISTAT <> l.LUOGO_ISTAT or
										dbo.AFS_ROUND(d.IMPORTO_OPZIONI,2) <> dbo.AFS_ROUND(l.IMPORTO_OPZIONI,2) or
										dbo.AFS_ROUND(d.IMPORTO_ATTUAZIONE_SICUREZZA,2) <> dbo.AFS_ROUND(l.IMPORTO_ATTUAZIONE_SICUREZZA,2)
										
										--obbligo la variazione se è cambiata la versione del simog
										or @versioneSimog <> @docVersione 

										then 'Update' 
									else 'Equal' 
								end as AzioneProposta ,
								case when ISNULL(MODALITA_ACQUISIZIONE,'')='' then '1' else MODALITA_ACQUISIZIONE end,
								TIPOLOGIA_LAVORO,

								[ID_ESCLUSIONE], [Condizioni], [ID_AFF_RISERVATI], [FLAG_REGIME], [ART_REGIME], [FLAG_DL50], [PRIMA_ANNUALITA], [ANNUALE_CUI_MININF]
								,[ID_MOTIVO_COLL_CIG], [CIG_ORIGINE_RIP], d.IMPORTO_OPZIONI, SYNC_LUOGO_NUTS, SYNC_LUOGO_ISTAT,  DURATA_ACCQUADRO_CONVENZIONE, DURATA_RINNOVI,
								l.CUP,

								--non li devo riprendere dalla gara perchè sulla richiesta cig vengono potenzialmente specializzati per lotto
								l.FLAG_PNRR_PNC, l.ID_MOTIVO_DEROGA,
								l.FLAG_MISURE_PREMIALI,l.ID_MISURA_PREMIALE,
								l.FLAG_PREVISIONE_QUOTA,l.QUOTA_FEMMINILE,
								l.QUOTA_GIOVANILE,
								l.FLAG_DEROGA_ADESIONE,
								l.FLAG_USO_METODI_EDILIZIA,
								l.DEROGA_QUALIFICAZIONE_SA
							from ctl_doc b with(nolock) 
									--inner join document_bando db with(nolock) on db.idHeader = b.id
									inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
									left  join Document_SIMOG_LOTTI l with(nolock) on  l.idheader = @OldRichiesta 
											and 
											(  
												( d.CIG <> ''  and l.CIG = case when @Divisione_lotti = 0 then @CIG else d.CIG end ) -- i dati della richiesta precedente vanno accoppiato per CIG
												or
												( d.CIG = '' and l.CIG = '' and l.NumeroLotto = d.NumeroLotto ) -- in assenza di CIG si accoppia per numero lotto
												or
												--per le monolotto sulla microlotti dettagli del pregara non andiamo a riportare il cig
												--quindi lo contronto con quello riportato in testata del pregara
												( isnull(d.cig,'')='' and  l.CIG = @CIG and @Divisione_lotti = 0)

											)

							where b.id = @Bando
							order by d.id

					-- per il monolotto mi devo prendere il CIG dalla testata
					--if @Divisione_lotti = 0
					--	update Document_SIMOG_LOTTI set CIG =  @CIG where [idHeader] = @newId 

					-- le gare senza lotti non hanno i cig sulle righe quindi non è necessario aggiungere lotti cancellati
					if @Divisione_lotti <> 0
					begin

						-- si aggiungono eventuali CIG precedentemente richiesti e non più presenti nella gara
						insert into Document_SIMOG_LOTTI
							( [idHeader], [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], [EsitoControlli], [StatoRichiestaLOTTO], [CIG] , AzioneProposta,MODALITA_ACQUISIZIONE,TIPOLOGIA_LAVORO, 
							  [ID_ESCLUSIONE], [Condizioni], [ID_AFF_RISERVATI], [FLAG_REGIME], [ART_REGIME], [FLAG_DL50], [PRIMA_ANNUALITA], [ANNUALE_CUI_MININF]
							  ,[ID_MOTIVO_COLL_CIG], [CIG_ORIGINE_RIP], IMPORTO_OPZIONI,CUP, FLAG_DEROGA_ADESIONE, FLAG_USO_METODI_EDILIZIA, DEROGA_QUALIFICAZIONE_SA
							)
							select 
									@newId							as [idHeader], 
									'' as NumeroLotto, 
									[OGGETTO], 
									[SOMMA_URGENZA], 
									[IMPORTO_LOTTO], -- recuperato dopo con query dinamica il campo cambia in funzione del modello
									[IMPORTO_SA], 
									[IMPORTO_IMPRESA], 
									[CPV], 
									[ID_SCELTA_CONTRAENTE], 
									[ID_CATEGORIA_PREVALENTE], 
									case when ISNULL([TIPO_CONTRATTO],'') = '' then  @TipoAppaltoGara else [TIPO_CONTRATTO] end , 
									[FLAG_ESCLUSO], 
									[LUOGO_ISTAT], 
									l.[IMPORTO_ATTUAZIONE_SICUREZZA], 
									[FLAG_PREVEDE_RIP], 
									[FLAG_RIPETIZIONE], 
									[FLAG_CUP], 
									[CATEGORIA_SIMOG], 
									[EsitoControlli], 
									[StatoRichiestaLOTTO], 
									l.CIG ,
									'Delete' as AzioneProposta,
									case when ISNULL(MODALITA_ACQUISIZIONE,'')='' then '1' else MODALITA_ACQUISIZIONE end,
									TIPOLOGIA_LAVORO,

									[ID_ESCLUSIONE], [Condizioni], [ID_AFF_RISERVATI], [FLAG_REGIME], [ART_REGIME], [FLAG_DL50], [PRIMA_ANNUALITA], [ANNUALE_CUI_MININF]
									,[ID_MOTIVO_COLL_CIG], [CIG_ORIGINE_RIP],
									l.IMPORTO_OPZIONI,
									l.CUP,
									l.FLAG_DEROGA_ADESIONE, 
									l.FLAG_USO_METODI_EDILIZIA,
									l.DEROGA_QUALIFICAZIONE_SA
								from Document_SIMOG_LOTTI l with(nolock) 
										inner join CTL_DOC b with(nolock) on b.id = @Bando
										left join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 and d.CIG = l.CIG
								where
									l.idheader = @OldRichiesta 
									and isnull( d.CIG , '' ) = '' -- is null
									and l.AzioneProposta <> 'Delete'
									and isnull( l.CIG , '' ) <> '' 
								order by l.idRow
					end

			END -- IF PER CHIAMARE LA STORED DI CREAZIONE RICHIESTA SMART CIG

		end

	end
	else -- else se esiste già il documento di modifica
	begin

		select @docVersione = versione, @statoFunzDoc = statoFunzionale from ctl_doc with(nolock) where id = @newid

		-- se il documento è ancora in lavorazione e rispetto alla sua creazione, la versione simog è avanzata, la rettifichiamo
		--	UPD: LA VERSIONE DEL DOCUMENTO IN LAVORAZIONE DEVE RIMANERE, NON DOBBIAMO AGGIORNARLO ALL'ULTIMA IN ESSERE
		--if @statoFunzDoc = 'InLavorazione' and @docVersione <> @versioneSimog
		--begin
			
		--	update ctl_doc
		--			set versione = @versioneSimog
		--		where id = @newid

		--	-- cancelliamo il modello per la versione "vecchia" così da lasciare il default
		--	delete from CTL_DOC_SECTION_MODEL where idheader = @newid and DSE_ID IN ( 'GARA', 'LOTTI' )

		--end
			
		if @statoFunzDoc = 'InLavorazione' and @docVersione < '3.4.6' and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @newid and DSE_ID in ( 'GARA', 'LOTTI' ) )
		begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
				
		end

	end

	if dbo.PARAMETRI('RICHIESTA_CIG_GARA_DELEGA','GestioneCiGconDelega','HIDE','0',-1) = '0'
	begin
		if ISNULL(@newId,0) <> 0
		begin
			--forse con un controllo di attivazione
			declare @cfEnteProponente varchar(500)
			declare @denominazioneEnteProponente varchar(500)
			declare @StazioneAppaltanteSoggettoSingolo varchar(50)
			declare @FUNZIONI_DELEGATE varchar(50)

			select 
					@cfEnteProponente = ISNULL(a.Value,''),
					@denominazioneEnteProponente = ISNULL(b.Value,''),
					@StazioneAppaltanteSoggettoSingolo = ISNULL(c.Value,''),
					@FUNZIONI_DELEGATE = ISNULL(d.Value,'')
				from CTL_DOC_Value as a with(nolock) 
					LEFT join CTL_DOC_Value as b with(nolock) on a.IdHeader = b.IdHeader and b.DSE_ID = 'GARADELEGA' and b.DZT_Name = 'DenominazioneAmministrazioneSA'
					LEFT join CTL_DOC_Value as c with(nolock) on a.IdHeader = c.IdHeader and c.DSE_ID = 'GARADELEGA' and c.DZT_Name = 'StazioneAppaltanteSoggettoSingolo'
					LEFT join CTL_DOC_Value as d with(nolock) on a.IdHeader = d.IdHeader and d.DSE_ID = 'GARADELEGA' and d.DZT_Name = 'FUNZIONI_DELEGATE'
				where a.IdHeader = @OldRichiesta 
					and a.DSE_ID = 'GARADELEGA' 
					and a.DZT_Name = 'CodiceFiscaleSoggettoSA'
		
			
					if exists (select idrow from CTL_DOC_Value with(nolock) where DSE_ID = 'GARADELEGA' and DZT_Name = 'CodiceFiscaleSoggettoSA' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = @cfEnteProponente where DSE_ID = 'GARADELEGA' and DZT_Name = 'CodiceFiscaleSoggettoSA' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'CodiceFiscaleSoggettoSA',  @cfEnteProponente)
						end
				
					if exists (select idrow from CTL_DOC_Value with(nolock) where DSE_ID = 'GARADELEGA' and DZT_Name = 'DenominazioneAmministrazioneSA' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = @denominazioneEnteProponente where DSE_ID = 'GARADELEGA' and DZT_Name = 'DenominazioneAmministrazioneSA' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'DenominazioneAmministrazioneSA',  @denominazioneEnteProponente)
						end
				
					if exists (select idrow from CTL_DOC_Value with(nolock) where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = @StazioneAppaltanteSoggettoSingolo where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'StazioneAppaltanteSoggettoSingolo',  @StazioneAppaltanteSoggettoSingolo)
						end

					if exists (select idrow from CTL_DOC_Value with(nolock) where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = @FUNZIONI_DELEGATE where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'StazioneAppaltanteSoggettoSingolo',  @FUNZIONI_DELEGATE)
						end
				
		end
	end

	IF @bloccaOutput = 0
	begin

		if  ISNULL(@newId,0) <> 0
		begin
			-- rirorna l'id del doc da aprire
			select @newId as id, @TYPE_TO as TYPE_TO
	
		end
		else
		begin

			select 'Errore' as id , @Errore as Errore

		end

	end

END










GO
