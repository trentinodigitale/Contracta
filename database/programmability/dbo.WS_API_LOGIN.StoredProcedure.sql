USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WS_API_LOGIN]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WS_API_LOGIN]( @CodiceAzienda varchar(100), @CodiceUtenza as nvarchar(100), @Password as nvarchar(500), @ipChiamante as nvarchar(500) = '') 
AS

	SET NOCOUNT ON

	DECLARE @idpfu		  INT
	DECLARE @pfuDeleted   INT
	DECLARE @aziDeleted   INT
	DECLARE @error		  NVARCHAR(1000)
	DECLARE @pfuToken	  NVARCHAR(1000)
	DECLARE @pfuStato     NVARCHAR(100)
	DECLARE @pfuPass	  NVARCHAR(500)
	DECLARE @pfuTentativi INT
	DECLARE @maxTentativi INT

	set @idpfu = NULL
	set @pfuDeleted = 0
	set @maxTentativi = 10
	set @error = ''
	set @pfuToken = ''

	select  @idpfu = p.idpfu, 
			@pfuDeleted = p.pfuDeleted,
			@aziDeleted = azi.aziDeleted,
			@pfuStato = pfuStato,
			@pfuPass = dbo.DecryptPwd(pfuPassword),
			@pfuTentativi = pfuTentativiLogin
		from Aziende azi with(nolock)
				inner join profiliutente p with(nolock) on azi.idazi = p.pfuidazi and pfuLogin = @CodiceUtenza
		where azilog = @CodiceAzienda
	
	-- SE LA COPPIA AZILOG+USERNAME E' CORRETTA
	IF NOT @idpfu IS NULL
	BEGIN

		IF @pfuPass = @Password
		BEGIN

			IF @pfuDeleted = 1 or @aziDeleted = 1
			BEGIN
				set @error = 'Utenza cessata, rivolgersi all''amministratore'
			END
			ELSE
			BEGIN

				-- capire dove mettere l'ip (lista?) autorizzato ad accedere con questa utenza e confrontarlo con la variabile passata in input @ipChiamante ( se diversa da vuota )

				set @pfuToken = NEWID()

				UPDATE profiliutente
						set pfuLastLogin = getdate(),
							pfuToken = @pfuToken,
							pfuTentativiLogin = 0
					where idpfu = @idpfu

				DELETE FROM CTL_SESSION_TOKEN where idpfu = @idpfu

				INSERT INTO CTL_SESSION_TOKEN( idpfu, token, lastAccess) VALUES ( @idpfu, @pfuToken, getdate() )

			END

		END
		ELSE
		BEGIN

			-- se sono stati raggiunti il numero massimo di tentativi
			IF @pfuStato = 'block' 
			BEGIN
				set @error = 'I dati inseriti sono riferiti ad un utenza bloccata, rivolgersi all''amministratore'
			END
			ELSE
			BEGIN

				-- SE LA COPPIA AZILOG + USERNAME E' CORRETTA, MA HA SBAGLIATO LA PASSWORD INCREMENTIAMO I TENTATIVI E VERIFICHIAMO SE HA SUPERATO IL LIMITE

				set @pfuTentativi = @pfuTentativi+1

				UPDATE profiliutente
						set pfuTentativiLogin = @pfuTentativi
					where idpfu = @idpfu

				select @maxTentativi = cast(DZT_ValueDef as int) from lib_dictionary with(nolock) where dzt_name = 'SYS_PWD_TENTATIVI_LOGIN'

				if @pfuTentativi >= @maxTentativi
				begin
					set @error = 'E'' stato raggiunto il limite di tentativi errati per accedere al sistema'
				end

			END

		END

	END
	ELSE
	BEGIN

		set @error = 'Dati di login non corretti'

	END

	select @pfuToken as token, @error as error

GO
