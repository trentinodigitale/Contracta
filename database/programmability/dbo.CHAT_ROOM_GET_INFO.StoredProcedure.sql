USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_GET_INFO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  proc [dbo].[CHAT_ROOM_GET_INFO]( @idRoom int , @Time varchar(30) ) 
as 
begin
	set nocount on

	declare @DS datetime


	-- definisco la data da cui estrarre le informazioni della chat
	if @Time <> ''
		set @DS = convert( datetime , @Time , 121 )
	else
		set @DS = convert( datetime , '1900-01-01 00:00:00' , 121 )


	select * , convert( varchar(19) ,LastUpd , 121 ) as LastTime from CTL_CHAT_ROOMS where idHeader = @idRoom and LastUpd > @DS

end


GO
