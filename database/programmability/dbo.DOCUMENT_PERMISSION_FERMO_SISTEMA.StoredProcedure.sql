USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_FERMO_SISTEMA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DOCUMENT_PERMISSION_FERMO_SISTEMA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL     
)
as
begin

	SET NOCOUNT ON

	declare @passed int

	set @passed = 0

	-- se il documento è in uno stato di "non inviato" o new, lo può aprire solo chi possiede il permesso 188
	--		altrimenti il documento è apribile da chiunque

	IF EXISTS ( select idpfu from profiliutente with(nolock) where idpfu = @idPfu and substring( pfuFunzionalita, 188,1 ) = '1' )
	BEGIN

		-- chi ha il permesso 188 può fare tuttp
		set @passed = 1 

	END
	ELSE
	BEGIN

		-- SE NON HAI IL PERMESSO 188 IL DOCUMENTO DEVE ESSERE NELLO STATO DI INVIATO/CONFERMATO
		IF isnumeric(@idDoc) = 1 and EXISTS ( select id from ctl_doc with(nolock) where id = @idDoc and StatoFunzionale = 'Confermato' )
			set @passed = 1 

	END

	insert into ctl_trace(descrizione) values ( @passed )

	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select top 0 0 as bP_Read , 0 as bP_Write

end


GO
