USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[USER_DOC_CREATE_FROM_AZI_ENTE_VISURA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[USER_DOC_CREATE_FROM_AZI_ENTE_VISURA] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Errore as varchar(1000)
	declare @totRecord as int
	declare @newId as int

	
	set @Errore = ''


	
	
		

		-- Creo il documento

		declare @Azienda INT
		declare @Fascicolo varchar(1000)
		declare @Destinatario_User INT
		declare @NotEditable varchar(4000)

		declare @nome nvarchar(4000)
		declare @cognome nvarchar(4000)
		declare @pfuRuoloAziendale varchar(1000)
		declare @pfuE_Mail nvarchar(1000)
		declare @pfuTel varchar(1000)
		declare @pfuCell varchar(1000)
		declare @linguaAll varchar(1000)
		declare @codicefiscale varchar(1000)

		SELECT @Azienda = Azienda,
				@Fascicolo = Fascicolo,
				@Destinatario_User = Destinatario_User,
				@NotEditable = NotEditable,

				@nome = nome,
				@cognome = cognome,
				@pfuRuoloAziendale = pfuRuoloAziendale,
				@pfuE_Mail = pfuE_Mail,
				@pfuTel = pfuTel,
				@pfuCell = pfuCell,
				@linguaAll = linguaAll,
				@codicefiscale = codicefiscale

			FROM USER_DOC_FROM_utenti where IDAZI = @idDoc

		INSERT INTO CTL_DOC ( idpfu, TipoDoc, StatoDoc, Azienda, Fascicolo, Destinatario_User, Note,JumpCheck  )
						--VALUES ( @IdUser, 'USER_DOC', 'Saved', @Azienda, @Fascicolo, @Destinatario_User, @NotEditable )
						VALUES ( @IdUser, 'USER_DOC', 'Saved', @Azienda, '', 0, @NotEditable, 'NEW' )

		set @newId = @@identity

		

		/*
		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'nome', @nome )
						
		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'cognome', @cognome )
		
		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'pfuRuoloAziendale', '' )
		

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'pfuE_Mail', @pfuE_Mail )

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'pfuTel', @pfuTel )

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'pfuCell', @pfuCell )

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'linguaAll', @linguaAll )

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'codicefiscale', @codicefiscale )

		INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
					VALUES (  @newId, 'UTENTI',0, 'NotEditable', @NotEditable )
		
		*/

		

	

	IF @Errore = ''
	BEGIN

		-- lascio aprire il documento in modifica
		select @newId as id

	END
	ELSE
	BEGIN

		-- blocco perchè l'utente doveva avere soltanto il profilo RespOrdOE
		select 'Errore' as id , @Errore as Errore

	END

END




GO
