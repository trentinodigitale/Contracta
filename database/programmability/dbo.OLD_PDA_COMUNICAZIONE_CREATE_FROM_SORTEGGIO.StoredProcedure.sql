USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO] 
	( @idDoc int , @IdUser int  , @NewId  int OUTPUT)
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
	declare @DataScadenza as datetime
	set @DataScadenza=DATEADD(hh,13,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE())))

	-- verifica l'esistenza di un documento salvato
	set @id = 0
	select @id = id 
		from CTL_DOC 
		where tipodoc = 'PDA_COMUNICAZIONE' 
				and linkedDoc = @idDoc 
				--and ( statodoc = 'Saved' or ( statodoc = 'Sended ' and DataScadenza > getdate()))
				and JumpCheck = '0-SORTEGGIO'
				and deleted = 0
		
	if isnull( @id , 0 ) = 0
	begin


		Select @IdPfu=IdPfu,
				@Fascicolo=Fascicolo,
				@ProtocolloGenerale=ProtocolloGenerale,
				@DataProtocolloGenerale=DataProtocolloGenerale,
				@ProtocolloRiferimento=ProtocolloRiferimento,
				@Body=cast( Body as nvarchar(2000)),@azienda=azienda,
				@StrutturaAziendale=StrutturaAziendale 
			from CTL_DOC where id=@idDoc
		
		---Insert nella CTL_DOC per creare la comunicazione 
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
		VALUES(@IdUser,'PDA_COMUNICAZIONE','Sorteggio delle offerte in exequo',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'0-SORTEGGIO')

			
		set @Id = @@identity	

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
--			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , dbo.CNV('Sorteggio delle offerte in exequo','I') , @IdUser , @userRole   , 1  , getdate() )

	end 

	-- ritorna l'id della nuova comunicazione appena creata
	set @NewId = @Id

	--select  @Id as ID


END
GO
