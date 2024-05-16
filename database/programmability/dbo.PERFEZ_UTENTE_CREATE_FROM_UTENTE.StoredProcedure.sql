USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PERFEZ_UTENTE_CREATE_FROM_UTENTE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[PERFEZ_UTENTE_CREATE_FROM_UTENTE] (  @IdUser int , @batch int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @valore as varchar(max)
	declare @IdAzi as int

	

	set @Errore = ''

	-- controllo se per l'utente esiste un documento nel sistema
	IF exists( select * from CTL_DOC with(nolock) where tipodoc='PERFEZ_UTENTE' and Deleted=0 and IdPfu=@IdUser )
	BEGIN

		-- rirorna l'errore
		set @Errore = 'Operazione non consentita esiste già un documento "Perfezionamento Utente" nel sistema'

	END

	if @Errore = '' 
	begin
		-- altrimenti lo creo
		INSERT into CTL_DOC (IdPfu,  TipoDoc, Titolo,Azienda)
			select @IdUser as idpfu , 'PERFEZ_UTENTE' as TipoDoc , 'Perfezionamento Utente' as Titolo,pfuidazi
			from ProfiliUtente with(nolock)
			where idpfu=@IdUser		

		set @id = SCOPE_IDENTITY()

		---PROVA A RECUPERARE INFORMAZIONI PER UTENTE 
		
		select @valore=pfunomeutente from ProfiliUtente with(nolock) where idpfu=@IdUser

		if ISNULL(@valore,'') <> ''
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @Id,'TESTATA','pfuNome',@valore,0
		END

		set @valore = ''
		select @valore=pfuCognome from ProfiliUtente with(nolock) where idpfu=@IdUser

		if ISNULL(@valore,'') <> ''
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @Id,'TESTATA','pfuCognome',@valore,0
		END

		set @valore = ''
		select @valore=pfuCodiceFiscale from ProfiliUtente where idpfu=@IdUser

		if ISNULL(@valore,'') <> ''
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @Id,'TESTATA','CodiceFiscale',@valore,0
		END

		set @valore = ''
		select @valore = pfuE_Mail from ProfiliUtente where idpfu=@IdUser

		if ISNULL(@valore,'') <> ''
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @Id,'TESTATA','pfuE_Mail',@valore,0
		END

		--recupero azienda utnete 
		set @IdAzi=null
		select @IdAzi=pfuidazi from profiliutente where idpfu=@IdUser
		
		set @valore = ''
		select @valore = isnull(aziStatoLeg2,'') from aziende where idazi = @IdAzi

		if ISNULL(@valore,'') <> ''
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @Id,'TESTATA','aziStatoLeg2',@valore,0
		END

		--INSERISCO IL DOCUMENTO NELLA CTL_ATTIVITA		
	
		insert into ctl_attivita (ATV_Object, ATV_DateInsert, ATV_Obbligatory, ATV_Execute,ATV_ExpiryDate, ATV_DocumentName, ATV_IdDoc, ATV_IdPfu,ATV_IdAzi )
				Select 'Perfezionamento Utente' , getdate()   ,'si','no' ,NULL,	tipoDoc, id, C.IdPfu ,C.Azienda
					from CTL_DOC C with(nolock)						
					where C.id=@id

	END

	IF @batch = 0
	BEGIN

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

END












GO
