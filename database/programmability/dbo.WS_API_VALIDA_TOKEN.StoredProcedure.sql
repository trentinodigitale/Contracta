USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WS_API_VALIDA_TOKEN]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WS_API_VALIDA_TOKEN]( @token nvarchar(1000), @ipChiamante as nvarchar(500) = '' ) 
AS

	SET NOCOUNT ON

	DECLARE @idpfu			INT
	DECLARE @esito			INT
	DECLARE @ipRichiesto	NVARCHAR(MAX)
	DECLARE @error			NVARCHAR(1000)
	declare @minuteToken    INT

	set @esito = 0
	set @idpfu = NULL
	set @error = ''
	set @minuteToken = 30 -- recuperare da ctl_parametri. il default è 30 minuti

	-- SE TROVIAMO UN TOKEN CON DATA LOGIN CHE NON SUPERI LE 24 ORE E RELATIVO AD UN UTENZA NON CESSATA
	select @idpfu = idpfu, @ipRichiesto = ISNULL(pfuIpServerLogin,'') from profiliutente p with(nolock) where pfuToken = @token and pfuDeleted = 0 and datediff(HOUR,pfuLastLogin, GETDATE() ) < 24

	IF @idpfu is null 
	BEGIN
		set @error = 'Token non valido'
	END
	ELSE
	BEGIN


		-- puliamo tutti i record scaduti
		DELETE FROM CTL_SESSION_TOKEN where DATEDIFF(MINUTE, lastAccess, getdate() ) > @minuteToken

		if not exists ( select token FROM CTL_SESSION_TOKEN with(nolock) where token = @token )
		begin
			set @error = 'Token scaduto'
		end
		else
		begin

			set @esito = 1

			update CTL_SESSION_TOKEN
					set lastAccess = getdate()
				where token = @token

			-- se è richiesto il controllo sull'ip
			IF @ipRichiesto <> '' and @ipChiamante <> ''
			BEGIN
			
				IF CHARINDEX(@ipChiamante, @ipRichiesto) > 0
					set @esito = 1
				else
				begin
					set @esito = 0
					set @error = 'Chiamante non riconosciuto'
				end

			END

		end

	END

	select @esito as esito, @error as error, @idpfu as idpfu

GO
