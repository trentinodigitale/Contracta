USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CAN29_POPOLA_BUFFER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[E_FORMS_CAN29_POPOLA_BUFFER] ( @idPDA int , @idUser int = 0, 
														@guidOperation varchar(500) = '', 
														@numeroLotto varchar(1000) = '',
														@idDocContrConv int = 0,
														@uuidFles varchar(100) = '')
AS
BEGIN

	--PER VELOCIZZARE LA PRODUZIONE DELL'XML SALVIAMO IN UNA TABELLA DI "CACHE" GLI ID DEI LOTTI CON STATO "TERMINALE" ( così come altri dati utili ). 
	-- L'AGGANCIO È UN GUID PASSATO DAL CHIAMANTE, QUESTI DATI POI VERRANNO USATI NELLE CHIAMATE/STORED SUCCESSIVE

	SET NOCOUNT ON

	DECLARE @TipoAggiudicazione varchar(100) = ''
	DECLARE @idProc INT = 0
	DECLARE @tipoDocGara varchar(100) = ''
	DECLARE @cigMonolotto varchar(100) = ''
	DECLARE @cigFLES varchar(100) = ''

	--PER NON AGGIUDICAZIONE, SE HO UN IDPROC AL POSTO DELL'ID PDA UTILIZZO QUELLO
	IF EXISTS(SELECT id FROM CTL_DOC WITH(NOLOCK) WHERE TipoDoc = 'BANDO_GARA' and Id = @idPDA )
	BEGIN
		SET @idProc = @idPDA
	END

	-------------------------------------------------------------------
	--SE PROVENIAMO DA UN GIRO DEL FLUSSO DI ESECUZIONE ( CAN38/40 ) --
	-------------------------------------------------------------------
	IF @uuidFles <> ''
	BEGIN

		SELECT  @cigFLES = CIG
			FROM FLES_TABLE_MODIFICA_CONTRATTUALE with(nolock)
			WHERE UUID = @uuidFles

	END

	--PER NON AGGIUDICAZIONE
	--SE NON HO TROVATO L'IDPROC ALLORA UTILIZZO LA PDA
	--ALTRIMENTI POPOLO LA BUFFER CON I DATI NELLA DOCUMENT_MICROLOTTI_DETTAGLI INSERENDO SEMPRE I LOTTI COME REVOCATI
	IF @idProc = 0
	BEGIN

		select @TipoAggiudicazione = db.TipoAggiudicazione,
				@idProc = db.idHeader,
				@tipoDocGara = g.TipoDoc,
				@cigMonolotto = db.CIG
			from ctl_doc pda with(nolock)
					inner join document_bando db with(nolock) on db.idHeader = pda.LinkedDoc
					inner join ctl_doc g with(nolock) on g.id = db.idHeader
			where pda.id = @idPDA

		--CANCELLO LE VECCHIE GENERAZIONI PER IDPROC
		DELETE FROM Document_E_FORM_BUFFER where IdProc=@idProc

		IF CHARINDEX(',', @numeroLotto) = 0 --se non si sta filtrando per numero lotto o se il lotto è unico
		BEGIN

			INSERT INTO Document_E_FORM_BUFFER( [guid], idRow, infoType, strData1, strData2, intData1, strData3, IdProc) 
				SELECT @guidOperation, a.id, 'LOTTI_CHIUSI', a.NumeroLotto, a.StatoRiga, a.Aggiudicata, isnull( CVL.TipoAggiudicazione , @TipoAggiudicazione ), @idProc
					FROM Document_MicroLotti_Dettagli a WITH(NOLOCK)
							--PER RECUPERARE TIPOAGGIUDICAZIONE DEL LOTTO
							LEFT JOIN document_microlotti_dettagli DB with (nolock) on DB.idheader = @idProc and db.tipodoc = @tipoDocGara and db.voce=0 and db.numerolotto = a.NumeroLotto
							LEFT JOIN View_Criteri_Valutazione_Lotto CVL with (nolock) on  CVL.idheader = db.id
					WHERE a.IdHeader=@idpda and a.TipoDoc='PDA_MICROLOTTI' and a.Voce=0 and a.StatoRiga in ('AggiudicazioneDef','interrotto','NonGiudicabile','Revocato','Deserta', 'NonAggiudicabile')
							-- se è stato richiesto un lotto specifico
							and a.NumeroLotto = ( case when @numeroLotto <> '' then  @numeroLotto else a.NumeroLotto end )

							-- se provengo dal giro FLES restringo il recupero al solo CIG presente sulla tabella FLES_TABLE_MODIFICA_CONTRATTUALE in quanto lato FLES
							--		è sempre monolotto l'invio
							and ( ( @uuidFles <> '' and isnull(a.cig, @cigMonolotto ) = @cigFLES ) or ( @uuidFles = '' ) )

		END
		ELSE
		BEGIN

			--aggiungo in inner join la split sui lotti richiesti
			INSERT INTO Document_E_FORM_BUFFER( [guid], idRow, infoType, strData1, strData2, intData1, strData3, IdProc) 
				SELECT @guidOperation, a.id, 'LOTTI_CHIUSI', a.NumeroLotto, a.StatoRiga, a.Aggiudicata, isnull( CVL.TipoAggiudicazione , @TipoAggiudicazione ), @idProc
					FROM Document_MicroLotti_Dettagli a WITH(NOLOCK)
							INNER JOIN dbo.Split(@numeroLotto,',') s on s.items = a.NumeroLotto
							--PER RECUPERARE TIPOAGGIUDICAZIONE DEL LOTTO
							LEFT JOIN document_microlotti_dettagli DB with (nolock) on DB.idheader = @idProc and db.tipodoc = @tipoDocGara and db.voce=0 and db.numerolotto = a.NumeroLotto
							LEFT JOIN View_Criteri_Valutazione_Lotto CVL with (nolock) on  CVL.idheader = db.id
					WHERE a.IdHeader=@idpda and a.TipoDoc='PDA_MICROLOTTI' and a.Voce=0 and a.StatoRiga in ('AggiudicazioneDef','interrotto','NonGiudicabile','Revocato','Deserta', 'NonAggiudicabile')

							-- se provengo dal giro FLES restringo il recupero al solo CIG presente sulla tabella FLES_TABLE_MODIFICA_CONTRATTUALE in quanto lato FLES
							--		è sempre monolotto l'invio
							and ( ( @uuidFles <> '' and isnull(a.cig, @cigMonolotto ) = @cigFLES ) or ( @uuidFles = '' ) )

		END

	END
	ELSE 
	BEGIN
		
		select @TipoAggiudicazione = db.TipoAggiudicazione,
				@tipoDocGara = g.TipoDoc,
				@cigMonolotto = db.CIG
			from ctl_doc BG with(nolock)
					inner join document_bando db with(nolock) on db.idHeader = BG.LinkedDoc
					inner join ctl_doc g with(nolock) on g.id = db.idHeader
			where BG.id = @idProc


		--CANCELLO LE VECCHIE GENERAZIONI PER IDPROC
		delete from Document_E_FORM_BUFFER where IdProc=@idProc

		IF CHARINDEX(',', @numeroLotto) = 0 --se non si sta filtrando per numero lotto o se il lotto è unico
		BEGIN

			INSERT INTO Document_E_FORM_BUFFER (guid, idrow, infoType, strData1, strData2, idProc)
				SELECT
					@guidOperation,
					Id AS idrow,
					'LOTTI_CHIUSI' AS infoType,
					NumeroLotto AS strData1,
					'Revocato' AS strData2,
					@idProc AS idProc
					 FROM Document_MicroLotti_Dettagli WITH(NOLOCK)
						WHERE IdHeader = @idProc
		END
		ELSE
		BEGIN

			INSERT INTO Document_E_FORM_BUFFER (guid, idrow, infoType, strData1, strData2, idProc)
				SELECT
					@guidOperation,
					Id AS idrow,
					'LOTTI_CHIUSI' AS infoType,
					NumeroLotto AS strData1,
					'Revocato' AS strData2,
					@idProc AS idProc
					 FROM Document_MicroLotti_Dettagli WITH(NOLOCK)
					 INNER JOIN dbo.Split(@numeroLotto,',') s on s.items = NumeroLotto
						WHERE IdHeader = @idProc
		END
	END

END
GO
