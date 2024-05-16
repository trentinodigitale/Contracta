USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateUserSSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[UpdateUserSSO]( 
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

	select @AziMaster  = mpIdAziMaster   from marketplace

	update profiliutente 
		set pfuRuoloAziendale = @Ruolo
			, pfuTel = @Telefono
			, pfuE_Mail = @Mail
		where pfuCodiceFiscale = @CodiceFiscale and pfuidazi = @AziMaster and pfudeleted = 0

	select pfuLogin , dbo.DecryptPwd( pfuPassword ) as pfuPassword , aziLog  
		from profiliutente 
			inner join aziende on pfuidazi = idazi 
		where pfuidazi = @AziMaster and pfuCodiceFiscale = @CodiceFiscale and pfudeleted = 0

end
GO
