USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_USER_DOC_OE_CREATE_FROM_UTENTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_USER_DOC_OE_CREATE_FROM_UTENTI] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Errore as varchar(1000)
	declare @totRecord as int
	declare @totRecordcheck as int
	declare @RegistrazionePeppol as int
	
	declare @newId as int

	set @totRecordcheck=2
	set @RegistrazionePeppol=0

	set @Errore = 'Operazione bloccata. L''utente deve possedere soltanto il permesso RespOrdOE'
	set @Errore = 'Operazione bloccata. E'' consentito la modifica solo degli utenti creati per gestire gli ordinativi. Gli utenti registrati dal portale possono cambiare i propri dati anagrafici dalla funzione dedicata'

	--in creazione vengono assegnati sempre profilo “Procuratore OE” e “RespOrdOE”, mentre il profilo “Registrazione Peppol” solo se attivo il modulo
	declare @sysModuli nvarchar(max) = ''

	select @sysModuli = DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'
	select items into #moduli_attivi from dbo.Split( @sysModuli ,',' )
	-- Se è attivo il modulo notier/peppol
	if exists ( select * from #moduli_attivi where items = 'GROUP_NOTIER' )
	BEGIN
		set @totRecordcheck=3
		set @RegistrazionePeppol=1
	END	
	
	select @totRecord = count(*) from profiliutenteattrib where idpfu = @idDoc and dztNome = 'Profilo'
	
	IF @totRecord = @totRecordcheck
	BEGIN
		
		-- se ha proprio i profili noti
		IF  EXISTS ( select * from profiliutenteattrib where idpfu = @idDoc and dztNome = 'Profilo' and attValue = 'RespOrdOE' )
			AND	
			EXISTS ( select * from profiliutenteattrib where idpfu = @idDoc and dztNome = 'Profilo' and attValue = 'ProcuratoreOE' )
			AND
			EXISTS ( select * from profiliutenteattrib where idpfu = @idDoc and dztNome = 'Profilo' and attValue = 'RegistrazionePeppol' or @RegistrazionePeppol = 0 )					
		BEGIN

			
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

				FROM USER_DOC_FROM_utenti where id_from = @idDoc

			INSERT INTO CTL_DOC ( idpfu, TipoDoc, StatoDoc, Azienda, Fascicolo, Destinatario_User, Note )
						  VALUES ( @idDoc, 'USER_DOC_OE', 'Saved', @Azienda, @Fascicolo, @Destinatario_User, @NotEditable )

			set @newId = @@identity

			INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
						VALUES (  @newId, 'UTENTI',0, 'nome', @nome )
						
			INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
						VALUES (  @newId, 'UTENTI',0, 'cognome', @cognome )

			INSERT INTO CTL_DOC_VALUE ( idHeader, DSE_ID, row, dzt_name, value )
						VALUES (  @newId, 'UTENTI',0, 'pfuRuoloAziendale', @pfuRuoloAziendale )

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
			

		END

	END 

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
