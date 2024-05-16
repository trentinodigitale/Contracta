USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PROROGA_GARA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[OLD_PROROGA_GARA_CREATE_FROM_BANDO_GARA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	
	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	-- cerco una versione precedente del documento 
	set @id = null
	select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PROROGA_GARA' ) and statofunzionale in ( 'InLavorazione', 'InAttesaTed' )

	IF EXISTS ( select id from ctl_doc with (nolock) where LinkedDoc=@idDoc and TipoDoc='RETTIFICA_GARA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di proroga non puo essere creato se non viene conclusa la rettifica in corso sul bando'
	END
		
	IF EXISTS ( select id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and jumpcheck = '0-REVOCA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di proroga non puo essere creato se non viene conclusa la revoca in corso sul bando'
	END
		
	--non posso creare la proroga se esite un doc PUBBLICA_GARA_TED 
	IF EXISTS ( select id 
					from 
						CTL_DOC with (nolock) 
					where 
						TipoDoc = 'PUBBLICA_GARA_TED'  and LinkedDoc = @idDoc 
						and deleted = 0 and StatoFunzionale='InAttesaPubTed' 
				)
	BEGIN
		set @Errore = 'Non e possibile procedere con la proroga in quanto esiste una richiesta di pubblicazione GUUE nello stato In attesa di pubblicazione TED'
	END

	-- se non esiste lo creo
	if @id is null and @Errore=''
	begin
			-- altrimenti lo creo
			--recupero un eventuale precedente proroga inviata
			Select 
				@PrevDoc = case when max(id) > 0 then  max(id) else 0 end
				from 
					CTL_DOC with (nolock) 
				where LinkedDoc=@idDoc and tipodoc='PROROGA_GARA' and Statofunzionale='Inviato'

			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, 
				Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,VersioneLinkedDoc,FascicoloGenerale )
				select 
					@IdUser as idpfu , 'PROROGA_GARA' as TipoDoc ,  
					'Proroga gara Num. ' + Protocollo as Titolo,  
						@idDoc as LinkedDoc,@PrevDoc,'BANDO_GARA',Body,Protocollo,CIG,'RichiestaQuesiti:'+RichiestaQuesito,Fascicolo,case when ISNULL(TipoProceduraCaratteristica,'') = 'RDO' then 'Proroga RDO' when ISNULL(TipoProceduraCaratteristica,'') = 'Cottimo' then 'Proroga Cottimo' else 'PROROGA_GARA' end,ISNULL(TipoProceduraCaratteristica,'')
					from document_bando with (nolock) 
						inner join ctl_doc on id=idheader --and tipodoc = 'BANDO_GARA'
					where idheader = @idDoc


			set @id = @@identity
			----recupero tutti i dati del Bando
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','ProtocolloBando',ProtocolloBando
				from document_bando with (nolock)  where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','CIG',CIG
				from document_bando with (nolock)  where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','Descrizione',Body
				from CTL_DOC with (nolock)  where id = @idDoc --and tipodoc='BANDO_GARA' 
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
				from document_bando with (nolock)  where idheader = @idDoc
				
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataSeduta', CONVERT(nvarchar(30), DataAperturaOfferte, 126)
				from document_bando with (nolock)  where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
				from document_bando with (nolock)  where idheader = @idDoc

			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataTermineRispostaQuesiti',CONVERT(nvarchar(30), ISNULL(DataTermineRispostaQuesiti,NULL), 126)
				from document_bando with (nolock)  where idheader = @idDoc
			
				

	end		
	

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

SET NOCOUNT OFF
END
		
		
















GO
