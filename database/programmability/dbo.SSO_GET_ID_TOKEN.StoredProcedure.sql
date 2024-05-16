USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SSO_GET_ID_TOKEN]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SSO_GET_ID_TOKEN] (@guid nvarchar(400), @idpfu INT = 0 )
AS

	SET NOCOUNT ON

	declare @token nvarchar(max)

	select @token = id_token from CTL_ACCESS_BARRIER with(nolock) where [guid] = @guid
	
	if @token <> ''
	begin

		DELETE CTL_ACCESS_BARRIER where [guid] = @guid
		select isnull(@token,'') as idToken

	end
	else
	begin
		select top 0 '' as idToken
	end

GO
