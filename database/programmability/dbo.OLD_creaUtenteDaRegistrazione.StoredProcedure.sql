USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_creaUtenteDaRegistrazione]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROC [dbo].[OLD_creaUtenteDaRegistrazione]
( 
	@chiave VARCHAR(4000),
	@azienda int,
	@profilo_rel_type varchar(1000),
	@profilo_rel_value_input varchar(1000),
	@idPfu int OUTPUT,
	@bEnte bit = 0
)
AS
BEGIN
	
	SET NOCOUNT ON

	declare @LOGIN as nvarchar(1000)
	declare @NOMECOGNO as nvarchar(4000)
	declare @NOME as nvarchar(4000)
	declare @COGNO as nvarchar(4000)
	declare @QUALIFICA as nvarchar(1000)  
	declare @TEL as nvarchar(500)
	declare @CELL as nvarchar(500)
	declare @MAIL as nvarchar(4000)
	declare @MAIL_RIF as nvarchar(4000)
	declare @CF as varchar(500)
	declare @PREFPROT varchar(1000)
	declare @pfuProfili as varchar(200)
	declare @pfuFunz as varchar(800)
	declare @FUNZ as varchar(800)
	declare @LNG as int
	declare @pfuResponsabileUtente as INT
	declare @AlgoritmoPwd as varchar(2)

	declare @aziStatoLeg2 varchar(500)

	declare @pfuOpzioni as varchar(1000)

	-- Impresa
	IF exists(select IdMpa from MPAziende with(nolock) inner join MarketPlace with(nolock) on idmp=mpaIdMp  where mpaIdAzi = @azienda and mpLog = 'IM' )
	BEGIN
		
		set @pfuOpzioni = '11010100000000000000000000000000000000000000000000'
		
	END
	ELSE
	BEGIN

		IF @bEnte = 0
		BEGIN
			set @pfuOpzioni = '11010110000000000000000000000000000000000000000000'
		END
		ELSE
		BEGIN
			set @pfuOpzioni = '11010100000000000000000000000000000000000000000000'
		END

	END

	

	set @pfuProfili = ''
	set @aziStatoLeg2 = ''

	-- la @chiave corrisponde con session.id ed è la chiave di aggancio con la tabella FormRegistrazione
	
	set @LNG=1
	set @AlgoritmoPwd = '0'
	select @AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary with(nolock) where dzt_name='SYS_PWD_ALGORITMO'

	select @CF=valore from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'cfRapLeg'
	select @TEL=valore from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'telRapLeg'
	select @CELL=valore from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'celRapLeg'
	select @MAIL=valore from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'emailRif' --PFUEMAIL
	select @NOME= ltrim(rtrim(valore)) from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'nomeRapLeg'
	select @COGNO=ltrim(rtrim(valore)) from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'cognomeRapLeg'
	select @QUALIFICA=valore from FormRegistrazione with(nolock) where sessionid = @chiave and nome_campo= 'funzAzi'
	--select @MAIL_RIF=valore from FormRegistrazione where sessionid = @chiave and nome_campo= 'emailRifAzi'--EmailRapLeg
	

	--------------------------------------------------------------------------------------
	-- VERIFICO PER SICUREZZA CHE L'UTENTE A PARITA' DI CF E AZIENDA NON E' GIA CENSITO --
	--------------------------------------------------------------------------------------
	IF EXISTS ( select idpfu from profiliutente with(nolock) where isnull(pfuCodiceFiscale,'') = @CF and pfuIdAzi = @azienda )
	BEGIN
		RAISERROR ('Utente gia censito', 16, 1)
        RETURN 99
	END

	set @NOMECOGNO=@NOME + ' ' +  @COGNO

	IF len(@NOMECOGNO) > 2
	BEGIN
		set @PREFPROT = left(@NOMECOGNO,3)
	END
	ELSE
	BEGIN
		set @PREFPROT = 'AFL'
	END

	declare @Tipoazienda int
	declare @pfuAcquirente int
	declare @pfuVenditore int

	--se venditore=2 è un operatore economico
	select @Tipoazienda=azivenditore, @aziStatoLeg2 = aziStatoLeg2 from aziende with(nolock) where idazi=@AZIENDA

	IF @Tipoazienda = 2
	BEGIN
		--fornitore
		set @pfuAcquirente = 0
		set @pfuVenditore = 1
	END
	ELSE
	BEGIN
		-- TIPOAZIENDA = 0 - ente
		set @pfuAcquirente = 1
		set @pfuVenditore = 0
	END

	-- Insert nella profiliutente per la creazione dell'utente
	INSERT INTO profiliUtente (pfuAcquirente,pfuVenditore,pfuIdAzi,pfuNome,pfucognome,pfunomeutente,pfuLogin,pfuRuoloAziendale,pfuPrefissoProt,pfuIdLng,pfuE_Mail,pfuProfili,pfuFunzionalita,pfuTel,pfuCell,pfuCodiceFiscale,pfuAlgoritmoPassword,pfuResponsabileUtente,pfuOpzioni) 
		VALUES    (@pfuAcquirente,@pfuVenditore,@AZIENDA,@NOMECOGNO,@COGNO,@NOME,@LOGIN,@QUALIFICA,@PREFPROT,@LNG,@MAIL,'B','',@TEL,@CELL,@CF,@AlgoritmoPwd,@pfuResponsabileUtente, @pfuOpzioni)


	set @idpfu = SCOPE_IDENTITY()
		
	-- aggiorno la login con le regole definite per il sistema
    exec ProfiliUtente_GeneraLogin @idpfu 

	-- ( LA PASSWORD la lascio vuota in quanto ne viene generata una temporanea prima dell'invio dell'email di censimento all'utente per poi cifrarla dopo l'invio )

    INSERT INTO ProfiliUtenteAttrib	(IdPfu,dztNome,attValue)
	    select @idpfu as IdPfu , 'profilo' as dztNome, rel_ValueOutput as attValue
			from ctl_relations with(nolock)
			where rel_type = @profilo_rel_type and rel_valueinput = @profilo_rel_value_input


	 -------------------------------------------------------------------------------------------
	 --- PER GLI OPERATORI CHE NON FANNO PARTE DELL'UNIONE EUROPEA CANCELLIAMO I PROFILI PRESENTI NELLA RELAZIONE DEDICATA   ----
	 -------------------------------------------------------------------------------------------
	 --if @aziStatoLeg2 <> 'M-1-11-ITA'
	 if left(@aziStatoLeg2,6) <> 'M-1-11' -- tutti gli stati con padre M-1-11 sono parte del sotto livello unione europea
			and    -- e se lo stato dell'azienda non è presente nella relazione degli stati extra europei per la registrazione peppol
		not EXISTS ( select a.REL_idRow from CTL_Relations a with(nolock) where REL_Type = 'GEO_STATI_REG_PEPPOL' and REL_ValueInput = 'EXTRA_COM_EURO' and REL_ValueOutput = @aziStatoLeg2 )
	 begin
	 
		delete from ProfiliUtenteAttrib	where IdPfu = @idpfu and dztNome = 'profilo' and attValue in ( select REL_ValueOutput from CTL_Relations with(nolock) where REL_Type = 'PROFILI_BASE_ECCEZIONE' and REL_ValueInput = 'ESTERI' ) 

	 end

    update profiliutente
	   set pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU( @idpfu )
	      ,pfuProfili  =  dbo.MERGE_PFUPROFILO_FROM_IDPFU( @idpfu )
	   where idpfu = @idpfu


	-- Se sono un operatore economico gli aggiunto un ruolo di default preso dalla relazione 'RUOLO_DEFAULT'
	IF @bEnte = 0
	BEGIN

		INSERT INTO ProfiliUtenteAttrib	(IdPfu,dztNome,attValue)
			select @idpfu as IdPfu , 'UserRoleDefault' as dztNome, rel_ValueOutput as attValue
			from ctl_relations where rel_type = 'RUOLO_DEFAULT' and rel_valueinput = 'OE'
				--			VALUES ( @idpfu, 'UserRoleDefault', 'OE')

		INSERT INTO ProfiliUtenteAttrib	(IdPfu,dztNome,attValue)
			select @idpfu as IdPfu , 'UserRole' as dztNome, rel_ValueOutput as attValue
			from ctl_relations where rel_type = 'RUOLO_DEFAULT' and rel_valueinput = 'OE'
		

	END

	--return @idPfu

END






GO
