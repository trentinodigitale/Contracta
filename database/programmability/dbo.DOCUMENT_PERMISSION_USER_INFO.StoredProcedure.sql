USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_USER_INFO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[DOCUMENT_PERMISSION_USER_INFO]( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL     )
as
begin

	declare @idAzi			int
    declare @IdAziMaster as int
	declare @AziFrom		varchar(100)


	select @IdAziMaster=mpidazimaster from marketplace
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu

	--azienda master vede tutto
	if @idAzi=@IdAziMaster 
	begin
		select  top 1 1 as bP_Read , 1 as bP_Write
	end
	else
	begin

		-- devo essere un utente dell'azienda su cui voglio accedere
		select  top 1 1 as bP_Read , 1 as bP_Write
			from  profiliutente p1 with(nolock)  
			where pfuIdazi = @idAzi 
				and  idpfu=@idDoc 
						
	
	end
end



GO
