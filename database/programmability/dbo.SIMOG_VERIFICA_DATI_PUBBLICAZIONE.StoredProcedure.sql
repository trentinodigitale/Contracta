USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SIMOG_VERIFICA_DATI_PUBBLICAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec SIMOG_VERIFICA_DATI_PUBBLICAZIONE 420126

--select top 10 * from CTL_Schedule_Process order by 1 desc

CREATE PROCEDURE [dbo].[SIMOG_VERIFICA_DATI_PUBBLICAZIONE] ( @idGara INT, @datiVariati INT = 0 output, @debug int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @attach nvarchar(4000) = ''
	declare @attachOld nvarchar(4000) = ''
	declare @idDocPub INT = 0
	declare @idDocReq INT = 0

	declare @LINK_SITO nvarchar(4000) = ''
	declare @NUMERO_QUOTIDIANI_NAZ INT = 0
	declare @NUMERO_QUOTIDIANI_REGIONALI INT = 0
	declare @DATA_PUBBLICAZIONE varchar(100) = ''
	declare @DATA_SCADENZA_PAG varchar(100) = ''
	declare @ORA_SCADENZA varchar(100) = ''
	declare @DATA_SCADENZA_RICHIESTA_INVITO varchar(100) = ''
	declare @DATA_LETTERA_INVITO varchar(100) = ''

	declare @LINK_SITO_OLD nvarchar(4000) = ''
	declare @NUMERO_QUOTIDIANI_NAZ_OLD INT = 0
	declare @NUMERO_QUOTIDIANI_REGIONALI_OLD INT = 0
	declare @DATA_PUBBLICAZIONE_OLD varchar(100) = ''
	declare @DATA_SCADENZA_PAG_OLD varchar(100) = ''
	declare @ORA_SCADENZA_OLD varchar(100) = ''
	declare @DATA_SCADENZA_RICHIESTA_INVITO_OLD varchar(100) = ''
	declare @DATA_LETTERA_INVITO_OLD varchar(100) = ''

	declare @fileHashNew nvarchar(max) = ''
	declare @fileHashOld nvarchar(max) = ''

	declare @RichiestaCigSimog varchar(10) = ''

	select @RichiestaCigSimog = RichiestaCigSimog  from Document_Bando with(nolock) where idHeader = @idGara

	IF @RichiestaCigSimog = 'si'
	BEGIN

		--se esiste una precedente richiesta cig inviata con successo
		IF exists (	select id from CTL_DOC with (nolock) where LinkedDoc = @idGara and TipoDoc='RICHIESTA_CIG' and StatoFunzionale='Inviato' and Deleted=0 )
		BEGIN

			select @idDocPub = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idGara and deleted = 0 and TipoDoc =  'SIMOG_PUBBLICA'
			--select @idDocPub = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idGara and deleted = 0 and TipoDoc =  'SIMOG_REQUISITI'

			select  @LINK_SITO = [LINK_SITO], 
					@NUMERO_QUOTIDIANI_NAZ = [NUMERO_QUOTIDIANI_NAZ], 
					@NUMERO_QUOTIDIANI_REGIONALI = [NUMERO_QUOTIDIANI_REGIONALI], 
					@DATA_PUBBLICAZIONE = [DATA_PUBBLICAZIONE], 
					@DATA_SCADENZA_PAG = [DATA_SCADENZA_PAG], 
					@ORA_SCADENZA = [ORA_SCADENZA], 
					@DATA_SCADENZA_RICHIESTA_INVITO = [DATA_SCADENZA_RICHIESTA_INVITO], 
					@DATA_LETTERA_INVITO = [DATA_LETTERA_INVITO] 
				from SIMOG_PUBBLICA_DATI_WS
				where id_gara = @idGara

			select  @LINK_SITO_OLD = [LINK_SITO], 
					@NUMERO_QUOTIDIANI_NAZ_OLD = [NUMERO_QUOTIDIANI_NAZ], 
					@NUMERO_QUOTIDIANI_REGIONALI_OLD = [NUMERO_QUOTIDIANI_REGIONALI], 
					@DATA_PUBBLICAZIONE_OLD = [DATA_PUBBLICAZIONE], 
					@DATA_SCADENZA_PAG_OLD = [DATA_SCADENZA_PAG], 
					@ORA_SCADENZA_OLD = [ORA_SCADENZA], 
					@DATA_SCADENZA_RICHIESTA_INVITO_OLD = [DATA_SCADENZA_RICHIESTA_INVITO], 
					@DATA_LETTERA_INVITO_OLD = [DATA_LETTERA_INVITO],
					@attachOld = fileBandoDiGara
				from document_bando_datiPubSimog with(nolock)
				where idHeader = @idDocPub

			exec CHECK_SEND_ALLEGATO_SIMOG @idGara, 0, @attach output

			if isnull(@attach,'') <> ''
			begin
				select @fileHashNew = ATT_FileHash from ctl_attach with (nolock) where att_hash = dbo.GetColumnValue( @attach, '*', 4)
			end

			if isnull(@attachOld,'') <> ''
			begin
				select @fileHashOld = ATT_FileHash from ctl_attach with (nolock) where att_hash = dbo.GetColumnValue( @attachOld, '*', 4)
			end

			if @debug = 1
			begin

				print '@fileHashNew : ' + @fileHashNew
				print '@@fileHashOld : ' + @fileHashOld

			end

			-- I REQUISITI NON SI POSSONO RIMANDARE DOPO LA PUBBLICAZIONE, ANAC CI RESTITUISCE L'ERRORE : 
			--		SIMOGWS_GARALOTTOMANAGER_APP_31 - ERRORE LA GARA RISULTA GIA' PUBBLICATA/PERFEZIONATA

			--declare @totReqNew INT = 0
			--declare @totReqOld INT = 0

			--declare @listReqNew nvarchar(max) = ''
			--declare @listReqOld nvarchar(max) = ''

			--select @listReqNew = @listReqNew + isnull(RequisitoGara,'') from Document_Bando_Requisiti with(nolock) where idHeader = @idGara order by RequisitoGara
			--select @listReqOld = @listReqOld + isnull(RequisitoGara,'') from Document_Bando_Requisiti with(nolock) where idHeader = @idDocReq order by RequisitoGara

			--if @totReqNew <> @totReqOld
			--if @listReqNew <> @listReqOld
			--begin
			--	INSERT INTO CTL_Schedule_Process ( iddoc, iduser, DPR_DOC_ID, DPR_ID)
			--							  values ( @idGara, 0, 'SIMOG', 'MODIFICA_REQUISITI' )
			--end

			IF ( @LINK_SITO_OLD <> @LINK_SITO or  
					@NUMERO_QUOTIDIANI_NAZ_OLD <> @NUMERO_QUOTIDIANI_NAZ or  
					@NUMERO_QUOTIDIANI_REGIONALI_OLD <> @NUMERO_QUOTIDIANI_REGIONALI or 
					@DATA_PUBBLICAZIONE_OLD <> @DATA_PUBBLICAZIONE or 
					@DATA_SCADENZA_PAG_OLD <> @DATA_SCADENZA_PAG or 
					@ORA_SCADENZA_OLD <> @ORA_SCADENZA or 
					@DATA_SCADENZA_RICHIESTA_INVITO_OLD <> @DATA_SCADENZA_RICHIESTA_INVITO or
					@DATA_LETTERA_INVITO_OLD <> @DATA_LETTERA_INVITO or
					isnull(@fileHashNew,'') <> isnull(@fileHashOld,'')
			)
			BEGIN

				set @datiVariati = 1

				INSERT INTO CTL_Schedule_Process ( iddoc, iduser, DPR_DOC_ID, DPR_ID)
										  values ( @idGara, 0, 'SIMOG', 'PUBBLICA_MODIFICA' )

			END

		END
		ELSE
		BEGIN

			if @debug = 1
				print 'richiesta cig non inviata'

		END

	END
	ELSE
	BEGIN

		if @debug = 1
			print 'simog no'

	END


END










GO
