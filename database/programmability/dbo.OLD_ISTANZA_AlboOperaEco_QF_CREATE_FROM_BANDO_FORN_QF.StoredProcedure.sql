USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_AlboOperaEco_QF_CREATE_FROM_BANDO_FORN_QF]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE  PROCEDURE [dbo].[OLD_ISTANZA_AlboOperaEco_QF_CREATE_FROM_BANDO_FORN_QF] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @titolo varchar(500)
	declare @Stato varchar(50)
	declare @pfuIdAzi as int		
	declare @myId as int	
	declare @AreaVal varchar(100)
	declare @merc varchar(5000)

	set @Errore = ''
	
	
	select @pfuIdAzi=pfuIdAzi from profiliutente where idpfu=@IdUser
	
	set @titolo=''
	--select @titolo=cast(body as varchar(500)) from ctl_doc where id=@idDoc
	select @titolo=isnull(ProtocolloGenerale, 'Bando qualificazione' ) from ctl_doc where id=@idDoc
	
	set @titolo='Risposta a ' + @titolo
	
	
	select @AreaVal=areavalutazione,@merc=ArtClasMerceologica  from document_bando where idheader = @idDoc

	-- controllo lo stato dell'istanza
	--if exists( select * from CTL_DOC where id = @idDoc and StatoFunzionale not in ( 'InValutazione' ,  'Integrato' ) ) 
	--begin 
	--	-- rirorna l'errore
	--	set @Errore = 'Operazione non consentita per lo stato del documento' 
	--end



	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	--if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'SCARTO_ISCRIZIONE', 'CONFERMA_ISCRIZIONE' ) and statoFunzionale in ( 'InLavorazione' , 'Valutato') )
	--	set @Errore = 'Operazione non consentita, esiste altro documento in lavorazione di tipo diverso. E'' necessario cancellarlo' 

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id,@Stato=Statofunzionale 
		  from CTL_DOC where LinkedDoc = @idDoc 
						  and deleted = 0 
						  and TipoDoc in (  'ISTANZA_AlboOperaEco_QF'  )
						  and azienda=@pfuIdAzi

		if @id is null
		begin
			   -- se non esiste lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
					Destinatario_Azi,JumpCheck )
				select 
					@IdUser as idpfu , 'ISTANZA_AlboOperaEco_QF'  as TipoDoc ,  
					@titolo, '' Body, 
					@pfuIdAzi as  Azienda, StrutturaAziendale, 
					ProtocolloRiferimento, Fascicolo, id as LinkedDoc, 
					CTL_DOC.IdPfu as Destinatario_User, 
					Azienda as Destinatario_Azi ,tipodoc
		
				from CTL_DOC
					--inner join profiliutente p on Destinatario_User = p.idpfu
				where id = @idDoc

				set @id = @@identity
				
				-- inserisce nella Document_Bando_DocumentazioneRichiesta
				--insert into dbo.CTL_DOC_ALLEGATI
				--(idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, 
				--Modified, NotEditable, TipoFile, DataScadenza, DSE_ID)
				
				--select @id, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, 
				--Modified, NotEditable, TipoFile, DataScadenza, DSE_ID
				--from CTL_DOC_ALLEGATI
				--where idHeader = @idDoc
				
				insert into dbo.Document_Bando_DocumentazioneRichiesta
				(idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione,peso,tipovalutazione,emas)
				
				select @id, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, null, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione,peso,tipovalutazione,emas
				from Document_Bando_DocumentazioneRichiesta
				where idHeader = @idDoc


				-- inserisce gli eventuali allegati presenti in anagrafica documenti
				-- UPDATE JOIN !!!
				update Document_Bando_DocumentazioneRichiesta

					set AllegatoRichiesto=b.Allegato 

							from Document_Bando_DocumentazioneRichiesta a ,Document_Anag_documentazione b , ctl_doc c
									where a.idheader=@id and a.AnagDoc = b.AnagDoc and b.deleted = 0									
											and rtrim(isnull(b.AnagDoc,'')) <> ''
											and isnull(b.Allegato,'')  <> ''
											and c.id = b.idHeader 
											and c.deleted=0
											and StatoFunzionale = 'Pubblicato'
											and TipoDoc = 'ANAG_DOCUMENTAZIONE'


				-- inserisce gli eventuali allegati non scaduti già presenti nella scheda anagrafica del fornitore
				-- UPDATE JOIN !!!
				update Document_Bando_DocumentazioneRichiesta
					set AllegatoRichiesto=b.Allegato ,	[DataScadenza]	=		b.DataScadenza
							from Document_Bando_DocumentazioneRichiesta a ,Aziende_Documentazione b 
									where a.idheader=@id and a.AnagDoc = b.AnagDoc and b.deleted = 0
									and ( b.DataScadenza is null or b.DataScadenza > getdate() )
									and idazi=@pfuIdAzi
									and rtrim(isnull(b.AnagDoc,'')) <> ''
									and isnull(b.Allegato,'')  <> ''

				

				
				exec Popola_Dati_Anag_Istanza @id,@pfuIdAzi,@AreaVal


				-- avvalora la merceologia bando
				update DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
				set MerceologiaBando = @merc
				where idHeader = @id


				exec Insert_Dati_Istanza_Anagrafici  @id,@pfuIdAzi,@merc

				


		end
		
		else
		
		begin
		  
		  set @myId = @id
		  
		  -- se esiste salvato apro quello
		  -- se esiste inviato crea una nuova copia di quello
		  if @Stato = 'Inviato'
		  begin
			 
			 -- vede se l'ente ha valutato tutto altrimenti blocca
			 declare @cnt int
			 
			 select @cnt=count(*) from ctl_doc
			 where tipodoc='QUESTIONARIO_FORNITORE'
			 and linkeddoc=@idDoc
			 and azienda=@pfuIdAzi
			 and deleted=0
			 and statofunzionale<>'Valutato'
			 
			 if @cnt>0 
				set @Errore = 'Ci sono ancora questionari sottoposti a valutazione su questo questionario'
			 
			 
			 if @Errore = '' 
			 begin
				INSERT into CTL_DOC (
					    IdPfu,  TipoDoc, 
					    Titolo, Body, Azienda, StrutturaAziendale, 
					    ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
					    Destinatario_Azi,JumpCheck,StatoFunzionale )
				    select 
					    @IdUser as idpfu , 'ISTANZA_AlboOperaEco_QF'  as TipoDoc ,  
					    'Istanza ' + titolo, '' Body, 
					    @pfuIdAzi as  Azienda, StrutturaAziendale, 
					    ProtocolloRiferimento, Fascicolo, @idDoc as LinkedDoc, 
					    CTL_DOC.IdPfu as Destinatario_User, 
					    Azienda as Destinatario_Azi ,tipodoc,'InLavorazione'
    		
				    from CTL_DOC
					    --inner join profiliutente p on Destinatario_User = p.idpfu
				    where id = @id

				    set @id = @@identity
    				
    				
				    -- inserisce nella Document_Bando_DocumentazioneRichiesta
				    --insert into dbo.CTL_DOC_ALLEGATI
				    --(idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, 
				    --Modified, NotEditable, TipoFile, DataScadenza, DSE_ID)
    				
				    --select @id, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, 
				    --Modified, NotEditable, TipoFile, DataScadenza, DSE_ID
				    --from CTL_DOC_ALLEGATI
				    --where idHeader = @myId
    				

				    insert into dbo.Document_Bando_DocumentazioneRichiesta
				    (idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione,peso,tipovalutazione,emas,DataScadenza)
    				
				    select @id, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, null, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione,peso,tipovalutazione,emas,DataScadenza					
				    from Document_Bando_DocumentazioneRichiesta
				    where idHeader = @myId

					-- inserisce gli eventuali allegati non scaduti già presenti nella scheda anagrafica del fornitore
					-- UPDATE JOIN !!!
					
					update Document_Bando_DocumentazioneRichiesta
					set AllegatoRichiesto=b.Allegato				
					from Document_Bando_DocumentazioneRichiesta a ,Aziende_Documentazione b 
					where a.idheader=@id and a.AnagDoc = b.AnagDoc and b.deleted = 0
					and ( b.DataScadenza is null or b.DataScadenza > getdate() )
					and idazi=@pfuIdAzi
					and rtrim(isnull(b.AnagDoc,'')) <> ''
					and isnull(b.Allegato,'')  <> ''
					


    				
				    exec Popola_Dati_Anag_Istanza @id,@pfuIdAzi,@AreaVal


				    -- avvalora la merceologia bando
				    update DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
				    set MerceologiaBando = @merc
				    where idHeader = @id


					insert into CTL_DOC_Value 
						(IdHeader , DSE_ID , row, DZT_Name , value)
					
					select @id, DSE_ID, row, DZT_Name, value
						from CTL_DOC_Value 
					where IdHeader = @myId



			 end				 
			 
		  end
		
		end
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
END








/*

select a.idrow,a.AllegatoRichiesto,b.Allegato, b.AnagDoc,b.*  from Document_Bando_DocumentazioneRichiesta a 
inner join Aziende_Documentazione b on a.AnagDoc = b.AnagDoc and b.deleted = 0
where a.idheader=340
and (b.DataScadenza is null or b.DataScadenza > getdate())
and idazi=35152433


update Document_Bando_DocumentazioneRichiesta
set AllegatoRichiesto=b.Allegato
--select AllegatoRichiesto,b.Allegato,b.AnagDoc,a.idrow
from Document_Bando_DocumentazioneRichiesta a ,Aziende_Documentazione b 
where a.idheader=340 and a.AnagDoc = b.AnagDoc and b.deleted = 0
and (b.DataScadenza is null or b.DataScadenza > getdate())
and idazi=35152433

*/

















GO
