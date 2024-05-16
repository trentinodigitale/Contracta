USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_UTENTE_ELIMINATO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[OLD_CK_UTENTE_ELIMINATO] 
	( @login as nvarchar(200), @azilog as char(7),@pwd as nvarchar(250) )
AS
BEGIN

	SET NOCOUNT ON
	
--	declare @login as nvarchar(200)
--	declare @azilog as char(7)
--	declare @pwd as nvarchar(250)
--	
--	set @login = 'forn_01'
--	set @azilog = 'ER000BG'
--	set	@pwd = 'bg'

	declare @Errore as nvarchar(4000)
	declare @PwdCrypt as nvarchar(250)
	
	declare @Idpfu as int
	
	--recupero idpfu
	select 	@Idpfu=Idpfu from profiliutente,aziende where pfuidazi=idazi and azilog=@azilog and pfulogin=@login
	--select 	@Idpfu=Idpfu from profiliutente,aziende where pfuidazi=idazi and azilog='ER000BG' and pfulogin='forn_01'

	--cifro la pwd
	exec EncryptPwdUser @Idpfu , @pwd , @PwdCrypt output
	--print @PwdCrypt

	--controllo che la terna è corretta
	set @Errore=''
	if exists(select * from profiliutente  where idpfu=@Idpfu and pfupassword=@PwdCrypt)
	begin
		if not exists(select * from profiliutente  where idpfu=@Idpfu and pfupassword=@PwdCrypt and pfudeleted=0)
			set @Errore='utente disabilitato'
	end
	--print 	'errore=' + @Errore

	if @Errore = ''
		-- rirorna OK
		select 'OK' as id , '' as Errore
	else
		select 'ERRORE' as id , @Errore as Errore
	

SET NOCOUNT OFF
END
GO
