USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[CONVENZIONE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;



	declare @Id as INT
	declare @idSorgente as INT
	declare @Jumpcheck as varchar(100)	
	declare @Errore as nvarchar(4000)
	declare @contatore as varchar(50)
	declare @NumOrd as varchar(50)

	declare @identifIniziativa varchar(500)
	declare @notEdit varchar(4000)

	set @identifIniziativa = NULL
	set @notEdit = null

	set @Errore = ''
	--se l'utente non ha il permesso 490 allora non può creare una convenzione
	if not exists (select idpfu from profiliutente with (nolock) where substring(pfuFunzionalita,490,1)=1 and idpfu = @IdUser )
		set @Errore = 'utente non abilitato alla creazione di una convenzione'
	

	-- se l'utente che sta creando la convenzione non è dell'agenzia
	if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @IdUser and pfuIdAzi = ( select top 1 mpidazimaster  from MarketPlace with(nolock) ) )
	begin

		set @identifIniziativa = '9999'
		set @notedit = ' IdentificativoIniziativa '

	end

	

	if @Errore = ''
	begin
		-- altrimenti lo creo
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,caption )
			VALUES (@IdUser  , 'CONVENZIONE' , @IdUser ,'CONVENZIONE')

		set @id = @@identity

		INSERT into Document_Convenzione (ID, IdentificativoIniziativa)
			VALUES (@id, @identifIniziativa )

		insert into CTL_DOC_SIGN (idheader)
			VALUES (@id )

		insert into CTL_DOC_VALUE (idheader)
			VALUES (@id )

		-- inserisoc il record nella document_protocollo
		insert into Document_dati_protocollo ( idHeader)
			values (  @Id )

		--Genero numord se è vuoto
		Select  @NumOrd=ISNULL(NumOrd,'') from Document_Convenzione where id=@id
		
		if ( @NumOrd='' ) 
		BEGIN
			exec CTL_GetNewProtocol 'CONVENZIONE','',@contatore output
			update Document_Convenzione 
				set NumOrd=@contatore
			where id = @id
		END

	
		--chiamo la stored che gestisce i campi not editable sulla convenzione
		exec CAMPI_NOT_EDITABLE_CONVENZIONE @id , @IdUser
	
		update Document_convenzione 
			set noteditable = isnull(noteditable,'') + isnull(@notedit,'')
		where id = @id
	end

	
	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END





GO
