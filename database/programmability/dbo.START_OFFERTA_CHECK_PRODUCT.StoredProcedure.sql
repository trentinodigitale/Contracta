USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[START_OFFERTA_CHECK_PRODUCT]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[START_OFFERTA_CHECK_PRODUCT]( @idDoc int , @idUser int ) 
as
begin
	exec AFS_OFFERTA_DECRYPT @idDoc , @idUser
end
GO
