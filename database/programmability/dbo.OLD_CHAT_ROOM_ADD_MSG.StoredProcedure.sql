USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CHAT_ROOM_ADD_MSG]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_CHAT_ROOM_ADD_MSG]( @idPfu int , @Room int , @MSG nvarchar(max) , @Type varchar(20) = 'MSG' ) 
as 
begin
	set nocount on


	if exists( select * from CTL_CHAT_ROOMS with(nolock) where idHeader  = @Room and Chat_Stato = 'OPEN' )
	begin
		declare @D datetime
		set @D = convert( varchar(19) , getdate() , 121)


		insert into CTL_CHAT_MESSAGES (  idHeader, idPfu, DataIns, Message , Type ) values( @Room , @idPfu , @D , @MSG , @Type )
		update CTL_CHAT_ROOMS set LastUpd = getdate() where idHeader = @Room

	end

end



GO
