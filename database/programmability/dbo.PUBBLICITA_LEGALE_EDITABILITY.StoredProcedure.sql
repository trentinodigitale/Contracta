USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PUBBLICITA_LEGALE_EDITABILITY]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[PUBBLICITA_LEGALE_EDITABILITY] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @statofunzionale as varchar(100)
	declare @jumpcheck as varchar (100)
	declare @protbando as varchar (50)
	declare @fascicolo as varchar (50)
	declare @tipoappalto as varchar (50)
	declare @importo as int 
	declare @pratica as varchar (50)
	declare @value as varchar(8000)
	declare @statofunzdoc as varchar(100)
	set @value=''


	-- RECUPERO LE INFORMAZIONI SUL DOCUMENTO
	select 
			@statofunzionale='%,' + statofunzionale + ',%' , 
			@jumpcheck=JumpCheck,
			@statofunzdoc=StatoFunzionale
		
		from CTL_DOC with(nolock) 
			
		where Id=@idDoc
	

	-------------------------------------------------------------
	-- GESTISCO I CAMPI NON EDITABILI
	-------------------------------------------------------------


	-- nel caso in cui il documento di pubblicità legale sia stato creato da un 
	-- pregara i seguenti attributi sono ereditati e quindi non possono essere cambiati
	if exists (SELECT * FROM CTL_DOC WITH(NOLOCK) WHERE id=@idDoc and isnull(LinkedDoc,0)<>0)
	begin
		set @Value=' Fascicolo Protocol Tipologia Importo '
	end

	-- aggiungiamo altri attributi che dobbiamo rendere non editabili in funzione dello stato, possono essere configurati 
	-- per consentire una parametrizzazione sul cliente
	select 
			@value=@value + ' ' + REL_ValueOutput + ' ' 
			
		from CTL_Relations with(nolock) 
		where rel_type='PUBBLICITA_LEGALE_NOT_EDITABLE'--'DOCUMENT_PREGARA_NOT_EDITABLE_STRATEGIA_For_Stato' 
			 and REL_ValueInput like @statofunzionale 


	--definiamo l'editabilià per i campi dell allegato IOL per il controllo del file firmato
	if @statofunzdoc<>'PubblicazioneAvviata'
		set @value=@value +' F1_SIGN_ATTACH ' 

	if @statofunzdoc not in ( 'PubblicazioneDaFir','TrasmissioneA_IOLNonApp')
		set @value=@value +' F2_SIGN_ATTACH ' 

	-- aggiorniamo i campi non editabili
	IF EXISTS (SELECT * FROM CTL_DOC_VALUE WITH(NOLOCK) WHERE IdHeader=@idDoc and DSE_ID='NOT_EDITABLE' and DZT_Name='Not_Editable')
	BEGIN 

		update CTL_DOC_Value set Value=@value
			where IdHeader=@idDoc and DSE_ID='NOT_EDITABLE' and DZT_Name='Not_Editable'

	end
	else
	begin

		INSERT INTO CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name, value)
			VALUES ( @idDoc,'NOT_EDITABLE','Not_Editable' , @value )

	end



	-------------------------------------------------------------
	-- GESTISCO LE SEZIONI NON EDITABILI
	-------------------------------------------------------------

	SET @value=''
	--RECUPERO LE SEZIONI EDITABILI IN FUNZIONE DELLO STATO DEL DOCUMENTO 
	select 
		@value=@VALUE + REL_ValueOutput 

		from CTL_Relations with(nolock) 
		where rel_type='PUBBLICITA_LEGALE_SECTION_EDITABLE'
			 and REL_ValueInput like @statofunzionale 

	IF EXISTS (SELECT * FROM CTL_DOC_VALUE WITH(NOLOCK) WHERE IdHeader=@idDoc and DSE_ID='SECTION_EDITABLE' and DZT_Name='SECTION_EDITABLE')
	BEGIN 
		update CTL_DOC_Value set Value=@value
			where IdHeader=@idDoc and DSE_ID='SECTION_EDITABLE' and DZT_Name='SECTION_EDITABLE'
	END
	ELSE
	BEGIN
		INSERT INTO CTL_DOC_Value (VALUE,IdHeader,DSE_ID,DZT_Name)
			VALUES (@VALUE,@idDoc,'SECTION_EDITABLE','SECTION_EDITABLE')
	END


	--RELAZIONE SECTION_VISIBLE


	-------------------------------------------------------------
	-- DETERMINO LE RIGHE PER I DATI DEI QUOTIDIANI
	-------------------------------------------------------------

	--aggiungo o elimino le righe relative ai quotidiani
	if @jumpcheck='GURI'
	BEGIN
		IF NOT EXISTS (SELECT * FROM Document_RicPrevPubblic_Quotidiani WHERE idHeader=@idDoc)
		BEGIN 
			insert into Document_RicPrevPubblic_Quotidiani (idHeader,giornale,Fornitore,importo,CostoBollo,Allegato) 
				select @idDoc,'Guri',null,0,0,'' from Document_RicPrevPubblic where idheader=@idDoc
		END


		-- TRAVASO L'HASH DEL FILE IOL PER VERIFICARE CHE QUELLO FIRMATO CORRISPONDA ALL'ORIGINALE
		UPDATE CTL_DOC_SIGN set F2_SIGN_HASH = F1_SIGN_HASH where idHeader = @idDoc
	END



	if @jumpcheck='QUOTIDIANI'
	BEGIN
		declare @numquotEsistenti as int
		declare @numquot as int
		set @numquot=0
		select @numquot=NumQuotReg+NumQuotNaz from Document_RicPrevPubblic D INNER JOIN CTL_DOC C ON C.ID=D.IdHeader where c.id=@idDoc and  NumQuotReg+NumQuotNaz>0 AND c.JumpCheck='QUOTIDIANI' 
		SELECT @numquotEsistenti=count(*) FROM Document_RicPrevPubblic_Quotidiani WHERE idHeader=@idDoc
		 
		--INSERISCO LE RIGHE PER I QUOTIDIANI RICHIESTI
		WHILE (@numquotEsistenti<@numquot)
		BEGIN  
			insert into Document_RicPrevPubblic_Quotidiani (idHeader,giornale,Fornitore,importo,CostoBollo,Allegato) 
				select @idDoc,'','',0,0,'' from Document_RicPrevPubblic where idheader=@idDoc
			SET @numquotEsistenti=@numquotEsistenti+1
		end
		WHILE (@numquotEsistenti>@numquot)
		BEGIN  
			DELETE FROM Document_RicPrevPubblic_Quotidiani WHERE idHeader=@idDoc AND  idRow=(select max (idrow) from Document_RicPrevPubblic_Quotidiani where idHeader=@idDoc)
			SET @numquotEsistenti=@numquotEsistenti-1	
		end
	END





END



GO
