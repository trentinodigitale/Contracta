USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_PROSSIMA_SEDUTA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_PROSSIMA_SEDUTA] 
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
	declare @key_mlng as nvarchar(2000)
	declare @idSeduta INT
	declare @DATA datetime
	declare @DATA_sed varchar(20)

	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
	
	---Insert nella CTL_DOC per creare la comunicazione 
	insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
	VALUES(@IdUser,'PDA_COMUNICAZIONE','Comunicazione Prossima Seduta',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'0-PROSSIMA_SEDUTA')

		
	set @Id = @@identity	

    ---inserisco la riga per tracciare la cronologia nella PDA
	declare @userRole as varchar(100)
	select    @userRole= isnull( attvalue,'')
		from ctl_doc d 
			left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
		where id = @id

		
	insert into CTL_ApprovalSteps 
		( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione Prossima Seduta' , @IdUser , @userRole   , 1  , getdate() )
		
		
	--recupero una chiave di multilinguismo da inserire come testo delle comunicazioni per i fornitori
--	select @key_mlng=ML_Description from LIB_MULTILINGUISMO where ML_KEY='ML_Testo Descrizione Comunicazione Prossima Seduta' and ML_LNG='I'			
	set @key_mlng= dbo.CNV( 'ML_Testo Descrizione Comunicazione Prossima Seduta' , 'I' )

	-- recuperiamo data prossima seduta
	select top 1 @idSeduta = idSeduta 
		from Document_PDA_Sedute 
		where idHeader = @idDoc 
		order by idRow desc
		

		set @DATA=null
		set @DATA_sed=''
		select @DATA=VALUE  from CTL_DOC_VALUE where DSE_ID='DATE' and dzt_name='DataSeduta' and idHeader=@idSeduta
		
		if @DATA is not null
		begin
			set @DATA_sed=CONVERT(VARCHAR(10),@DATA,105)
			set @DATA_sed=@DATA_sed + ' ' + CONVERT(VARCHAR(5),@DATA,114)

			if @DATA_sed like '1900%'
			begin
				set @DATA_sed=''
			end

		end

	

	-- lista dei fornitori - creiamo le singole comunicazioni
	insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 
		select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione Prossima Seduta',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),@key_mlng+@DATA_sed,'0-PROSSIMA_SEDUTA' 
			from Document_PDA_OFFERTE 
			where idHEader=@idDoc and StatoPda not in (1,99)


	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END




GO
