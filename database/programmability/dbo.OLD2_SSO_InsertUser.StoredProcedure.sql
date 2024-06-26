USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SSO_InsertUser]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD2_SSO_InsertUser]
( 
	@CF varchar(100),
	@COGNO nvarchar(4000),
	@NOME nvarchar(4000),
	@MAIL nvarchar(1000),
	@TEL varchar(500),
	@azienda int,
	@userID varchar(500),
	@isEnte bit = 0
)
AS
BEGIN
	
	SET NOCOUNT ON

	declare @LOGIN as nvarchar(1000)
	declare @NOMECOGNO as nvarchar(4000)

	declare @QUALIFICA as nvarchar(1000)  

	declare @PREFPROT varchar(1000)
	declare @pfuProfili as varchar(200)
	declare @pfuFunz as varchar(800)
	declare @FUNZ as varchar(800)
	declare @LNG as int
	declare @pfuResponsabileUtente as INT
	declare @AlgoritmoPwd as varchar(2)

	declare @pfuOpzioni as varchar(1000)

	declare @pfuAcquirente int
	declare @pfuVenditore int

	DECLARE @idpfu INT

	DECLARE @profilo_rel_type VARCHAR(200)
	DECLARE @profilo_rel_value_input VARCHAR(200)

	IF @isEnte = 0
	BEGIN
		set @pfuOpzioni = '11010110000000000000000000000000000000000000000000'
	END
	ELSE
	BEGIN
		set @pfuOpzioni = '11010100000000000000000000000000000000000000000000'
	END

	set @pfuProfili = ''
	set @LNG=1
	set @AlgoritmoPwd = '0'
	select @AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary where dzt_name='SYS_PWD_ALGORITMO'

	set @NOMECOGNO=@NOME + ' ' +  @COGNO

	IF len(@NOMECOGNO) > 2
	BEGIN
		set @PREFPROT = left(@NOMECOGNO,3)
	END
	ELSE
	BEGIN
		set @PREFPROT = 'AFL'
	END

	IF @isEnte = 0
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
	INSERT INTO profiliUtente (pfuAcquirente,pfuVenditore,pfuIdAzi,pfuNome,pfucognome,pfunomeutente,pfuLogin,pfuRuoloAziendale,pfuPrefissoProt,pfuIdLng,pfuE_Mail,pfuProfili,pfuFunzionalita,pfuTel,pfuCell,pfuCodiceFiscale,pfuAlgoritmoPassword,pfuResponsabileUtente,pfuOpzioni, pfuUserID) 
		VALUES    (@pfuAcquirente,@pfuVenditore,@AZIENDA,@NOMECOGNO,@COGNO,@NOME,@LOGIN,@QUALIFICA,@PREFPROT,@LNG,@MAIL,'B','',@TEL,'',@CF,@AlgoritmoPwd,@pfuResponsabileUtente, @pfuOpzioni,@userID)

		--if @@error <> 0
		--begin
		--	raiserror  ('errore inswer', 16, 1)
		--	return
		--end

	--SELECT @@IDENTITY

	set @idpfu = scope_identity()

	--PRINT @idpfu
		
	-- aggiorno la login con le regole definite per il sistema
    exec ProfiliUtente_GeneraLogin @idpfu 

	IF @isEnte = 0
	BEGIN
		SET @profilo_rel_type = 'PROFILI_BASE'
		SET @profilo_rel_value_input = 'OE'
	END
	ELSE
	BEGIN
		SET @profilo_rel_type = 'PROFILI_BASE'
		SET @profilo_rel_value_input = 'Ente'
	END

    INSERT INTO ProfiliUtenteAttrib
			(IdPfu,dztNome,attValue)
	    select @idpfu as IdPfu , 'profilo' as dztNome, rel_ValueOutput as attValue
			from ctl_relations where rel_type = @profilo_rel_type and rel_valueinput = @profilo_rel_value_input

    UPDATE profiliutente
	   set pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU( @idpfu )
	      ,pfuProfili  =  dbo.MERGE_PFUPROFILO_FROM_IDPFU( @idpfu )
	   where idpfu = @idpfu

	-- Se sono un operatore economico gli aggiunto un ruolo di default preso dalla relazione 'RUOLO_DEFAULT'
	IF @isEnte = 0
	BEGIN

		INSERT INTO ProfiliUtenteAttrib	(IdPfu,dztNome,attValue)
			select @idpfu as IdPfu , 'UserRoleDefault' as dztNome, rel_ValueOutput as attValue
			from ctl_relations where rel_type = 'RUOLO_DEFAULT' and rel_valueinput = 'OE'

		INSERT INTO ProfiliUtenteAttrib	(IdPfu,dztNome,attValue)
			select @idpfu as IdPfu , 'UserRole' as dztNome, rel_ValueOutput as attValue
			from ctl_relations where rel_type = 'RUOLO_DEFAULT' and rel_valueinput = 'OE'
		

	END

	-- ritorno al chiamante l'idpfu generato
	SELECT @idpfu as idPfu

END


GO
