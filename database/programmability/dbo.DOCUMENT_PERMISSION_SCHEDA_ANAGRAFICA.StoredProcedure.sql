USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_SCHEDA_ANAGRAFICA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[DOCUMENT_PERMISSION_SCHEDA_ANAGRAFICA]( 
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

			-- Se sono un utente dell'azienda a cui voglio accedere oppure sono un ente	

			IF EXISTS ( select idpfu from  profiliutente p1 with(nolock)  where pfuIdazi = @idDoc and  idpfu=@idPfu  )
				OR
			  EXISTS ( select idpfu from  profiliutente p, aziende az where p.pfuidazi = az.idazi and p.idpfu=@idPfu and az.aziAcquirente <> 0  )
			BEGIN

				select  top 1 1 as bP_Read , 1 as bP_Write

			END
			ELSE
			BEGIN

				select top 0 0 as bP_Read , 0 as bP_Write

			END
	end
end

GO
