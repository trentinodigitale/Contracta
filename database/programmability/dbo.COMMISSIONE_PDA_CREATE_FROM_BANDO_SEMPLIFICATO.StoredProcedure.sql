USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COMMISSIONE_PDA_CREATE_FROM_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[COMMISSIONE_PDA_CREATE_FROM_BANDO_SEMPLIFICATO] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @ProtocolBG  varchar(50)
	declare @TipoDoc  varchar(250)
	declare @PrevDoc as INT
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	
	set @PrevDoc=0
	set @Id = 0

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select @ProtocolBG = Fascicolo--ProtocolBG 
			, @TipoDoc = TipoDoc
				from CTL_DOC with (nolock)
					where Id = @idDoc	
	
	-- cerco la prima in lavorazione senza doc precedenti
	select @Id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and TipoDoc = 'COMMISSIONE_PDA' and deleted = 0 and statofunzionale = 'InLavorazione' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc and isnull(prevdoc,0)=0
	
	-- se non esiste cerco una versione pubblicata (valida)
	if isnull(@Id , 0 ) = 0 
		select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = 'COMMISSIONE_PDA' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc  and statofunzionale = 'Pubblicato'
	
	--verifica se l'utente che sta creando la commissione è utente che ha creato la gara, rup oppure riferimento
	IF NOT EXISTS ( select * from ctl_doc C1  with (nolock)
						left join Document_Bando_Riferimenti  DR with (nolock) on C1.id=DR.idHeader and DR.RuoloRiferimenti='Bando' 
						left join CTL_DOC_Value CV with (nolock) on CV.IdHeader=c1.id and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' 
						where C1.id=@idDoc and ( ISNULL(DR.idpfu,0) = @idUser or C1.idPfu = @idUser or ISNULL(CV.Value,0) = @idUser ) 
				  )
	BEGIN
		set @Errore='Operazione non possibile utente non abilitato. Solo il compilatore del "Bando", gli utenti fra i riferimenti del bando come "Bando/Invito", il responsabile del procedimento possono creare la commissione.'
	END
	
	-- se non viene trovato allora si crea il nuovo documento
	if isnull(@Id , 0 ) = 0  and  @errore=''
	begin

		--recupero un eventuale precedente proroga inviata
		Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			from 
				CTL_DOC with (nolock)
			where 
				LinkedDoc=@idDoc and tipodoc='COMMISSIONE_PDA' and Statofunzionale='Pubblicato' and deleted=0
				and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc

		--creo il nuov documento
		INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Fascicolo,idPfuInCharge )
				select 
						@IdUser as idpfu , 'COMMISSIONE_PDA' as TipoDoc ,  
						'Commissione gara Num. ' + d.Protocollo as Titolo,  
						 @idDoc as LinkedDoc,@PrevDoc, @TipoDoc ,d.Body,d.Protocollo,CIG,@ProtocolBG,@idUser
					from CTL_DOC d with (nolock)
						inner join document_Bando b with (nolock) on d.id = b.idheader
					where Id = @idDoc
		
		set @Id = @@identity

		----recupero tutti i dati del Bando
		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			select 
				@id,'TESTATA','ProtocolloBando',ProtocolloBando
				from 
					document_Bando with (nolock)
				where idheader = @idDoc


		--select ProtocolloBando,cig,CriterioAggiudicazioneGara from document_Bando where idheader=68803

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			select  @id,'TESTATA','CIG',CIG  
				from document_Bando  with (nolock)
				where idheader = @idDoc
		
		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			select  @id,'TESTATA','Descrizione',Body
				from CTL_DOC  with (nolock) where Id = @idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			select 
				@id,'TESTATA','CriterioAggiudicazioneGara',criterioaggiudicazionegara
				from document_Bando  with (nolock) where idheader = @idDoc			

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			select 
				@id,'TESTATA','Conformita',Conformita
				from document_Bando  with (nolock) where idheader = @idDoc	

		--popolo la modifica con i dati precedenti
		if @PrevDoc<>0
		begin
			insert into CTL_DOC_ALLEGATI
				( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID	)
				select 
					@id, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID	
					from 
						CTL_DOC_ALLEGATI  with (nolock)
					where idheader=@PrevDoc
			
			insert into Document_CommissionePda_Utenti
				(IdHeader, UtenteCommissione, RuoloCommissione, TipoCommissione)
				select 
					@id, UtenteCommissione, RuoloCommissione, TipoCommissione
					from 
						Document_CommissionePda_Utenti  with (nolock)
					where idheader=@PrevDoc
		end
	end

	-- Usiamo i modelli dinamici ed in caso di tipoDoc uguale a BANDO_CONCORSO allora aggiungiamo in tabella i due modelli ad hoc
	if @TipoDoc in ( 'BANDO_CONCORSO') and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @id and DSE_ID in ( 'GIUDICATRICE', 'AGGIUDICATRICE' ) )
	begin
		INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
			VALUES ( @id, 'GIUDICATRICE', 'COMMISSIONE_PDA_CONCORSO_GIUDICATRICE' )

		INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
			VALUES ( @id, 'AGGIUDICATRICE', 'COMMISSIONE_PDA_CONCORSO_AGGIUDICATRICE' )					
	end

	if @Errore = ''
	begin
		-- rirorna l'id della Commissione
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	

END

GO
