USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_RETTIFICA_OFFERTA_ECONOMICA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_RETTIFICA_OFFERTA_ECONOMICA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloBAndo as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT

	set @Errore=''
	
	set @id = null

	----SE NON SONO PERVENUTE RISPOSTE NON HA SENSO CREARE LA COMUNICAZIONE
	--IF NOT EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RISPOSTA_CONSULTAZIONE' and StatoFunzionale='Inviato' )
	--BEGIN
	--	set @Errore = 'Il documento non puo essere creato in quanto sulla Consultazione Preliminare non risultano pervenute risposte'
	--END


	--recupero campi per inserire la nuova comunicazione capogruppo
	Select 
		@IdPfu=IdPfu,
		@Fascicolo=Fascicolo,
		@ProtocolloBAndo=Protocollo,
		@Body=Body,
		@azienda=azienda
		from 
			CTL_DOC with (nolock)
		where id=@idDoc

	-- vede se ne esista già una per quel fornitore, nel caso apre quella
	select @id = id 
		from CTL_DOC with (nolock)
	where IdPfu=@IdUser and TipoDoc = 'PDA_COMUNICAZIONE_GARA' and deleted = 0
			and LinkedDoc = @idDoc and Azienda = @azienda
			--and StatoFunzionale = 'InLavorazione'
			and SUBSTRING(JumpCheck, 3, LEN(JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
	
	if @Errore = '' and @id is null
	begin

		 -- lista dei fornitori - creiamo le singole comunicazioni
		insert into CTL_DOC 
						(
							IdPfu,
							TipoDoc,
							Titolo,
							Fascicolo,
							LinkedDoc,
							Body,
							ProtocolloRiferimento,
							ProtocolloGenerale,
							Azienda,
							Destinatario_Azi,
							Data,
							JumpCheck,
							Caption 
						) 
			select 
				@IdUser,
				'PDA_COMUNICAZIONE_GARA',
				'Rettifica Offerta Economica',
				@Fascicolo,
				@idDoc,
				@Body,
				@ProtocolloBAndo,
				'',
				Azienda,
				Destinatario_Azi,
				getDate(),
				'0-RETTIFICA_ECONOMICA_OFFERTA',
				'Rettifica Offerta Economica'
				from 
					ctl_doc with (nolock)		
				where id=@idDoc 
					and TipoDoc='OFFERTA' --and StatoFunzionale='Inviato'
	
		set @id=SCOPE_IDENTITY()

	
	end


	-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
	if @Errore = ''
	begin

		-- Inserisco il modello dinamico per la sezione di testata se non già presente
		if not exists (select 1 from CTL_DOC_SECTION_MODEL with (nolock)where IdHeader = @Id and DSE_ID = 'TESTATA' and MOD_Name = 'RETTIFICA_OFFERTA_TESTATA')
		begin
			insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
			values (@Id,'TESTATA','RETTIFICA_OFFERTA_TESTATA')
		end

		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id,'' as Errore
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end	

END







GO
