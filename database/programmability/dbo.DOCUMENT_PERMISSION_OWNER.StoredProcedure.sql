USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_OWNER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
-- stored che controlla l'accessibilita ai documenti presenti nella CTL_DOC
-- per owner
---------------------------------------------------------------
create proc [dbo].[DOCUMENT_PERMISSION_OWNER]
(
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL
)
as
begin

	-- Se il documento è nuovo
	if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param is null 
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	
		-- Se stiamo aprendo un documento come create from
		-- non bisogna controllare il parametro idazienda che sarà NEW
		-- ma quello dopo la virgola nel parametro param  . es : AZIENDA, 123
		
		if not @param is null 
		begin
			
			set @idDoc = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
			
		end
	
		declare @idOwner int
		select @idOwner = IdPfu  from ctl_doc with(nolock) where id = @idDoc
		
		declare @idAzi int
		select @idAzi = pfuIdAzi  from profiliutente with(nolock)where idPfu = @idPfu
		

		--			 select * from ctl_doc doc
		--						inner join profiliutente ut on doc.idpfu = ut.idpfu 
		--		 				inner join LIB_Documents sec on doc.tipoDoc = sec.DOC_ID and ( isnull(DOC_PosPermission,0) = 0 or substring( ut.pfufunzionalita, isnull(DOC_PosPermission,0) , 1 ) = 1 )

		
		-- Se l'utente fa parte dell'azienda master gli permettiamo l'apertura di qualsiasi documento
		if exists(
					select * from profiliutente inner join marketPlace on pfuidazi = mpIdAziMaster where idpfu = @idPfu
				 )					
		begin
		
			select 1 as bP_Read , 1 as bP_Write
		
		end
		else
		begin										 
					
			-- Se l'utente che sta aprendo il documento è l'owner
			if @idOwner = cast( @idPfu as int )
				select 1 as bP_Read , 1 as bP_Write
			else
				select top 0 0 as bP_Read , 0 as bP_Write
		
		end
	end

end


GO
