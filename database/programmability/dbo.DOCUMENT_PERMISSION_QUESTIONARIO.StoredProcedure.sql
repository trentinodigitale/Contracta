USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_QUESTIONARIO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[DOCUMENT_PERMISSION_QUESTIONARIO]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON

	/*
	if ( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' OR @idDoc = '' )  --and 
		
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	*/

			if 
				exists( select * from ctl_doc a
							left outer join CTL_DOC_DESTINATARI on CTL_DOC_DESTINATARI.idheader=a.Id
								where TipoDoc='QUESTIONARIO_FORNITORE'  and id=@idDoc and isnull(CTL_DOC_DESTINATARI.IdPfu,-1) = @idPfu )
					or
				exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue = 'ADMIN' and idPfu = @idPfu )

			begin
				select 1 as bP_Read , 1 as bP_Write						
			end
			else
			begin
			   select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
			end

	--end



end

GO
