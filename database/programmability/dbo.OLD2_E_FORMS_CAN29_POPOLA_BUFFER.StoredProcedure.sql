USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_E_FORMS_CAN29_POPOLA_BUFFER]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_E_FORMS_CAN29_POPOLA_BUFFER] ( @idPDA int , @idUser int = 0, 
														@guidOperation varchar(500) = '', 
														@numeroLotto varchar(1000) = '',
														@idDocContrConv int = 0)
AS
BEGIN

	--PER VELOCIZZARE LA PRODUZIONE DELL'XML SALVIAMO IN UNA TABELLA DI "CACHE" GLI ID DEI LOTTI CON STATO "TERMINALE". L'AGGANCIO È UN GUID PASSATO DAL CHIAMANTE
	--	QUESTI DATI POI VERRANNO USATI NELLE CHIAMATE/STORED SUCCESSIVE

	SET NOCOUNT ON

	DECLARE @TipoAggiudicazione varchar(100) = ''
	DECLARE @idProc INT = 0
	DECLARE @tipoDocGara varchar(100) = ''

	select @TipoAggiudicazione = db.TipoAggiudicazione,
			@idProc = db.idHeader,
			@tipoDocGara = g.TipoDoc
		from ctl_doc pda with(nolock)
				inner join document_bando db with(nolock) on db.idHeader = pda.LinkedDoc
				inner join ctl_doc g with(nolock) on g.id = db.idHeader
		where pda.id = @idPDA

	--CANCELLO LE VECCHIE GENERAZIONI PER IDPROC
	delete from Document_E_FORM_BUFFER where IdProc=@idProc


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

	END

END
GO
