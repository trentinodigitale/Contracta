USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ISTANZA_AlboOperaEco_CREATE_FROM_CONFERMA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[OLD2_ISTANZA_AlboOperaEco_CREATE_FROM_CONFERMA]
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

	set @Errore = ''
	
	select @idBando = LinkedDoc , @azienda = azienda from CTL_DOC where id = @idDoc

	
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
	if exists( select * from CTL_DOC where id = @idDoc and StatoFunzionale not in ( 'Confermato','ConfermatoParz'  ) ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end


	if exists( select * from CTL_DOC_VIEW where id = @idDoc and CAN_CONFERMA = 'no' ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Sono scaduti i termini per la creazione di una conferma automatica' 
	end



	if   @Errore = '' 
	begin 
	

		-- verifico la presenza di un documento precedente. in al caso lo cancello e lo ricreo per sicurezza
		if exists( select id  from CTL_DOC where StatoDoc = 'Saved' and azienda = @azienda and LinkedDoc = @idBando )
		begin
			update CTL_DOC set deleted = 1 where StatoDoc = 'Saved' and azienda = @azienda and LinkedDoc = @idBando 
		end


		-- creo una copia dell'istanza
		INSERT into CTL_DOC ( IdPfu,  TipoDoc  )
			select @IdUser as idpfu , TipoDoc   
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
			where id = @id 

		
		-- copio i dati delle altre tabelle
		insert into CTL_DOC_SIGN ( idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK )
			select @id as  idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK
				from CTL_DOC_SIGN  where idheader = @idDoc


		insert	CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value where idheader = @idDoc 
				
		--Recupero il CF dell'azienda dall'anagrafica e lo aggiorna sulla nuova istanza
		execute Upd_CTL_DOC_Value_DA_DMATTR @azienda, 'codicefiscale' , @id ,'TESTATA' 

		--Recupero le classi_iscrizione dalla precedente conferma e le inserisco sulla nuova istanza
		
		--risalgo alla conferma iscrizione fatta sulla precedente istanza e mi vado a prendere le classi
		declare @classiconferma as nvarchar(MAX)
		select @classiconferma=value 
			from ctl_doc 
			inner join CTL_DOC_Value on Id=IdHeader and DSE_ID='CLASSI' and DZT_Name='ClasseIscriz'
			where tipodoc='CONFERMA_ISCRIZIONE' and linkeddoc=@idDoc and StatoFunzionale='Notificato'

		update CTL_DOC_Value set Value=Replace(@classiconferma,'###0###','###')
		where IdHeader=@id and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz'


		
		---RIMUOVO LE CLASSIISCRIZ NON PRESENTI NEL DOMINIO 
		DECLARE @classi_ok as varchar(MAX)
		set @classi_ok='###'

		select @classi_ok=@classi_ok + items + '###' from dbo.Split((select value from CTL_DOC_Value where IdHeader=@id and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz'),'###')
		inner join ClasseIscriz on DMV_Cod=items and dmv_deleted=0

		update CTL_DOC_Value set value=@classi_ok
		 where IdHeader=@id and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' 






		delete from CTL_DOC_Value where idheader = @id and DSE_ID = 'SCADENZA_ISTANZA' and DZT_Name = 'DataScadenzaIstanza'


		insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile )
			select  @id as  idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile 
				from CTL_DOC_ALLEGATI
					where IdHeader = @idDoc
					
			
		if @Errore = ''
		begin
			-- rirorna l'id della nuova comunicazione appena creata
			select @Id as id
		
		end
		else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
	
	END

END













GO
