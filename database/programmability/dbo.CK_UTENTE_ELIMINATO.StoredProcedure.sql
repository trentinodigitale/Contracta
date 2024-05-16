USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_UTENTE_ELIMINATO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CK_UTENTE_ELIMINATO] 
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
	declare @pwdComodo  as nvarchar(4000)
	declare @Errore as nvarchar(4000)
	declare @PwdCrypt as nvarchar(2500)
	declare @pfuPassword as nvarchar(2500)
	declare @pfudeleted int
	
	declare @Idpfu as int

	set @Errore=''
	set @idpfu = null

	select 	@idPfu = Idpfu , @pfupassword = pfupassword
					from profiliutente
						INNER JOIN AZIENDE  on pfuidazi=idazi 
					where 
						azilog=@azilog and 
						pfulogin=@login and
						pfudeleted  <> 0 

	-- se esiste l'utente con la tripla esatta ed è annullato
	if @idPfu is not null
	begin

		-- verifico che la password sia la stessa allora è stato disattivato
		exec EncryptPwdUser @Idpfu , @pwd , @PwdCrypt output
		if @PwdCrypt = @pfupassword
		begin

			set @Errore='utente disabilitato'

			set @idpfu = null

			-- ma se esiste anche attivo allora non è disattivato esiste attivo
			select 	@idPfu = Idpfu , @pfupassword = pfupassword
							from profiliutente
								INNER JOIN AZIENDE  on pfuidazi=idazi 
							where 
								azilog=@azilog and 
								pfulogin=@login and
								pfudeleted  = 0 

			if @idPfu is not null
			begin

				-- verifico che la password sia la stessa allora è attivo
				exec EncryptPwdUser @Idpfu , @pwd , @PwdCrypt output
				if @PwdCrypt = @pfupassword
				begin
					set @Errore=''
				end

			end

		end

	end




	if @Errore = ''
	begin
		select 'OK' as id , '' as Errore
	end
	else
	begin

		select 'ERRORE' as id , @Errore as Errore
	end
	

	SET NOCOUNT OFF
END

GO
