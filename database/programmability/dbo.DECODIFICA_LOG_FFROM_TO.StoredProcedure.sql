USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DECODIFICA_LOG_FFROM_TO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[DECODIFICA_LOG_FFROM_TO] @idpfu int , @idFrom int , @idTo int
as
begin

	declare @idrow INT

	declare CurProg Cursor static for 
		select id from dbo.CTL_LOG_UTENTE with(nolock)
		where id >= @idFrom and id < @idTo and idpfu = @idpfu
		order by id

	open CurProg

	FETCH NEXT FROM CurProg 
	INTO @idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN

		 exec DECODIFICA_LOG @idrow
		 FETCH NEXT FROM CurProg INTO @idrow
	 END 

	CLOSE CurProg
	DEALLOCATE CurProg

end

GO
