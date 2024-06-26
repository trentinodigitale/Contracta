USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_PROGRAMMAZIONE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[BANDO_PROGRAMMAZIONE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Idazi as INT

	select @Idazi=pfuidazi from ProfiliUtente where IdPfu=@IdUser
	

	
	

	   -- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda )
			VALUES (@IdUser  , 'BANDO_PROGRAMMAZIONE' , @IdUser ,@Idazi)


		set @id = SCOPE_IDENTITY()

		insert into Document_Bando (idHeader) values (@id)

		insert into Document_dati_protocollo (idHeader) values (@id)

		--INSERISCO IL RECORD NELLA CRONOLOGIA DI CREAZIONE DOCUMENTO
				
		declare @userRole as varchar(100)
		select  @userRole= isnull( attvalue,'')
			from  profiliutenteattrib where idpfu = @IdUser and dztnome = 'UserRoleDefault'  
		IF ISNULL(@userRole ,'') = ''
		set @userRole ='UtenteEnte'

	    insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('BANDO_PROGRAMMAZIONE' , @id , 'Compiled' , '' , @IdUser     , @userRole       , 1         , getdate() )
	
	if  ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin

		select 'Errore' as id , 'ERROR' as Errore

	end
END








GO
