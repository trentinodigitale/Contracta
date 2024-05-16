USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANNULLA_RICHIESTA_CIG_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_ANNULLA_RICHIESTA_CIG_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;

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
	declare @idRichiesta int

	declare @TYPE_TO varchar(200)

	set @Errore=''	
	
	
	if @Errore=''
	BEGIN

		---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
		select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'ANNULLA_RICHIESTA_CIG' ) and StatoFunzionale <> 'Annullato'
		set @TYPE_TO = 'ANNULLA_RICHIESTA_CIG'

		if @newId is null
		begin
			select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'ANNULLA_RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato'
			set @TYPE_TO = 'ANNULLA_RICHIESTA_SMART_CIG'
		end
		
	END

	if @newId is null
	begin

		set @Bando = @idDoc

		-- deve esistere un documento di richiesta nello stato di iniviato o invio in corso
		if not exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG'  )  and StatoFunzionale in ( 'Inviato', 'InvioInCorso' ,'Invio_con_errori' ) ) 
			set @Errore = 'Per effettuare l''annullamento della Richiesta CIG deve essere stata inviata una Richiesta CIG al SIMOG'
					
		
		-- se non sono presenti errori
		if @Errore = ''
		begin

			declare @idRicSmartCig INT

			set @idRicSmartCig = 0

			select @idRicSmartCig = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  )  and StatoFunzionale in ( 'Inviato' ) 

			IF @idRicSmartCig > 0
			BEGIN

				set @TYPE_TO = 'ANNULLA_RICHIESTA_SMART_CIG'

				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc )
					select  @IdUser,'ANNULLA_RICHIESTA_SMART_CIG' , @IdUser ,Azienda,body,@idDoc 
						from ctl_doc with(nolock)
						where id=@idDoc	

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
				select @Rup  =  [idpfuRup] , @idRichiesta = id from CTL_DOC  with(nolock) inner join Document_SIMOG_GARA on id = idheader  where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  )  and StatoFunzionale in ( 'InvioInCorso' , 'Inviato','Invio_con_errori' ) 
			
				-- CREO IL DOCUMENTO
				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, StatoFunzionale )
					select  @IdUser,'ANNULLA_RICHIESTA_CIG' , @IdUser ,Azienda,body,@idDoc, 'InviataRichiesta'	-- lo stato di InviataRichiesta è una sentinella usata nell'onload del documento per chiamare il processo 'CONSULTA_GARA_AUTO,SIMOG'
						from ctl_doc with(nolock)
						where id=@idDoc		

				set @newId = SCOPE_IDENTITY()

				-- recupero il codice fiscale dell'ente
				select @CF_AMMINISTRAZIONE = vatValore_FT 
					from ctl_doc with(nolock) 
						inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
					where id = @Bando

				-- recupero il CF del RUP
				select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 

				--select @NumLotti = count(*) from ctl_doc b with(nolock) inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 where b.id = @Bando
				select @NumLotti = count(*)
					from Document_SIMOG_LOTTI with(nolock)
					where idHeader = @idRichiesta and isnull( CIG , '' ) <> '' 

				-- inserisco i dati base della gara
				insert into Document_SIMOG_GARA
					(	[idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup] 
						, MOTIVAZIONE_CIG

						-- nuove colonne per versione simog 3.4.2
						, STRUMENTO_SVOLGIMENTO
						, ESTREMA_URGENZA 
						, MODO_INDIZIONE
					)
					select 
						@newId AS [idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup]

							, MOTIVAZIONE_CIG

							-- nuove colonne per versione simog 3.4.2
							, STRUMENTO_SVOLGIMENTO
							, ESTREMA_URGENZA 
							, MODO_INDIZIONE
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
