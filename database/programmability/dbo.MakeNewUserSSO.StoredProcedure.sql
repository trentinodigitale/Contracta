USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MakeNewUserSSO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[MakeNewUserSSO]( 
	@Nome as nvarchar(100) 
	, @Cognome as varchar(100) 
	, @Ruolo as nvarchar(200) 
	, @Telefono  as nvarchar(100) 
	, @Mail  as nvarchar(100) 
	, @CodiceFiscale  as nvarchar(100) 
)
as
begin

	declare @AziMaster   int
	declare @pfuFunzionalita varchar(400)
	declare @newUser int

	select @AziMaster  = mpIdAziMaster   from marketplace
	select top 1 @pfuFunzionalita = pfuFunzionalita from ProfiliUtente where pfuidazi = @AziMaster order by idpfu desc

	insert into ProfiliUtente ( pfuIdAzi , pfuNome , pfuLogin , pfuRuoloAziendale , pfuPassword , 
									pfuPrefissoProt ,pfuAcquirente ,pfuIdLng ,pfuE_Mail ,
									 pfuFunzionalita, pfuTel , pfuCodiceFiscale )
		values( @AziMaster , @Nome + ' ' + @Cognome , '' , @Ruolo , ''  , 
									left( @Cognome , 3 )  , 1 ,1 ,@Mail ,
									 @pfuFunzionalita, @Telefono , @CodiceFiscale )
		
	set @newUser = SCOPE_IDENTITY()

	update ProfiliUtente set pfuLogin = cast( @newUser as varchar ) , pfuPassword = dbo.EncryptPwd( cast( @newUser as varchar ) ) where idpfu = @newUser

	select pfuLogin , dbo.DecryptPwd( pfuPassword ) as pfuPassword , aziLog  
		from profiliutente 
			inner join aziende on pfuidazi = idazi 
		where pfuidazi = @AziMaster and pfuCodiceFiscale = @CodiceFiscale and pfudeleted = 0

end


GO
