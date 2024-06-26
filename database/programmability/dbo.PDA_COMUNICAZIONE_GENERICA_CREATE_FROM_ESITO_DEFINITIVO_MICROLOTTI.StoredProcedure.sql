USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_DEFINITIVO_MICROLOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_DEFINITIVO_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2014-03-18&Attivita=54707&Nominativo=Enrico
--crea la nuova comunicazione di aggiudicazione definitiva partecipanti
BEGIN

	exec PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_SUB_MICROLOTTI @idDoc , @IdUser , 'AggiudicazioneDef',''

--	SET NOCOUNT ON;
--
--	declare @Id as INT
--	declare @c as INT
--	declare @n as INT
--	declare @ProtocolloRiferimento as varchar(40)
--	declare @Body as nvarchar(2000)
--	declare @azienda as varchar(50)
--	declare @StrutturaAziendale as varchar(150)
--	declare @ProtocolloGenerale as varchar(50)
--	declare @Fascicolo as varchar(50)
--	declare @DataProtocolloGenerale as datetime
--	declare @IdPfu as INT
--	declare @Errore as nvarchar(2000)
--	
--	set @Errore=''
--
--	-- controllo che ci sono lotti nello stato richiesto
--	if not exists( select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,'AggiudicazioneDef','0-ESITO_DEFINITIVO_MICROLOTTI')	 ) 
--	begin 
--		-- rirorna l'errore
--		set @Errore = 'Non ci sono lotti nello stato Aggiudicazione Definitiva' 
--	end
--	
--	if @Errore=''
--	begin
--		--controllo che ci sono aziende a cui fare la comunicazione
--		if	not exists( select 
--							distinct idaziPartecipante 
--						from 
--								Document_PDA_OFFERTE DPO , DOCUMENT_MICROLOTTI_DETTAGLI DMDO 
--						where 
--								DPO.idHEader=@idDoc and StatoPda not in ('1','99')
--								and DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'
--								and 	DMDO.NumeroLotto in (select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,'AggiudicazioneDef','0-ESITO_DEFINITIVO_MICROLOTTI')			)
--								and   DMDO.Voce=0
--						)
--		begin 
--			-- rirorna l'errore
--			set @Errore = 'Non ci sono partecipanti ai lotti aggiudicati' 
--		end	
--	end
--
--	if @Errore = ''
--	begin
--		
--		-- invalido le precedenti comunicazioni di dettaglio non inviate
--		update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
--				where JumpCheck='0-ESITO_DEFINITIVO_MICROLOTTI' and TipoDoc='PDA_COMUNICAZIONE_GARA' and 
--						StatoFunzionale='InLavorazione' 
--				and LinkedDoc in (Select id from CTL_DOC where LinkedDoc=@idDoc )
--			
--		--invalido la precedente capogruppo
--		update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
--				where JumpCheck='0-ESITO_DEFINITIVO_MICROLOTTI' and TipoDoc='PDA_COMUNICAZIONE_GENERICA' and 
--						StatoFunzionale='InLavorazione' 
--				and LinkedDoc=@idDoc
--
--		--recupero campi per inserire la nuova comunicazione capogruppo
--		Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
--		
--
--		--determino il corpo della comunicazione (da inserire nel campo note)
--		--escludere i lotti per i quali ho già fatto una comunicazione dello stesso tipo
--		
--		--DA FARE
--		--recupero la lista dei lotti per costruire il testo della comunicazione
--		declare @Note as nvarchar(4000)
--		set @Note=dbo.RisolvoTemplatePDAMicrolotti(@idDoc,'0-ESITO_DEFINITIVO_MICROLOTTI')
--		
--		--select 	len(dbo.RisolvoTemplatePDAMicrolotti(42227))
--		
--		---Insert nella CTL_DOC per creare la comunicazione capogruppo
--		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck,Note)
--		VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Esito Definitivo',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'0-ESITO_DEFINITIVO_MICROLOTTI',@Note )
--
--		set @Id = @@identity	
--		
--		
--
--		---inserisco la riga per tracciare la cronologia nella PDA
--		declare @userRole as varchar(100)
--		select    @userRole= isnull( attvalue,'')
--			from ctl_doc d 
--				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
--			where id = @id
--
--			
--		insert into CTL_ApprovalSteps 
--			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
--			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GENERICA' , 'Comunicazione di Esito Definitivo' , @IdUser , @userRole   , 1  , getdate() )
--			
--			
--					
--			
--		-- lista dei partecipanti (non esclusi) ai lotti che si trovano nello stato aggiucatario provvisorio
--		-- creiamo le singole comunicazioni
--		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 
--			select @IdPfu,'PDA_COMUNICAZIONE_GARA','Esito Definitivo',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,PAR.idaziPartecipante,getDate(),@Note,'0-ESITO_DEFINITIVO_MICROLOTTI' 
--				from 
--				( select distinct idaziPartecipante from Document_PDA_OFFERTE DPO , DOCUMENT_MICROLOTTI_DETTAGLI DMDO 
--				where DPO.idHEader=@idDoc and StatoPda not in ('1','99')
--					  and DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'
--					  and 	DMDO.NumeroLotto in (select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,'AggiudicazioneDef','0-ESITO_DEFINITIVO_MICROLOTTI')			)
--					  and   DMDO.Voce=0
--				) PAR
--		
--		
--		
--		
--		
--		--Per il controllo all'invio memorizzo i lotti aggiudicati in modo provvisorio con i secondi classificati
--		--per i quali ho fatto la comunicazione
--		insert into Document_comunicazione_StatoLotti
--		(IdHeader, NumeroLotto, IdAziAggiudicataria, Importo, IdAziIIClassificata)
--		select @id,NumeroLotto,Aggiudicata,ValoreEconomico,IIClassificata from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,'AggiudicazioneDef','0-ESITO_DEFINITIVO_MICROLOTTI')	
--		
--	end
--	
--	--select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(42227,'AggiudicazioneProvv')			
--	
--	-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
--	if @Errore = ''
--	begin
--		-- rirorna l'id della nuova comunicazione appena creata
--		select @Id as id
--	
--	end
--	else
--	begin
--		-- rirorna l'errore
--		select 'Errore' as id , @Errore as Errore
--	end	

END



GO
