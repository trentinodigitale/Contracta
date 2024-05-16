USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_ADD_MSG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[CHAT_ROOM_ADD_MSG]( @idPfu int , @Room int , @MSG nvarchar(max) , @Type varchar(20) = 'MSG' ) 
as 
begin
	set nocount on


	if exists( select * from CTL_CHAT_ROOMS with(nolock) where idHeader  = @Room and Chat_Stato = 'OPEN' )
		and
		exists( select * from CTL_CHAT_LAST_UPD with(nolock) where idPfu = @idPfu and idHeader = @Room )
	begin
		declare @D datetime
		set @D = convert( varchar(19) , getdate() , 121)


		insert into CTL_CHAT_MESSAGES (  idHeader, idPfu, DataIns, Message , Type ) values( @Room , @idPfu , @D , @MSG , @Type )
		update CTL_CHAT_ROOMS set LastUpd = getdate() where idHeader = @Room

	end

end




GO
