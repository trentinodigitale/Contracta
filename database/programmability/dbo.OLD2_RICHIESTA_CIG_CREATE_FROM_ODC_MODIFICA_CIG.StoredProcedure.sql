USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RICHIESTA_CIG_CREATE_FROM_ODC_MODIFICA_CIG]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  PROCEDURE [dbo].[OLD2_RICHIESTA_CIG_CREATE_FROM_ODC_MODIFICA_CIG] ( @odc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int

	declare @notEditable varchar(1000)
	declare @CODICE_CPV_PREVALENTE varchar(50)

	declare @categoriaPrevalente varchar(100)

	declare @TYPE_TO varchar(200)
	declare @bloccaOutput int
	declare @TipoAppaltoGara as varchar(50)

	declare @importoTotale float --Importo dell’OdF al netto dell'IVA
	declare @cigMaster varchar(100)

	declare @idGara INT

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @categoriaMerceologica varchar(100)

	declare @versioneSimog varchar(100)
	declare @docVersione varchar(100)
	declare @statoFunzDoc varchar(100)

	set @versioneSimog = '3.4.2' 

	select top 1 @versioneSimog = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'

	set @TYPE_TO = 'RICHIESTA_CIG'
	set @bloccaOutput = 0
	set @Errore=''	
	set @notEditable = ''

	---CERCO UNA RICHIESTA di modifica IN CORSO CREATA DA QUEL DOCUMENTO
	select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato','Invio_con_errori' )  and JumpCheck = 'MODIFICA'
	
	-- SE NON C'E' UNA RICHIESTA_CIG PROVO A CERCARE UNA RICHIESTA_SMART_CIG
	IF @newId is null
	BEGIN

		select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato' ) and JumpCheck = 'MODIFICA'

		IF @newId is not null
			set @TYPE_TO = 'RICHIESTA_SMART_CIG'

	END
		

	IF @newId is null
	BEGIN

		IF EXISTS ( select id from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale = 'Inviato'  )
		BEGIN
				
				EXEC RICHIESTA_SMART_CIG_CREATE_FROM_ODC @odc , @IdUser , 1
				set @bloccaOutput = 1
				
		END
		ELSE
		BEGIN
			

				if not exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale in ( 'Inviato' ,'Invio_con_errori') )
					set @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che prima sia stata eseguita una richiesta CIG'

				if @Errore = ''
				begin
					if exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale = 'InvioInCorso' )
						set @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che la richiesta CIG abbia terminato l''invio dei dati al SIMOG'
				end

				if @errore = ''
				begin
					
					select  @cigMaster = CIG_MADRE, 
							@COD_LUOGO_ISTAT = FatturazioneLocalita2,
							@Rup = idpfuRup,
							@importoTotale = isnull(RDA_Total,0)
						from document_odc with(nolock)
						where rda_id = @ODC

					--RISALGO SULLA GARA DI ORIGINE DEL CIG MASTER. In sua assenza blocco
					select top 1 @idGara = g.id
						from ctl_doc g with(nolock)
								inner join document_bando b with(nolock) on b.idHeader = g.id
								inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = g.id and m.TipoDoc = g.TipoDoc and m.voce = 0
						where g.tipodoc IN ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO') and g.Deleted = 0 and g.StatoFunzionale not in ( 'InLavorazione', 'Annullato' , 'Revocato', 'Rifiutato' )
								and ( b.cig = @cigMaster or m.CIG = @cigMaster )
						order by g.id desc

					if @idGara is null
					begin
						set @Errore = 'Richiesta CIG non possibile. Il cig master non risulta associato a nessuna procedura in piattaforma'
					end
					else
					begin

						-- recupero il codice fiscale dell'ente
						select @CF_AMMINISTRAZIONE = vatValore_FT 
							from ctl_doc with(nolock) 
								inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
							where id = @idGara

						select @TipoAppaltoGara= 
								case 
									when TipoAppaltoGara = '1' then 'F'
									when TipoAppaltoGara = '2' then 'L'
									when TipoAppaltoGara = '3' then 'S'
									else ''
								end				
							from Document_Bando DB with(nolock) 
							where idHeader = @idGara

						select top 1 @CODICE_CPV_PREVALENTE = l.CPV,
								 @categoriaMerceologica = g.CATEGORIE_MERC,
								 @categoriaPrevalente = l.ID_CATEGORIA_PREVALENTE
						from ctl_doc rCig with(nolock) 
								inner join Document_SIMOG_GARA g with(nolock) on g.idHeader = rcig.id
								inner join Document_SIMOG_LOTTI l with(nolock) on l.idHeader = rcig.id and l.CIG = @cigMaster
						where rCig.LinkedDoc = @idGara and rCig.TipoDoc = 'RICHIESTA_CIG' and rCig.Deleted = 0 and rCig.StatoFunzionale =  'Inviato' 


					end

				end

				


				-- se non sono presenti errori
				if @Errore = ''
				begin

					declare @OldRichiesta int
					declare @CIG varchar(50)

					--declare @OldOggetto nvarchar(max)

					-- recupero la precedente richiesta inviata
					select @OldRichiesta = id,
							@docVersione = Versione
						from CTL_DOC  with(nolock) 
						where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale in( 'Inviato' ,'Invio_con_errori')

					-- se il documento precedente non era stato creato con l'ultima versione del simog, la modifica cig la continuiamo a fare con la versione precedente
					--IF @docVersione <> @versioneSimog
					--BEGIN
					--	set @versioneSimog = @docVersione
					--END

					-- CREO IL DOCUMENTO
					INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, Versione, iddoc ,JumpCheck , PrevDoc , Caption )
						select  @IdUser,'RICHIESTA_CIG' , @IdUser ,Azienda,body,@odc, @versioneSimog , @idGara, 'MODIFICA' , @OldRichiesta , 'Modifica - Richiesta CIG'
							from ctl_doc with(nolock)
							where id=@odc	


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


					-- recupero il CF del RUP
					select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 

					set @NumLotti = 1
		

					set @notEditable = ' MODO_REALIZZAZIONE ID_SCELTA_CONTRAENTE CIG_ACC_QUADRO '

						if isnull(@categoriaMerceologica,'') <> ''
							set @notEditable = @notEditable + ' CATEGORIE_MERC '

					-- inserisco i dati base della gara
					insert into Document_SIMOG_GARA
						(	[idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup], MOTIVAZIONE_CIG, STRUMENTO_SVOLGIMENTO, CIG_ACC_QUADRO, NotEditable, AzioneProposta )
						select 
								@newId				as [idHeader], 
								null				as [indexCollaborazione], 
								''					as [ID_STAZIONE_APPALTANTE], 
								''					as [DENOM_STAZIONE_APPALTANTE], 
								@CF_AMMINISTRAZIONE as [CF_AMMINISTRAZIONE], 
								''					as [DENOM_AMMINISTRAZIONE], 
								@CF_UTENTE			as [CF_UTENTE], 
								RDA_Total			as [IMPORTO_GARA], 
								''					as [TIPO_SCHEDA], 
								'11'					as [MODO_REALIZZAZIONE], 
								@NumLotti			as [NUMERO_LOTTI], 
								''					as [ESCLUSO_AVCPASS], 
								''					as [URGENZA_DL133], 
								@categoriaMerceologica	as [CATEGORIE_MERC], 
								'18'				as [ID_SCELTA_CONTRAENTE], -- Affidamento diretto in adesione ad accordo quadro/convenzione
								''					as [StatoRichiestaGARA], 
								''					as [EsitoControlli], 
								old.id_gara					as [id_gara], 
								@Rup				as [idpfuRup],
								'2'					as MOTIVAZIONE_CIG,
								'5'					as STRUMENTO_SVOLGIMENTO,
								@cigMaster			as CIG_ACC_QUADRO,
								@notEditable,

								 case 

										when 
												--@CF_AMMINISTRAZIONE <> old.CF_AMMINISTRAZIONE or
												@CF_UTENTE <> old.CF_UTENTE or 
												@categoriaMerceologica <> old.CATEGORIE_MERC or
												@cigMaster <> old.CIG_ACC_QUADRO
											then 'Update' 
										else 'Equal' 

									end as AzioneProposta

							from ctl_doc a with(nolock)
									inner join document_odc b with(nolock)  on b.RDA_ID = a.id
									left join document_simog_gara old with(nolock) on old.idHeader = @OldRichiesta
							where a.id = @odc

				
					set @notEditable = ' FLAG_RIPETIZIONE FLAG_CUP IMPORTO_ATTUAZIONE_SICUREZZA FLAG_ESCLUSO '

					-- inserisco i dati dei lotti
					insert into Document_SIMOG_LOTTI
						( [idHeader], [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], [EsitoControlli], [StatoRichiestaLOTTO], [CIG], NotEditable , AzioneProposta,MODALITA_ACQUISIZIONE)
						select 
								@newId							as [idHeader], 
								1, 
								a.Note							as [OGGETTO], 
								'N'								as [SOMMA_URGENZA], 
								b.RDA_Total						as [IMPORTO_LOTTO], 
								0								as [IMPORTO_SA], 
								0								as [IMPORTO_IMPRESA], 
								@CODICE_CPV_PREVALENTE			as [CPV], 
								'18'							as [ID_SCELTA_CONTRAENTE],
								@categoriaPrevalente			as [ID_CATEGORIA_PREVALENTE], 
								@TipoAppaltoGara				as [TIPO_CONTRATTO], 
								'N'								as [FLAG_ESCLUSO], 
								@COD_LUOGO_ISTAT				as [LUOGO_ISTAT], 
								0								as [IMPORTO_ATTUAZIONE_SICUREZZA], 
								'N'								as [FLAG_PREVEDE_RIP], 
								'N'								as [FLAG_RIPETIZIONE], 
								'N'								as [FLAG_CUP], 
								''								as [CATEGORIA_SIMOG], 
								''								as [EsitoControlli], 
								''								as [StatoRichiestaLOTTO], 
								old.CIG							as [CIG],
								@notEditable,

								case 
									when isnull( old.CIG, '' ) = '' then 'Insert' 
									when cast( a.Note as nvarchar(max)) <> old.OGGETTO or
											b.RDA_Total <> old.IMPORTO_LOTTO or
											@CODICE_CPV_PREVALENTE <> old.CPV or
											@TipoAppaltoGara <> old.TIPO_CONTRATTO or
											@COD_LUOGO_ISTAT <> old.LUOGO_ISTAT
											--obbligo la variazione se è cambiata la versione del simog
											or @versioneSimog <> @docVersione 

										then 'Update' 
									else 'Equal' 
								end as AzioneProposta,
								'1' as MODALITA_ACQUISIZIONE

							from ctl_doc a with(nolock)
									inner join document_odc b with(nolock)  on b.RDA_ID = a.id

									left join Document_SIMOG_LOTTI old with(nolock) on old.idHeader = @OldRichiesta

							where a.id = @odc

			END -- IF PER CHIAMARE LA STORED DI CREAZIONE RICHIESTA SMART CIG

		end

	end
	else -- else se esiste già il documento di modifica
	begin

		select @docVersione = versione, @statoFunzDoc = statoFunzionale from ctl_doc with(nolock) where id = @newid
		
		if @statoFunzDoc = 'InLavorazione' and @docVersione < '3.4.6' and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @newid and DSE_ID in ( 'GARA', 'LOTTI' ) )
		begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
				
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
