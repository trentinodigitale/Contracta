USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONTRATTO_PDF_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--drop procedure VERBALEGARA_CREATE_FROM_CONVENZIONE


CREATE  PROCEDURE [dbo].[CONTRATTO_PDF_CREATE_FROM_CONVENZIONE] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;



	declare @Id as INT
	declare @idSorgente as INT
	declare @Jumpcheck as varchar(100)	
	declare @Errore as nvarchar(4000)
	declare @contatore as varchar(50)
	declare @NumOrd as varchar(50)

	set @Errore = ''
	


	select top 1 @idSorgente  = id 
		from CTL_DOC 
			inner join dbo.Document_VerbaleGara on id = idheader and TipoSorgente = '8' -- Contratto convenzione
		where tipodoc = 'VERBALETEMPLATE' and deleted = 0 and StatoFunzionale = 'Pubblicato'
		order by id desc	

	if @idSorgente is null
	begin
		set @Errore = dbo.CNV( 'Non esiste il template per la creazione del contratto. Provvedere alla creazione con le funzioni di amministratore prima di proseguire' , 'I' )
	end

	-- cerco una versione precedente del documento se esiste


	set @id = null
	select @id = id 
		from CTL_DOC 
		where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONTRATTO_PDF' ) 
			and statoFunzionale in ( 'InLavorazione' , 'Lavorato')  and isnull(Jumpcheck,'') = 'CONTRATTO'

	if @id is null and @Errore = ''
	begin
	   -- altrimenti lo creo
		INSERT into CTL_DOC (IdPfu,  TipoDoc, LinkedDoc ,jumpcheck ,  Titolo)
			VALUES (@IdUser  , 'CONTRATTO_PDF'  ,  @idDoc , 'CONTRATTO' , 'Contratto Convenzione' )

		set @id = @@identity

		insert into Document_VerbaleGara (  IdHeader, ProceduraGara, CriterioAggiudicazioneGara, Testata, PiePagina, Testata2, Multiplo, IdTipoVerbale, TipoVerbale, TipoSorgente, CriterioFormulazioneOfferte )
			select  @id as IdHeader, ProceduraGara, CriterioAggiudicazioneGara, Testata, PiePagina, Testata2, Multiplo, IdTipoVerbale, TipoVerbale, TipoSorgente, CriterioFormulazioneOfferte 
				from Document_VerbaleGara
				where  IdHeader = @idSorgente
		


		insert into Document_VerbaleGara_Dettagli ( IdHeader, Pos, SelRow, TitoloSezione, DescrizioneEstesa, Edit, CanEdit, Expression ) 
			select @id as IdHeader, Pos, SelRow, TitoloSezione, DescrizioneEstesa, Edit, CanEdit, Expression
				from Document_VerbaleGara_Dettagli
				where  IdHeader = @idSorgente

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
				values( @id , 'TESTATA1' , 'VERBALEGARA_TESTATA_CONTRATTO_CONVENZIONE' )

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
				values( @id , 'FIRMA' , 'VERBALE_GARA_CONTRATTO_CONVENZIONE_FIRMA' )
				
				

		-- blocco i campi sulla testata che definiscono i dati del contratto
		update Document_Convenzione 
			set NotEditable = ' DescrizioneIniziativa  IdentificativoIniziativa  Titolo  Merceologia  AZI_Dest BDG_TOT_Residuo CodiceFiscaleReferente ConvNoMail DataProtocolloBando DescrizioneEstesa DOC_Name GestioneQuote ImportoAllocabile IVA Mandataria NewTotal NumOrd OggettoBando ProtocolloBando QtMinTot ReferenteFornitore ReferenteFornitoreHide RichiediFirmaOrdine RicPreventivo TipoEstensione TipoImporto TipoOrdine Total TotaleOrdinato Valuta Ambito Tipo_Modello_Convenzione ' 
			where id = @idDoc

		--Genero numord se è vuoto
		Select  @NumOrd=ISNULL(NumOrd,'') from Document_Convenzione where id=@idDoc
		
		if ( @NumOrd='' ) 
		BEGIN
			exec CTL_GetNewProtocol 'CONVENZIONE','',@contatore output
			update Document_Convenzione 
				set NumOrd=@contatore
			where id = @idDoc
		END


	end

	
	
	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END



















GO
