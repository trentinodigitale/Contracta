USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CAMPI_NOT_EDITABLE_CONVENZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OLD2_CAMPI_NOT_EDITABLE_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @tipodoc as varchar(50)
	declare @PERMESSO_SUPER_CONV as varchar(50)
	declare @statofunzionale as varchar(50)	
	declare @utente as INT
	declare @idconv as INT
	declare @jumpcheck as varchar(50)	
	declare @NotEditable varchar(max)

	set @PERMESSO_SUPER_CONV = ''
	set @NotEditable = ''


	--recupero tipodoc del doc corrente in input
	Select @tipodoc=tipodoc from ctl_doc with(nolock) where id=@idDoc

	--recupero id convenzione 		
    IF @tipodoc = 'CONVENZIONE' 
    BEGIN
		set @idconv = @idDoc
	end

	
    IF @tipodoc in ( 'CONTRATTO_CONVENZIONE' , 'LISTINO_CONVENZIONE' , 'LISTINO_ORDINI')
    BEGIN
	   select @idconv=linkedDoc from ctl_doc  with(nolock) where id=@idDoc
	end

	--recupero jumpcheck che mi fa capire l'operazione a seconda di tipodoc
	Select @jumpcheck=ISNULL(jumpcheck,'') from ctl_doc with(nolock) where id=@idconv


	-----------------------------------------------------------------------
	-- l'utente che ha in carico la convenzione se non ha il permesso SUPER CONVENZIONE non ha abilitato la richiesta firma
	---------------------------------------------------------------------------

	--recupero l'utente che ha in carico la convenzione
	Select @utente=idpfuincharge from ctl_doc with(nolock) where id=@idconv

	--Controllo se ha il permesso di superuser Convenzione ovvero il 332
	Select @PERMESSO_SUPER_CONV=substring (pfufunzionalita, 332 , 1) from profiliUtente with(nolock) where idpfu=@utente

	--SE NON LO TIENE BLOCCO IL CAMPO RICHIESTA FIRMA
	IF ( @PERMESSO_SUPER_CONV = '0' )
	BEGIN
		--update document_convenzione set NotEditable=' RichiestaFirma '
		--where id=@idDoc

		set @NotEditable = @NotEditable +  ' RichiestaFirma '
	END



	---------------------------------------------------------------------
	-- se esiste il contratto
	---------------------------------------------------------------------
	if exists( select id from CTL_DOC with(nolock) where linkeddoc = @idConv 
				and tipodoc = 'CONTRATTO_CONVENZIONE' and deleted = 0 and statofunzionale not in ( 'Rifiutato','Richiamato' ) 
			  )
	begin
		set @NotEditable = @NotEditable + ' RichiestaFirma DescrizioneIniziativa  IdentificativoIniziativa  Titolo  Merceologia  AZI_Dest BDG_TOT_Residuo CodiceFiscaleReferente ConvNoMail DataProtocolloBando DescrizioneEstesa DOC_Name GestioneQuote ImportoAllocabile IVA Mandataria NewTotal NumOrd OggettoBando ProtocolloBando QtMinTot ReferenteFornitore ReferenteFornitoreHide RichiediFirmaOrdine RicPreventivo TipoEstensione TipoImporto TipoOrdine Total TotaleOrdinato Valuta Ambito Tipo_Modello_Convenzione Tipo_Modello_Convenzione_Scelta Acquisto_Sociale Appalto_Verde TipoConvenzione OrdinativiIntegrativi TipoScadenzaOrdinativo NumeroMesi ConAccessori Macro_Convenzione F2_SIGN_ATTACH F1_SIGN_ATTACH F3_SIGN_ATTACH ImportoMinimoOrdinativo Stipula_in_forma_pubblica ConvenzioniInUrgenza AllegatoDetermina ' 

    END	

	---------------------------------------------------------------------
	-- se esiste il listino blocco "Tipo Convenzione Completa", "Valore Accessorio", "Iva" , "Tipo Importo"
	---------------------------------------------------------------------
	if exists( select id from CTL_DOC with(nolock) where linkeddoc = @idConv 
				and tipodoc = 'LISTINO_CONVENZIONE' and deleted = 0 and statofunzionale not in ( 'Rifiutato','Richiamato' ) 
			  )
	begin
		set @NotEditable = @NotEditable + ' IVA  TipoConvenzione ConAccessori TipoImporto ' 

    END	

	---------------------------------------------------------------------
	-- se la convenzione è di integrazione
	---------------------------------------------------------------------
    IF @jumpcheck='INTEGRAZIONE'
    BEGIN
		set @NotEditable = @NotEditable + ' fascicoloSecondario DataFine RichiestaFirma DescrizioneIniziativa  IdentificativoIniziativa   Merceologia  AZI_Dest CodiceFiscaleReferente ConvNoMail DataProtocolloBando  GestioneQuote IVA Mandataria NumOrd ProtocolloBando QtMinTot ReferenteFornitore ReferenteFornitoreHide RichiediFirmaOrdine RicPreventivo TipoEstensione TipoImporto TipoOrdine Valuta Ambito Tipo_Modello_Convenzione Tipo_Modello_Convenzione_Scelta Acquisto_Sociale Appalto_Verde TipoConvenzione OrdinativiIntegrativi TipoScadenzaOrdinativo NumeroMesi DataScadenzaOrdinativo ConAccessori ImportoMinimoOrdinativo Macro_Convenzione ' 
    
    END


    -- se esiste la comunicazione inserisce nei campi non editabili la Mandataria
    --IF EXISTS ( select id from ctl_doc where LinkedDoc = @idconv and tipodoc = 'PDA_COMUNICAZIONE_GARA' and JumpCheck like '%COMUNICAZIONE_FORNITORE_CONVENZIONE' and deleted = 0 )  --StatoDoc <> 'Saved' )  
    --BEGIN

	   -- se nell'elenco delle non editabili manca la mandataria la aggiungo
	---  update document_convenzione set NotEditable = isnull( NotEditable  , '' ) + ' Mandataria '
	--	  where id=@idconv and isnull( NotEditable , '' ) not like '% Mandataria %' 
		--set @NotEditable = @NotEditable + ' Mandataria '

    --END
	
	--se ConvenzioniInUrgenza flaggato e ho fatto pubblica lascio i segenti campi editabile
	--Data Stipula Convenzione completa  (DataStipulaConvenzione)
	-- Scadenza     (DataFine) (E.P. viene bloccata in seguito alla messa a punto att. 443204)
	--Convenzione ( allegato)  (F2_SIGN_ATTACH)
	--clausola vessatoria ( allegato) (F1_SIGN_ATTACH)
	--altri allegati ( allegato)   (F3_SIGN_ATTACH)
	if @tipodoc = 'CONVENZIONE'  and exists ( select id from Document_Convenzione with(nolock) where ID = @idConv and ISNULL(ConvenzioniInUrgenza , 0) = 1 and StatoConvenzione = 'Pubblicato' )
	begin
		set @NotEditable = @NotEditable + ' RichiestaFirma DescrizioneIniziativa  IdentificativoIniziativa  Titolo  Merceologia  AZI_Dest BDG_TOT_Residuo CodiceFiscaleReferente ConvNoMail DataProtocolloBando DescrizioneEstesa DOC_Name GestioneQuote ImportoAllocabile IVA Mandataria NewTotal NumOrd OggettoBando ProtocolloBando QtMinTot ReferenteFornitore ReferenteFornitoreHide RichiediFirmaOrdine RicPreventivo TipoEstensione TipoImporto TipoOrdine Total TotaleOrdinato Valuta Ambito Tipo_Modello_Convenzione Tipo_Modello_Convenzione_Scelta Acquisto_Sociale Appalto_Verde TipoConvenzione OrdinativiIntegrativi TipoScadenzaOrdinativo NumeroMesi ConAccessori Macro_Convenzione ImportoMinimoOrdinativo Stipula_in_forma_pubblica ConvenzioniInUrgenza AllegatoDetermina DataScadenzaOrdinativo DataFine ' 
	end
	


	--se il cotratto è stato rifiutato e ConvenzioniInUrgenza flaggato lascio edatibili i campi 
	--Data Stipula Convenzione completa  (DataStipulaConvenzione)
	-- Scadenza     (DataFine)
	--Convenzione ( allegato)  (F2_SIGN_ATTACH)
	--clausola vessatoria ( allegato) (F1_SIGN_ATTACH)
	--altri allegati ( allegato)   (F3_SIGN_ATTACH)
	IF @tipodoc = 'CONTRATTO_CONVENZIONE'
		and exists (select id from CTL_DOC with(nolock) where linkeddoc = @idConv and tipodoc = 'CONTRATTO_CONVENZIONE' and deleted = 0 and statofunzionale in ( 'Rifiutato','Richiamato' ) )
		and exists ( select id from Document_Convenzione with(nolock)  where ID = @idConv and ISNULL(ConvenzioniInUrgenza , 0) = 1 )
	begin
		set @NotEditable = @NotEditable + ' RichiestaFirma DescrizioneIniziativa  IdentificativoIniziativa  Titolo  Merceologia  AZI_Dest BDG_TOT_Residuo CodiceFiscaleReferente ConvNoMail DataProtocolloBando DescrizioneEstesa DOC_Name GestioneQuote ImportoAllocabile IVA Mandataria NewTotal NumOrd OggettoBando ProtocolloBando QtMinTot ReferenteFornitore ReferenteFornitoreHide RichiediFirmaOrdine RicPreventivo TipoEstensione TipoImporto TipoOrdine Total TotaleOrdinato Valuta Ambito Tipo_Modello_Convenzione Tipo_Modello_Convenzione_Scelta Acquisto_Sociale Appalto_Verde TipoConvenzione OrdinativiIntegrativi TipoScadenzaOrdinativo NumeroMesi ConAccessori Macro_Convenzione ImportoMinimoOrdinativo Stipula_in_forma_pubblica ConvenzioniInUrgenza AllegatoDetermina DataScadenzaOrdinativo ' 
	end
	
	--se esiste il listino convenzione inviato op confermato allora blocco i seguenti campi
	--fornitore, referente,le info di testata prodotti e i prodotti 
	--sono bloccati dalla condizione sulla testata
	if exists
			(
				select id from ctl_doc with (nolock) 
					where linkeddoc = @idconv and tipodoc ='LISTINO_CONVEZIONE' 
						and StatoFunzionale in ( 'Inviato','Confermato' ) and Deleted=0
			)
	begin
		set @NotEditable = @NotEditable + ' Titolo Merceologia Mandataria AZI_Dest CodiceFiscaleReferente ReferenteFornitore ReferenteFornitoreHide Tipo_Modello_Convenzione_Scelta Ambito Tipo_Modello_Convenzione '
	end

	--se esiste il listino ordini inviato allora blocco i seguenti campi
	--(fornitore, referente, PresenzaListinoOrdini le info di testata prodotti e i prodotti 
	--sono bloccati dalla condizione sulla testata
	if exists (select id from ctl_doc with (nolock) 
					where linkeddoc = @idconv and tipodoc ='LISTINO_ORDINI' 
						and StatoFunzionale <> 'InLavorazione' and Deleted=0)
			
	begin
		set @NotEditable = @NotEditable + ' PresenzaListinoOrdini Titolo Merceologia Mandataria AZI_Dest CodiceFiscaleReferente ReferenteFornitore ReferenteFornitoreHide Tipo_Modello_Convenzione_Scelta Ambito Tipo_Modello_Convenzione '
	end

	---------------------------------------------------------------------
	-- aggiorno il campo dei non editabili sulla convenzione
	---------------------------------------------------------------------
	update 
		document_convenzione 
			set NotEditable = @NotEditable
		where id=@idconv 



END










GO
