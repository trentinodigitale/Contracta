USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANNULLA_RICHIESTA_CIG_CREATE_FROM_ODC]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ANNULLA_RICHIESTA_CIG_CREATE_FROM_ODC] ( @odc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON
	
	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	--declare @Bando as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int
	declare @idRichiesta int

	declare @TYPE_TO varchar(200)
	declare @versioneSimog varchar(100)
	
	set @versioneSimog = '3.4.2'
	set @Errore=''	
	
	
	if @Errore=''
	BEGIN

		---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
		select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'ANNULLA_RICHIESTA_CIG' ) and StatoFunzionale <> 'Annullato'
		set @TYPE_TO = 'ANNULLA_RICHIESTA_CIG'

		if @newId is null
		begin
			select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'ANNULLA_RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato'
			set @TYPE_TO = 'ANNULLA_RICHIESTA_SMART_CIG'
		end
		
	END

	if @newId is null
	begin

		-- deve esistere un documento di richiesta nello stato di iniviato o invio in corso
		if not exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG'  )  and StatoFunzionale in ( 'Inviato', 'InvioInCorso' ,'Invio_con_errori' ) ) 
			set @Errore = 'Per effettuare l''annullamento della Richiesta CIG deve essere stata inviata una Richiesta CIG al SIMOG'
					
		
		-- se non sono presenti errori
		if @Errore = ''
		begin

			declare @idRicSmartCig INT

			set @idRicSmartCig = 0

			select @idRicSmartCig = id from CTL_DOC with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  )  and StatoFunzionale in ( 'Inviato' ) 

			IF @idRicSmartCig > 0
			BEGIN

				set @TYPE_TO = 'ANNULLA_RICHIESTA_SMART_CIG'

				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc )
					select  @IdUser,'ANNULLA_RICHIESTA_SMART_CIG' , @IdUser ,Azienda,body, id 
						from ctl_doc with(nolock)
						where id= @odc	

				set @newId = SCOPE_IDENTITY()

				insert into Document_SIMOG_SMART_CIG (	[idHeader], [IMPORTO_GARA], [idpfuRup], smart_cig,[indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], 
							[DENOM_AMMINISTRAZIONE], [CF_UTENTE], [codiceFattispecieContrattuale], [codiceProceduraSceltaContraente], 
							[codiceClassificazioneGara], [cigAccordoQuadro], [cup], 
							[motivo_rich_cig_comuni], [motivo_rich_cig_catmerc], [CATEGORIE_MERC] )
					select 
							@newId				as [idHeader], 
							c.IMPORTO_GARA, 
							c.idpfuRup,
							c.smart_cig,
							
							[indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], 
							[DENOM_AMMINISTRAZIONE], [CF_UTENTE], [codiceFattispecieContrattuale], [codiceProceduraSceltaContraente], 
							[codiceClassificazioneGara], [cigAccordoQuadro], c.[cup], 
							[motivo_rich_cig_comuni], [motivo_rich_cig_catmerc], [CATEGORIE_MERC]
							
						from ctl_doc a with(nolock) 
								inner join Document_SIMOG_SMART_CIG c with(nolock) on c.idHeader = a.Id
						where a.id = @idRicSmartCig and a.TipoDoc = 'RICHIESTA_SMART_CIG'

			END
			ELSE
			BEGIN

				set @TYPE_TO = 'ANNULLA_RICHIESTA_CIG'

				-- recupero il rup che aveva inoltrato la richiesta
				select  @Rup  =  [idpfuRup] , 
						@idRichiesta = id 
					from CTL_DOC  with(nolock)
							 inner join Document_SIMOG_GARA on id = idheader  
					where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  )  and StatoFunzionale in ( 'InvioInCorso' , 'Inviato','Invio_con_errori' ) 
				

				--recupero la versione della richiesta per portarla anche sul doc di annulla
				select @versioneSimog = Versione from ctl_doc with (nolock) where id = @idRichiesta

				-- CREO IL DOCUMENTO
				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, StatoFunzionale , Versione )
					select  @IdUser,'ANNULLA_RICHIESTA_CIG' , @IdUser ,Azienda,body,id, 'InviataRichiesta'	-- lo stato di InviataRichiesta è una sentinella usata nell'onload del documento per chiamare il processo 'CONSULTA_GARA_AUTO,SIMOG'
							, @versioneSimog
						from ctl_doc with(nolock)
						where id = @odc		

				set @newId = SCOPE_IDENTITY()


				--se la versione simog è antecedente alla 3.4.8 inserisco il modello per la testata prima della versione 3.4.8
				if @versioneSimog < '3.4.8'
				begin
					INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
						VALUES ( @newId, 'GARA', 'ANNULLA_RICHIESTA_CIG_GARA_BEFORE_3.4.8' )
				end


				select @NumLotti = 1

				-- inserisco i dati base della gara
				insert into Document_SIMOG_GARA
					(	[idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup] 
						, MOTIVAZIONE_CIG

						-- nuove colonne per versione simog 3.4.2
						, STRUMENTO_SVOLGIMENTO
						, ESTREMA_URGENZA 
						, MODO_INDIZIONE
						
						,CIG_ACC_QUADRO
					)
					select 
						@newId AS [idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup]

							, MOTIVAZIONE_CIG

							-- nuove colonne per versione simog 3.4.2
							, STRUMENTO_SVOLGIMENTO
							, ESTREMA_URGENZA 
							, MODO_INDIZIONE
							, CIG_ACC_QUADRO
						from Document_SIMOG_GARA
						where idheader = @idRichiesta
				

				-- inserisco i dati dei lotti prendendoli dal precedente documento
				insert into Document_SIMOG_LOTTI
					( [idHeader], [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], [EsitoControlli], [StatoRichiestaLOTTO], [CIG] )
					select 
							@newId							as [idHeader], 
							 [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], '' as  [EsitoControlli], [StatoRichiestaLOTTO], [CIG] 
						from Document_SIMOG_LOTTI with(nolock)
						where idHeader = @idRichiesta and isnull( CIG , '' ) <> '' 
						order by idrow

			END

			

		
		end

	end


	if  ISNULL(@newId,0) <> 0
	begin

		select @newId as id, @TYPE_TO as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
