USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PROROGA_BANDO_CREATE_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_PROROGA_BANDO_CREATE_FROM_BANDO_SDA]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @PrevDoc as INT
	
	set @Id=0
	
	declare @Errore as nvarchar(2000)

	declare @IdPfu as INT

	set @Errore = ''
	--controllo se l'utente che sta facendo l'operazione è tra i riferimenti del bando oppure è il RUP
	IF NOT EXISTS (
					
					select * from ctl_doc 
					inner join Document_Bando_Riferimenti  DR on id=DR.idHeader
					inner join Document_Bando_Commissione  DC on id=DC.idHeader and RuoloCommissione='15550'
					where id=@idDoc and ( DR.idpfu=@IdUser or DC.idPfu=@IdUser )

				   )
	BEGIN	
		set @Errore = 'L''estensione puo essere creata solo dagli utenti fra i riferimenti del bando oppure dal responsabile del procedimento'
	END

	---controllo se per quel bando esiste una rettifica
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='REVOCA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di estensione non puo essere creato se non viene conclusa la revoca in corso sul bando'
	END
	---controllo se per quel bando esiste una proroga/estensione
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RETTIFICA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di estensione non puo essere creato se non viene conclusa la rettifica in corso sul bando'
	END

	-- controllo se esiste una rettifica in corso
	select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='PROROGA_BANDO' and statofunzionale in ('InLavorazione','InApprove')
	if ( @id IS NULL or @id=0 ) and  @Errore = '' 
	begin 
	
		
		 --recupero un eventuale precedente proroga inviata
		 Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
		from CTL_DOC where LinkedDoc=@idDoc and tipodoc='PROROGA_BANDO' and Statofunzionale='Inviato'
		
		--inserisco nella ctl_doc		
		insert into CTL_DOC (
				IdPfu, TipoDoc, Titolo,ProtocolloRiferimento, NumeroDocumento, Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck,Caption,PrevDoc,Azienda)
			select
				 @idUser ,  'PROROGA_BANDO'  , 'Estensione Bando Num. ' + Protocollo as Titolo , 
				 Protocollo ,CIG , Fascicolo , @idDoc  ,'InLavorazione',@idUser , 'BANDO_SDA','Estensione Bando SDA',@PrevDoc,Azienda
			from ctl_doc
			inner join document_bando on idHeader=id
			where Id = @idDoc

		set @Id = @@identity	

		---inserisco il modello specifico per la testata
		insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		values (@Id,'TESTATA','PROROGA_BANDO_SDA_2_TESTATA')

		--inserisce oggetto del bando sulla rettifica
		Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @Id,'TESTATA','Descrizione',body
		from ctl_doc where id=@idDoc


		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 	@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenza, 126)
		from ctl_doc where id=@idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 
		@id,'TESTATA','DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenza, 126)
		from ctl_doc where id=@idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 
		@id,'TESTATA','DataPresentazioneRisposteDal',CONVERT(nvarchar(30), DataPresentazioneRisposte, 126)
		from document_bando where idheader=@idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 
		@id,'TESTATA','OLD_DataPresentazioneRisposteDal',CONVERT(nvarchar(30), DataPresentazioneRisposte, 126)
		from document_bando where idheader=@idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 
		@id,'TESTATA','MotivoEstensionePeriodo',CONVERT(nvarchar(30), MotivoEstensionePeriodo, 126)
		from document_bando where idheader=@idDoc

		Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		select 
		@id,'TESTATA','OLD_MotivoEstensionePeriodo',CONVERT(nvarchar(30), MotivoEstensionePeriodo, 126)
		from document_bando where idheader=@idDoc

		

		--se la data DataPresentazioneRisposteDal è superata non consento di editare il campo
		if EXISTS (Select * from Document_Bando where idHeader=@idDoc and getdate() > DataPresentazioneRisposte )
		BEGIN
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			VALUES (@id,'TESTATA','Not_Editable',' DataPresentazioneRisposteDal ')
		
		END

		--inserisce nello storico la creazione
		insert into CTL_ApprovalSteps (APS_Doc_Type,APS_ID_DOC,APS_State,APS_IsOld,APS_IdPfu)
		values ('PROROGA_BANDO',@Id,'Compiled',1,@idUser)
		
		
		
	end

	

	if @Errore = ''
	begin
		
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END














GO
