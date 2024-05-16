USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SSO_UpdateUser]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[OLD_SSO_UpdateUser] ( 
		@idPfu int,
		@CF varchar(100),
		@COGNO nvarchar(4000),
		@NOME nvarchar(4000),
		@MAIL nvarchar(1000),
		@TEL varchar(500)
)
AS

	SET NOCOUNT ON 

	DECLARE @datiVariati	INT
	DECLARE @CF1 varchar(100)
	DECLARE @COGNO1 nvarchar(4000)
	DECLARE @NOME1 nvarchar(4000)
	DECLARE @MAIL1 nvarchar(1000)
	DECLARE @TEL1 varchar(500)
	declare @NOMECOGNO as nvarchar(4000)

	set @datiVariati = 0
	set @NOMECOGNO = ''

	select top 1 @cf1 = pfu.pfuCodiceFiscale
				,@COGNO1 = pfu.pfuCognome 
				,@nome1 = pfu.pfuNome 
				,@MAIL1 = pfu.pfuE_Mail
				,@tel1 = pfu.pfuTel
		from profiliutente pfu with(nolock)
		where pfu.idpfu = @idPfu

	IF @cf1 <> @cf OR @COGNO1 <> @COGNO OR @nome1 <> @nome 
		OR @MAIL1 <> @MAIL OR @tel1 <> @tel
	BEGIN
		set @datiVariati = 1
	END

	IF @datiVariati = 1
	BEGIN
		

		set @NOMECOGNO=@NOME + ' ' +  @COGNO

		UPDATE ProfiliUtente 
			set pfuCodiceFiscale = @cf
				,pfuCognome = @COGNO
				,pfunomeutente = @NOME
				,pfunome = @NOMECOGNO
				,pfuE_Mail = @mail
				,pfuTel = @TEL 
		where idpfu = @idPfu

		-- Chiamo la stored per la creazione del documento anagrafica
		exec SSO_InsertDocUser @idPfu

	END
	
GO
