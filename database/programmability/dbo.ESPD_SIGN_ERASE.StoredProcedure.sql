USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESPD_SIGN_ERASE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [dbo].[ESPD_SIGN_ERASE] ( @IdDoc int , @idPfu int )
as
begin

	------------------------------------------
	-- elimina le informazioni di firma solomanete se l'utente è il 
	-- compilatore ed il documento a cui si fa riferimento è in lavorazione
	------------------------------------------
	if exists( 
				select s.id 
					from CTL_DOC s with(nolock) 
						inner join CTL_DOC r with(nolock) on r.id = s.LinkedDoc 
					where s.id = @idDoc and s.idPfu = @IdPfu and r.Statofunzionale = 'InLavorazione' 
			 )
	begin
		update CTL_DOC set SIGN_ATTACH = '' , SIGN_HASH = '' , SIGN_LOCK = 0 where id = @idDoc and idPfu = @IdPfu
	end

end
GO
