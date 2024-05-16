USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CHAT_ROOM_ENTRY]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- effettua l'iscrizione ad una chat
CREATE  proc [dbo].[OLD_CHAT_ROOM_ENTRY](  @idPfu int , @idRoom int  ) 
as 
begin
	set nocount on


	-- verifico la presenza dell'utente nella chat
	if not exists( select LastUpd from CTL_CHAT_LAST_UPD u with(nolock) where idPfu = @idPfu and idHeader = @idRoom )
	begin

		if exists ( select id from CTL_CHAT_ROOMS where  idHeader = @idRoom )
			-- se non è presente viene iscritto alla chat	
			insert into CTL_CHAT_LAST_UPD ( idHeader, idPfu, LastUpd  ) values ( @idRoom , @idPfu , getdate() )


	end


end


GO
