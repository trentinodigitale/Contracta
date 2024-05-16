USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RIPRISTINO_GARA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[RIPRISTINO_GARA_CREATE_FROM_BANDO_GARA]
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
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RIPRISTINO_GARA' ) and statofunzionale = 'InLavorazione'		

		-- se non esiste lo creo
		if @id is null and @Errore=''
		begin
			   -- altrimenti lo creo
			   --recupero un eventuale precedente RIPRISTINO_GARA inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
				from CTL_DOC
					where LinkedDoc=@idDoc and tipodoc='RIPRISTINO_GARA' and Statofunzionale='Inviato'
				
				INSERT into CTL_DOC ( IdPfu,  TipoDoc, azienda,Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,
									ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,VersioneLinkedDoc,FascicoloGenerale )
					select 
						@IdUser as idpfu , 'RIPRISTINO_GARA' as TipoDoc ,  azienda,
						'Ripristino Procedura Num. ' + Protocollo as Titolo,  
						 @idDoc as LinkedDoc,@PrevDoc,TipoDoc,Body,Protocollo,CIG,'RichiestaQuesiti:'+RichiestaQuesito,Fascicolo,case when ISNULL(TipoProceduraCaratteristica,'') = 'RDO' then 'Ripristino RDO' when ISNULL(TipoProceduraCaratteristica,'') = 'Cottimo' then 'Ripristino Cottimo' else 'RIPRISTINO_GARA' end,ISNULL(TipoProceduraCaratteristica,'')
						from document_bando 
							inner join ctl_doc on id=idheader --and tipodoc = 'BANDO_GARA'				
						where idheader = @idDoc

				set @id = SCOPE_IDENTITY()

				----recupero tutti i dati del Bando
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','ProtocolloBando',ProtocolloBando
					from document_bando where idheader = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','CIG',CIG
					from document_bando where idheader = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','Descrizione',Body
					from CTL_DOC where id = @idDoc --and tipodoc='BANDO_GARA' 
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
					from document_bando where idheader = @idDoc


				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
					from document_bando where idheader = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataSeduta', CONVERT(nvarchar(30), DataAperturaOfferte, 126)
					from document_bando where idheader = @idDoc

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataSeduta', CONVERT(nvarchar(30), DataAperturaOfferte, 126)
					from document_bando where idheader = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
					from document_bando where idheader = @idDoc

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
					from document_bando where idheader = @idDoc

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataTermineRispostaQuesiti',CONVERT(nvarchar(30), ISNULL(DataTermineRispostaQuesiti,NULL), 126)
					from document_bando where idheader = @idDoc

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataTermineRispostaQuesiti',CONVERT(nvarchar(30), ISNULL(DataTermineRispostaQuesiti,NULL), 126)
					from document_bando where idheader = @idDoc
			
				

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
