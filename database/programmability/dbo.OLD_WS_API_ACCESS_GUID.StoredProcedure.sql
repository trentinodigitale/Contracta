USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_WS_API_ACCESS_GUID]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_WS_API_ACCESS_GUID]( @guid nvarchar(1000)) 
AS

	SET NOCOUNT ON

	DECLARE @idpfu			INT
	set @idpfu = NULL

	select @idpfu = idpfu from CTL_ACCESS_BARRIER with(nolock) where guid = @guid and datediff(SECOND, data,getdate()) <= 60

	if not @idpfu is null
	begin
		-- se trovo il guid cancello il record dopo averlo usato
		delete from CTL_ACCESS_BARRIER where guid = @guid
	end

	select @idpfu as idpfu

GO
