USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_UPD]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[CHAT_ROOM_UPD]( @idPfu int , @Room int , @Title nvarchar(max)  , @Stato varchar(20)  ) 
as 
begin
	set nocount on


	if exists( select * from CTL_CHAT_ROOMS with(nolock) where idHeader  = @Room  )
	begin

		if @Title <> '' 
			update CTL_CHAT_ROOMS set Title = @Title where idheader = @Room


		if @Stato in (  'CLOSE' , 'OLD' )
			update CTL_CHAT_ROOMS set DateEnd = getdate() ,Chat_Stato = @Stato  where idheader = @Room

		if @Stato = 'OPEN'
			update CTL_CHAT_ROOMS set DateEnd = null , Chat_Stato = @Stato  where idheader = @Room

	end

end

GO
