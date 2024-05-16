USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CONTRATTO_GARA_FORN_CREATE_FROM_CONTRATTO_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_CONTRATTO_GARA_FORN_CREATE_FROM_CONTRATTO_GARA] ( @idContratto int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as int
	declare @errore varchar(1000)
	declare @idContrattoForn INT
	declare @ModelloBando as varchar(500)
	declare @nomeModello varchar(4000)
	declare @Filter as varchar(500)
	declare @DestListField as varchar(500)

	set @idContrattoForn = 0
	SET @errore = ''
	set @nomeModello = ''

	select @idContrattoForn = a.id
		from ctl_doc a with(nolock)
		where a.LinkedDoc = @idContratto and a.TipoDoc = 'CONTRATTO_GARA_FORN' and a.Deleted = 0

	IF isnull(@idContrattoForn,0) = 0
	BEGIN

		insert into CTL_DOC ( IdPfu,Titolo, TipoDoc, StatoFunzionale, Azienda, Body,	ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_Azi ,idPfuInCharge ) 
			select @IdUser,'Contratto', 'CONTRATTO_GARA_FORN','Inviato',  Azienda ,  Body,ProtocolloRiferimento, Fascicolo, @idContratto , Destinatario_Azi , 0
			from ctl_doc with(nolock)
			where id = @idContratto

		set @Id = SCOPE_IDENTITY()

		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
						select @Id , DSE_ID, Row, DZT_Name, Value
						from ctl_doc_value with(nolock)
						where IdHeader = @idContratto

		INSERT INTO CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma, FirmeRichieste, AllegatoRisposta )
								select @Id as idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma, FirmeRichieste, AllegatoRisposta
								from CTL_DOC_ALLEGATI with(nolock)
								where idHeader = @idContratto

		INSERT INTO CTL_DOC_SIGN ( idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK )
								select @Id as idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK
								from CTL_DOC_SIGN with(nolock)
								where idHeader = @idContratto
		 

		insert into ctl_approvalsteps (APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld)
			select top 1 'CONTRATTO_GARA_FORN',@Id,'Sent','','',isnull( attvalue,''),@IdUser,0 
			from profiliutenteattrib p  with(nolock)
			where  p.idpfu = @IdUser and dztnome = 'UserRoleDefault'

		select @ModelloBando = [value]
			from ctl_doc_value with(nolock)
			where idheader = @idContratto and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'ModelloBando'

		set @nomeModello = 'MODELLI_LOTTI_' + @ModelloBando + '_MOD_PERFEZIONAMENTO_CONTRATTO'

		-- SE ESISTE IL MODELLO SPECIFICO PER IL PERFEZIONAMENTO CONTRATTO, LO UTILIZZO. ALTRIMENTI USO QUELLO DEL CONTRATTO
		IF EXISTS ( select * from CTL_Models a with(nolock) where a.MOD_ID = @nomeModello )
		BEGIN

			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
				values	( @Id , 'BENI' , @nomeModello )	

		END
		ELSE
		BEGIN

			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
											select @Id, DSE_ID, MOD_Name
											from CTL_DOC_SECTION_MODEL with(nolock)
											where IdHeader = @idContratto and DSE_ID = 'BENI'

		END

		
		set @Filter = ' Tipodoc=''CONTRATTO_GARA'' '
		set @DestListField = ' ''CONTRATTO_GARA_FORN'' as TipoDoc, '''' as EsitoRiga '
		  
		exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idContratto, @Id, 'IdHeader', 
							' Id,IdHeader,TipoDoc,EsitoRiga ', 
							@Filter, 
							' TipoDoc, EsitoRiga ', 
							@DestListField,
							' id '


	END

END



GO
