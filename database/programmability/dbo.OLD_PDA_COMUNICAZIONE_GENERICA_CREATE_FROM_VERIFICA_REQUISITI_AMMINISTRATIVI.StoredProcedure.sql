USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_VERIFICA_REQUISITI_AMMINISTRATIVI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

					
CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_VERIFICA_REQUISITI_AMMINISTRATIVI]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
    declare @Allegato nvarchar(255)
    declare @Descrizione nvarchar(255)
    declare @key_mlng as nvarchar(2000)
    declare @SEDUTA as varchar(50)
    declare @idSeduta INT
	
	declare @DataScadenza as datetime

	set @DataScadenza= DATEADD(hh,23,DATEADD(mi,59,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE() ) ) ) )

	--se esiste un documento riapre quello
	if exists( select id from ctl_doc where tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and JumpCheck = '1-VERIFICA_REQUISITI'and deleted=0 and LinkedDoc = @idDoc )
	begin
		select id from ctl_doc where tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and JumpCheck = '1-VERIFICA_REQUISITI' and deleted=0 and LinkedDoc = @idDoc
	end
	else
	-- se non sono presenti offerte che si trovano nello stato di ammesse/ammessa con riserva
	if not exists(select idHeader from Document_PDA_OFFERTE where idHEader=@idDoc and StatoPda in ('2','22') )
	begin

		select 'ERRORE' as id , 'Non sono presenti offerte il cui stato consente la verifica dei requisiti amministrativi.' as Errore
	end
	else
	begin
		Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
		
		--recupero una chiave di multilinguismo da inserire come testo delle comunicazioni per i fornitori
		select @key_mlng=ML_Description from LIB_MULTILINGUISMO where ML_KEY='ML_Testo Comunicazione Di Verifica Requisiti Amministrativi' and ML_LNG='I'

		---Insert nella CTL_DOC per creare la comunicazione 
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck,note,DataDocumento,DataScadenza,Caption)
		VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Di Verifica Requisiti Amministrativi',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-VERIFICA_REQUISITI',@key_mlng,getdate(),@DataScadenza,'Comunicazione Di Verifica Requisiti Amministrativi')

			
		set @Id = SCOPE_IDENTITY()	

		---INSERISCO IL MODELLO SPECIFICO PER LA SEZIONE DELLE COMUNICAZIONI
		insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		select @Id,'DETTAGLI','PDA_COMUNICAZIONE_GENERICA_DETTAGLI_VERIFICA_REQ_AMMGriglia'


		---inserisco la riga per tracciare la cronologia nella PDA
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d 
				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

			
		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione Di Verifica Requisiti Amministrativi' , @IdUser , @userRole   , 1  , getdate() )
			
		
					
			
		---- lista dei fornitori - creiamo le singole comunicazioni
		--insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 
		--	select @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Amministrativa',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),@key_mlng ,'0-VERIFICA_AMMINISTRATIVA' 
		--		from Document_PDA_OFFERTE 
		--		where idHEader=@idDoc and StatoPda in ('2')
		---- lista dei fornitori - creiamo le singole comunicazioni
		--insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 
		--	select @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Amministrativa',@Fascicolo,@Id,@Body ,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),@key_mlng + '<br/>' + dbo.PDA_MICROLOTTI_ListaMotivazioni( idRow ) ,'0-VERIFICA_AMMINISTRATIVA' 
		--		from Document_PDA_OFFERTE 
		--		where idHEader=@idDoc and StatoPda in ('22')


		-- recuperiamo l'allegato del verbale da aggiungere alle comunicazioni
		select top 1 @Allegato = Allegato , @Descrizione = Descrizione, @idSeduta = idSeduta 
			from Document_PDA_Sedute 
			where idHeader = @idDoc 
			order by idRow desc
		
		--controllo se la seduta è pubblica altrimenti non inserisco l'allegato
		select @SEDUTA=VALUE  from CTL_DOC_VALUE where DSE_ID='DATE' and dzt_name='TipoSeduta' and idHeader=@idSeduta
		IF (ISNULL(@SEDUTA,'') <> 'Privata')
		BEGIN
			-- aggiungo l'allegato alle singole comunicazioni
			insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato )
				select id  , left( 'Verbale - ' + @Descrizione , 250 )  , @Allegato
					from CTL_DOC where LinkedDoc = @Id
		END	

		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id

	end


END










GO
