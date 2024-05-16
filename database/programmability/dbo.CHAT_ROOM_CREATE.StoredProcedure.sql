USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_CREATE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[CHAT_ROOM_CREATE]( @idPfu int , @Room int , @Title nvarchar(max) ) 
as 
begin
	set nocount on


	if not exists( select * from CTL_CHAT_ROOMS with(nolock) where idHeader  = @Room  )
	begin

		insert into CTL_CHAT_ROOMS (  idHeader, Title, Owner, Chat_Stato, DateStart, DateEnd, LastUpd ) values( @Room , @Title , @idPfu , 'OPEN' , getdate() ,  null , getdate() )

	end

end

GO
