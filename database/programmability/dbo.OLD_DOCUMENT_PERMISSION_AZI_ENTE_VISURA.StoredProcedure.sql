USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_AZI_ENTE_VISURA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_AZI_ENTE_VISURA]
( 
	@idPfu   as int  , 
	@idazienda as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	if upper( substring( @idazienda, 1, 3 ) ) = 'NEW' and @param is null 
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
			
			set @idazienda = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
			
		end

		declare @idAzi int
		select @idAzi = pfuIdAzi  from profiliutente with(nolock)where idPfu = @idPfu

		-- Se l'utente appartiene all'azienda master gli permettiamo l'apertura di qualsiasi 
		if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) 
			and -- hai almeno un ruolo associato
			exists( select * from profiliutenteattrib where dztnome = 'UserRole' and idpfu = @idPfu )
		begin
			select 1 as bP_Read , 1 as bP_Write
		end
		else
		begin
		
			-- Verifico se l'utente stà aprendo la scheda della sua azienda
			if @idAzi = cast( @idazienda as int )
				select 1 as bP_Read , 1 as bP_Write
			else
				select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
			
		end
		
	end
	

end








GO
