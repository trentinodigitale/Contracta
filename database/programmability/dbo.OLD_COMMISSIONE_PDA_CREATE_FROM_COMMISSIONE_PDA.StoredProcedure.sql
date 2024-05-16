USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COMMISSIONE_PDA_CREATE_FROM_COMMISSIONE_PDA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OLD_COMMISSIONE_PDA_CREATE_FROM_COMMISSIONE_PDA] 
	( @idDoc int , @IdUser int , @forzaCopia int = 0, @idCommissioneOut int = 0 out )
AS
BEGIN
	SET NOCOUNT ON
	
	declare @id as int
	declare @Jumpcheck as varchar(100)
	declare @LinkedDoc as int
	declare @IdDocFrom as int
	declare @Conformita as varchar(20)
	declare @Errore as nvarchar(2000)
	declare @TipoDoc  varchar(250)
	set @Errore = ''

	--recupero info del bando
	select 
		@Jumpcheck=jumpcheck
		,@LinkedDoc=LinkedDoc
	from CTL_DOC where id = @idDoc

	-- recupero il tipo doc del bando

	select @TipoDoc = a.TipoDoc 
	from CTL_DOC a with(nolock)
		inner join CTL_DOC b on a.id = b.LinkedDoc
	where b.id = @idDoc

	--cerco un documento in lavorazione
	set @id = null
	IF @forzaCopia = 0
	BEGIN
		--select @id = id from CTL_DOC where prevdoc = @idDoc and deleted = 0 and TipoDoc = 'COMMISSIONE_PDA' and jumpcheck=@Jumpcheck and statofunzionale = 'InLavorazione' 
		select @id = id from CTL_DOC where deleted = 0 and TipoDoc = 'COMMISSIONE_PDA' and jumpcheck=@Jumpcheck and statofunzionale = 'InLavorazione'  and linkeddoc=@LinkedDoc

	
			--verifica se l'utente che sta creando la commissione è utente che ha creato la gara, rup oppure riferimento
			IF NOT EXISTS ( select * from CTL_DOC C
								inner join ctl_doc C1 on  C1.id=C.LinkedDoc
								left join Document_Bando_Riferimenti  DR on C1.id=DR.idHeader and DR.RuoloRiferimenti='Bando' 
								left join CTL_DOC_Value CV on CV.IdHeader=c1.id and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' 
								where C.id=@idDoc and ( ISNULL(DR.idpfu,0) = @idUser or C1.idPfu = @idUser or ISNULL(CV.Value,0) = @idUser ) 
						  )
				and
				not exists( select * from profiliutenteattrib where idpfu = @idUser and dztnome = 'Profilo' and attvalue = 'SuperUserRDO' )
			
			BEGIN
				set @Errore='Operazione non possibile utente non abilitato. Solo il compilatore del "Bando", gli utenti fra i riferimenti del bando come "Bando/Invito", il responsabile del procedimento possono creare la commissione.'
			END
	END


	-- se non esiste lo creo
	if @id is null and  @errore=''
	begin		
	
		--recupero ultimo doc pubblicato
		select @IdDocFrom=id from CTL_DOC where deleted = 0 and TipoDoc = 'COMMISSIONE_PDA' and statofunzionale = 'Pubblicato' and @LinkedDoc=LinkedDoc

		--faccio la copia dell'ultimo pubblicato
		INSERT into CTL_DOC (
			IdPfu,  TipoDoc, 
			Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Fascicolo,idPfuInCharge )
		select top 1 
			@IdUser,  TipoDoc, 
			Titolo,LinkedDoc,@idDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Fascicolo,@IdUser
		from CTL_DOC where id = @IdDocFrom

		set @id = @@identity

		--popolo la modifica con i dati precedenti
		Insert into ctl_doc_value 
		select 
			@id, DSE_ID, Row, DZT_Name, Value
		from ctl_doc_value where idheader = @idDoc and dse_id='TESTATA'


		--update record della conformita prendendolo dal bando
		select @Conformita=Conformita from document_Bando where idheader = @LinkedDoc	
		update ctl_doc_value set  Value =@Conformita where  idheader=@id and dzt_name='Conformita' and dse_id='TESTATA' 

		insert into CTL_DOC_ALLEGATI
			( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID )
			select 
				@id, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, 	
				case Anagdoc
					when 'VariazioneCommissione' then '  AnagDoc  Descrizione  DataEmissione  Allegato  '
					else ''
				end as NotEditable,
			 TipoFile, DataScadenza, DSE_ID

			from 
				CTL_DOC_ALLEGATI
			where idheader=@IdDocFrom
		
		--ricopio le commissioni
		insert into Document_CommissionePda_Utenti
			(IdHeader, UtenteCommissione, RuoloCommissione, TipoCommissione, CodiceFiscale, Nome, Cognome, RagioneSociale,RuoloUtente,EMAIL,Allegato,UtentePresente, AllegatoFirmato)
			select 
				@id, UtenteCommissione, RuoloCommissione, TipoCommissione, CodiceFiscale, Nome, Cognome, RagioneSociale,RuoloUtente,EMAIL,Allegato,UtentePresente, AllegatoFirmato
			from 
				Document_CommissionePda_Utenti
			where idheader=@IdDocFrom

		--ricopio i settaggi di blocco
		insert into document_CommissionePda_Blocco
			(IdHeader, Busta, BloccoBusta)
			select 
				@id, Busta, BloccoBusta
			from 
				document_CommissionePda_Blocco
			where idheader=@IdDocFrom
	end
	else
	begin
		--forzo come utente del documento l'utente corrente
		update ctl_doc set IdPfu=@IdUser,idPfuInCharge = @IdUser where id=@Id
	end	

		-- Usiamo i modelli dinamici ed in caso di tipoDoc uguale a BANDO_CONCORSO allora aggiungiamo in tabella i due modelli ad hoc
	if @TipoDoc in ( 'BANDO_CONCORSO') and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @id and DSE_ID in ( 'GIUDICATRICE', 'AGGIUDICATRICE' ) )
	begin
		INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
			VALUES ( @id, 'GIUDICATRICE', 'COMMISSIONE_PDA_CONCORSO_GIUDICATRICE' )

		INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
			VALUES ( @id, 'AGGIUDICATRICE', 'COMMISSIONE_PDA_CONCORSO_AGGIUDICATRICE' )					
	end

	IF @forzaCopia = 0
	BEGIN
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
	ELSE
		SET @idCommissioneOut = @id
	
		
END

GO
