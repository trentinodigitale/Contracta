USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CTL_CONFIG_MAIL_CREATE_FROM_CONFIG_MAIL]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[CTL_CONFIG_MAIL_CREATE_FROM_CONFIG_MAIL]( @idOrigin as int, @idPfu as int = -20  ) 
AS
BEGIN

	SET NOCOUNT ON
	declare @Id as INT
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	select @id=ID from CTL_DOC with(nolock) where LinkedDoc=@idOrigin and TipoDoc='CTL_CONFIG_MAIL' and StatoFunzionale='InLavorazione'
	
	--CANCELLO SEMPRE IL DOCUMENTO PER FARLO AGGIORNARE DALLA TABELLA DI CONFIGURAZIONE
	--SE PER IL CLIENTE NEL TEMPO SONO STATI CAMBIATI DATI SULLA TABLE SI RISCHIA DI AVERE DATI SPORCHI 
	IF @id is not null
	BEGIN
		delete from ctl_doc where id=@id
		delete from ctl_doc_value where idheader=@id
		set @id=NULL
	END


	if @Id is null
	BEGIN
		insert into CTL_DOC (IdPfu,Titolo,TipoDoc,LinkedDoc,PrevDoc)
			select @idPfu,'Parametri Ctl Config Mail','CTL_CONFIG_MAIL',@idOrigin,ISNULL(MAX(id),0)
				from ctl_doc with(nolock) 
					where TipoDoc='CTL_CONFIG_MAIL' and LinkedDoc=@idOrigin

		set @Id=SCOPE_IDENTITY();

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'Alias',Alias
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'Server',Server
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ServerPort',ServerPort
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'UseSSL',UseSSL
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'Authenticate',Authenticate
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'UserName',UserName
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'MailFrom',MailFrom
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'AliasFrom',AliasFrom
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'Certified',Certified
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'StartTLS',StartTLS
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ServerRead',case when rtrim(isnull(ServerRead,''))='' then [Server] else ServerRead end
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ServerPortRead',case when isnull(ServerPortRead,0) = 0 then [ServerPort] else ServerPortRead end			
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'LoginMethod',case when isnull(LoginMethod,'') = '' then 'LOGIN' else LoginMethod end			
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'JsonToken',isnull(JsonToken,'')
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'DateUpdateToken',DateUpdateToken
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'FrequencyUpdateToken',FrequencyUpdateToken
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ClientId',isnull(ClientId,'')
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ClientSecret',isnull(ClientSecret,'')
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'TokenEndpoint',isnull(TokenEndpoint,'')
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		
		
	END

	else

	begin
		
		delete from CTL_DOC_Value
			where IdHeader = @Id and DSE_ID = 'DETTAGLI' and [Row] = 0 
					and DZT_Name in ('ServerRead','ServerPortRead')

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ServerRead',case when rtrim(isnull(ServerRead,''))='' then [Server] else ServerRead end
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @Id,'DETTAGLI',0,'ServerPortRead',case when isnull(ServerPortRead,0) = 0 then [ServerPort] else ServerPortRead end			
				from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'LoginMethod')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'LoginMethod',case when isnull(LoginMethod,'') = '' then 'LOGIN' else LoginMethod end			
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'JsonToken')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'JsonToken',isnull(JsonToken,'')
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'DateUpdateToken')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'DateUpdateToken',DateUpdateToken
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'FrequencyUpdateToken')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'FrequencyUpdateToken',FrequencyUpdateToken
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'ClientId')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'ClientId',isnull(ClientId,'')
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'ClientSecret')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'ClientSecret',isnull(ClientSecret,'')
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end

		if not exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader=@Id and DSE_ID='DETTAGLI' and DZT_Name = 'TokenEndpoint')
		begin
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @Id,'DETTAGLI',0,'TokenEndpoint',isnull(TokenEndpoint,'')
					from CTL_CONFIG_MAIL with(nolock)  where id=@idOrigin
		end


	end

	if @Errore = ''
	begin
		-- rirorna l'id del doc
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END


GO
