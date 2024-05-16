USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_IN_OUT_USER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[CHAT_ROOM_IN_OUT_USER]( @idPfu int , @Room int ,  @Type varchar(20) ) 
as 
begin
	set nocount on
		
	declare @D datetime
	set @D = convert( varchar(19) , getdate() , 121)

	insert into CTL_CHAT_MESSAGES (  idHeader, idPfu, DataIns, Message , Type ) values( @Room , @idPfu , @D , '' , @Type )
	update CTL_CHAT_ROOMS set LastUpd = getdate() where idHeader = @Room
	
end







GO
