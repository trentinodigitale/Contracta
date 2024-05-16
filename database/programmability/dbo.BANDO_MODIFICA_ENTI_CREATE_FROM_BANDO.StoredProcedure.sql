USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_MODIFICA_ENTI_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[BANDO_MODIFICA_ENTI_CREATE_FROM_BANDO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Role varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdPfu as INT

	set @Id=0
	set @Errore = ''

	-- controllo se esiste una modifica in corso
	select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='BANDO_MODIFICA_ENTI' and StatoFunzionale = 'InLavorazione'
	if ( @id IS NULL or @id=0 )
	begin 
		
		Insert into CTL_DOC (idpfu,Titolo,idPfuInCharge,tipodoc,Body,LinkedDoc,ProtocolloRiferimento,VersioneLinkedDoc)
		Select  @IdUser as idpfu ,'Modifica Enti',@IdUser as idPfuInCharge ,'BANDO_MODIFICA_ENTI',Body,@idDoc  as LinkedDoc,Protocollo,tipodoc	
		from CTL_DOC where id=@idDoc and deleted=0
	    
		set @id=@@IDENTITY	

		--inserisco la cronologia
		set @Role = null
		
		select top 1 @Role = attvalue 
			from profiliutenteattrib 
			where idpfu = @IdUser and dztnome = 'UserRoleDefault'

		insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values( 'BANDO_MODIFICA_ENTI' , @id  , 'Compiled' , '', @IdUser     , @Role       , 1         , getdate() )
		
		--travaso sul documento di modifica gli enti del bando_sda 
		insert into ctl_doc_value
		(IdHeader, DSE_ID, Row, DZT_Name, Value)
		select 
			@id, 'ENTI', Row, DZT_Name, Value
		from 
			ctl_doc_value
		where 
			idheader=@idDoc and dse_id='ENTI'
		
		--travaso sul documento di modifica gli enti del bando_sda per loi storico
		insert into ctl_doc_value
		(IdHeader, DSE_ID, Row, DZT_Name, Value)
		select 
			@id, 'STORICO_ENTI', Row, DZT_Name, Value
		from 
			ctl_doc_value
		where 
			idheader=@idDoc and dse_id='ENTI'

	end

   --select * from ctl_doc_value where idheader=64777 and DSE_ID='ENTI'

	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	

	if @Errore = ''
	begin
		
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END










GO
