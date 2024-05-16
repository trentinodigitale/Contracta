USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_ISTANZA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[DOCUMENT_PERMISSION_ISTANZA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON

	if ( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' OR @idDoc = '' )  --and 
		--( dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = ''  OR	dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = 'RDO_PRESTAZIONI'  )
	
	-- @param is null 
		--or
		--exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue = 'Amministratore' and idPfu = @idPfu )
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin


			if 
				exists( select * from ctl_doc where TipoDoc='ISTANZA_AlboOperaEco_QF'  and id=@idDoc and idpfu=@idPfu )
					or
				exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue = 'ADMIN' and idPfu = @idPfu )
			begin
				select 1 as bP_Read , 1 as bP_Write
				--select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
			end
			else
			begin
			   select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
			end

	end



end

GO
