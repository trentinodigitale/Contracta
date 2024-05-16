USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_UTENTECOMMISSIONE_CREATE_FROM_UTENTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].[OLD_UTENTECOMMISSIONE_CREATE_FROM_UTENTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT



	declare @Titolo as varchar (200)
	declare @Destinatario_User int
	declare @PrevDoc int


	declare @pfuE_Mail as varchar (300)
	declare @pfuTel as varchar (200)
	declare @pfuCell as varchar (200)
	declare @pfuPrefissoProt as varchar (200)
	declare @CodiceFiscale as varchar (200)
	declare @funzionalitautente as varchar (1200)
	declare @pfuRuoloAziendale as varchar (200)
	declare @LinguaAll as int
	declare @pfuResponsabileUtente int

	declare @PosPermesso as  int
	set @PosPermesso=-1
	select @PosPermesso = DZT_ValueDef from LIB_Dictionary where DZT_Name = 'SYS_POS_PERMESSO_UTENTI_COMMISSIONE'

	if @PosPermesso	<> -1
	begin
		
		set @Errore = ''

		-- se @idDoc è -1 allora dobbiamo creare un nuovo utente altrimenti è la modifica di uno esistente 
		IF @idDoc = -1
		begin
			
			set @funzionalitautente = REPLICATE('0', 400)
			set @funzionalitautente = stuff( @funzionalitautente , @PosPermesso , 1 , '1' )

			insert into CTL_DOC ( tipoDoc ,idpfu, azienda , Titolo , Destinatario_User , Statodoc , Statofunzionale )
				select top 1 'UTENTECOMMISSIONE' , @IdUser, mpIdAziMaster , 'Nome Commissario' , 0 , 'Saved' , 'InLavorazione'  from MarketPlace 

			set @IdPfu = @@identity

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @IdPfu , 'UTENTI' , 0 , 'funzionalitaUtente' ,'###' +  @funzionalitautente )

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @IdPfu , 'UTENTI' , 0 , 'LinguaAll' , '1' )


		end
		else
		begin


			-- controlliamo che per l'utente da modificare sia attivo il permesso di modifica
			if exists( select * from profiliutente where idpfu = @idDoc and substring( pfufunzionalita , @PosPermesso , 1 ) = '1' )
			begin
			


				insert into CTL_DOC ( tipoDoc , idpfu, azienda , Titolo , Destinatario_User , Statodoc , Statofunzionale  , Fascicolo , Note , PrevDoc)
					select 'UTENTECOMMISSIONE' , @IdUser, pfuidazi , pfuNome , idpfu ,  'Saved' , 'InLavorazione' , pfuLogin , ' pfuLogin Fascicolo ' , idpfu 
						from profiliutente where idpfu = @idDoc

				set @IdPfu = @@identity



				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					values( @IdPfu , 'UTENTI' , 0 , 'LinguaAll' , '1' )

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'pfuE_Mail' , pfuE_Mail  from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'pfuTel' , pfuTel from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @IdPfu , 'UTENTI' , 0 , 'pfuCell' , pfuCell from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @IdPfu , 'UTENTI' , 0 , 'pfuPrefissoProt' , pfuPrefissoProt from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'CodiceFiscale' , pfuCodiceFiscale from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @IdPfu , 'UTENTI' , 0 , 'pfuRuoloAziendale' , pfuRuoloAziendale from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'pfuResponsabileUtente' , pfuResponsabileUtente from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'funzionalitaUtente' , '###' + pfuFunzionalita from profiliutente where idpfu = @idDoc

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @IdPfu , 'UTENTI' , 0 , 'pfuTitolo' , pfutitolo from profiliutente where idpfu = @idDoc


			end
			else
			begin
				set @Errore = 'Operazione non consentita per l''utente selezionato' 
			end

		end

	end

	else
		begin
			set @Errore = 'Definire SYS_POS_PERMESSO_UTENTI_COMMISSIONE per utenti Commissioni' 
		end	

	if @Errore = ''
		begin
			-- rirorna l'id della nuova comunicazione appena creata
			select @IdPfu as id
		
		end
	else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
END

GO
