USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[END_OFFERTA_CHECK_PRODUCT]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[END_OFFERTA_CHECK_PRODUCT]( @idDoc int , @idUser int ) 
as
begin
	exec AFS_OFFERTA_CRYPT  @idDoc , @idUser
end
GO
