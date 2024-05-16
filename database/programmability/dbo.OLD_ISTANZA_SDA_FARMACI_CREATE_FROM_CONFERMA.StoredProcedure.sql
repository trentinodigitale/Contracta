USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_SDA_FARMACI_CREATE_FROM_CONFERMA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_ISTANZA_SDA_FARMACI_CREATE_FROM_CONFERMA]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @idBando int

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @TipoDoc as varchar(150)
	declare @TipoBando as varchar(500)

	set @Errore = ''
	
	select @idBando = LinkedDoc , @azienda = azienda , @TipoDoc = TipoDoc , @TipoBando=TipoBando
		from CTL_DOC inner join document_bando on idheader=LinkedDoc 
		where id = @idDoc

	

	--controllo che la nuova istanza sia compatibile con il tipobando
	if @TipoDoc <> 'ISTANZA_' + @TipoBando 
	begin
	   set @Errore = 'Operazione non consentita. Istanza ha subito evoluzioni' 
	end

	----------------------------------------------------------------------------------------------------------------------------------
	-- BISOGNA AGGIUNGERE UN CONTROLLO CHE BLOCCA NEL CASO IN CUI TROVA I DATI ANAGRAFICI DELL'AZIENDA DIFFERENTI DAL DOCUMENTO
	----------------------------------------------------------------------------------------------------------------------------------
	-- controllo CHE LA CONFERMA può essere creata solo dallo stesso utente ,se l'idpfu = @IdUser  
	if exists( select * from CTL_DOC where id = @idDoc and idpfu <> @IdUser )
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita. La conferma non si può creare poichè l''istanza precedente è stata sottoposta da altro utente' 
	end



	-- controllo lo stato dell'istanza
	if exists( select * from CTL_DOC where id = @idDoc and StatoFunzionale not in ( 'Confermato','ConfermatoParz'  ) ) and @Errore = ''
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end


	if exists( select * from CTL_DOC_VIEW where id = @idDoc and CAN_CONFERMA = 'no' )  and @Errore = ''
	begin 
		-- rirorna l'errore
		set @Errore = 'Sono scaduti i termini per la creazione di una conferma automatica' 
	end


	if   @Errore = '' 
	begin 
	
		-- verifico la presenza di un documento precedente. in tal caso lo cancello e lo ricreo per sicurezza
		if exists( select id  from CTL_DOC where StatoDoc = 'Saved' and azienda = @azienda and LinkedDoc = @idBando )
		begin
			update CTL_DOC set deleted = 1 where StatoDoc = 'Saved' and azienda = @azienda and LinkedDoc = @idBando 
		end


		-- creo una copia dell'istanza
		INSERT into CTL_DOC ( IdPfu,  TipoDoc , idPfuInCharge )
			select @IdUser as idpfu , TipoDoc , @IdUser  as  idPfuInCharge 
				from CTL_DOC
				where id = @idDoc

		set @id = SCOPE_IDENTITY()

		-- ricopio tutti i valori
		exec COPY_RECORD  'CTL_DOC'  ,@idDoc  , @id , ',IdPfu,TipoDoc,ID,'
		
		-- svuoto i campi ed inserisco il flag per indicare che si tratta di una conferma
		update CTL_DOC set JumpCheck = 'Conferma' 
						, SIGN_HASH = '' 
						, SIGN_ATTACH = '' 
						, SIGN_LOCK = 0 
						, StatoFunzionale = 'InLavorazione'
						, DataScadenza = null
						, StatoDoc = 'Saved'
						, PrevDoc = @idDoc
						, Protocollo = ''
						, ProtocolloGenerale = ''
						, DataProtocolloGenerale = null
						, DataInvio = null
						, Data = getdate() 
						, idPfuInCharge = @IdUser
						,Versione='2'
			where id = @id 

		
		-- copio i dati delle altre tabelle
		insert into CTL_DOC_SIGN ( idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK )
			select @id as  idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK
				from CTL_DOC_SIGN  where idheader = @idDoc


		insert	CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value where idheader = @idDoc
		--Recupero il CF dell'azienda dall'anagrafica e lo aggiorna sulla nuova istanza
		execute INS_CTL_DOC_Value_DA_DMATTR @azienda, 'codicefiscale' , @id ,'TESTATA' 

		delete from CTL_DOC_Value where idheader = @id and DSE_ID = 'SCADENZA_ISTANZA' and DZT_Name = 'DataScadenzaIstanza'

		insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile,RichiediFirma )
			select  @id as  idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile ,RichiediFirma
				from CTL_DOC_ALLEGATI
					where IdHeader = @idDoc


		insert into Document_MicroLotti_Dettagli ( IdHeader	, TipoDoc , NumeroLotto , Voce , NumeroRiga )
			select @id as  IdHeader	, TipoDoc , NumeroLotto , Voce , NumeroRiga
				from Document_MicroLotti_Dettagli 
				where IdHeader = @idDoc and TipoDoc = @TipoDoc


		-- ricopio i dati dei lotti dal documento originale
		declare @sql varchar(4000)
		set @sql = 'select  S.ID , D.ID from Document_MicroLotti_Dettagli as D 	inner join Document_MicroLotti_Dettagli S on S.idheader = ' + cast( @idDoc as varchar ) + ' and S.TipoDoc = D.TipoDoc  and S.NumeroRiga = D.NumeroRiga  where D.idHeader = ' + cast( @id as varchar )
		exec COPY_DETTAGLI_MICROLOTTI @sql

		-- associo il modello per la visualizzazione dei prodotti
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			select @id as IdHeader, DSE_ID, MOD_Name 
				from CTL_DOC_SECTION_MODEL 
				where idheader = @idDoc

	   
		---------------------COPIA DGUE SE TROVA IL DOC LINKEDDOC ALLA PRECEDENTE----------------------------------------------------------------------  
	     exec DGUE_COPY_FROM_DOC @idDoc, @IdUser, @id

	end
		
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id, @TipoDoc as TYPE_TO
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END














GO
