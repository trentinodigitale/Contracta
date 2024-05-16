USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_OE_DA_CONTROLLARE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[DOCUMENT_PERMISSION_OE_DA_CONTROLLARE]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin
		
	declare @TipoDoc as varchar(200)	
	declare @passed int -- variabile di controllo
	set @passed = 0 -- non passato
	
	IF  EXISTS ( select P.idpfu 
					from CTL_DOC C with(nolock) 
						inner join ProfiliUtente P with(nolock)  on P.pfuIdAzi=C.Azienda and P.pfuDeleted=0
					where C.id=@idDoc and P.IdPfu=@idPfu
			   )
	BEGIN
		set @passed=1
	END


	-- Verifico se l'utente può aprire
	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100	

end


GO
