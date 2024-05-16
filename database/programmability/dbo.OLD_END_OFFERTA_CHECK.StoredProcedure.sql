USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_END_OFFERTA_CHECK]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[OLD_END_OFFERTA_CHECK]( @iddoc int , @idPfu int )
as 
begin

	declare @TipoDoc as varchar(100)

	--recupero tipo del documento
	select @TipoDoc= Tipodoc from CTL_DOC where id = @iddoc 

	if @TipoDoc in ( 'OFFERTA')
	begin

		
		exec AFS_CRYPTED_CLEAN 'CTL_DOC_ALLEGATI' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI'   , 'id,idheader,EsitoRiga' , '' 
	end

	if @TipoDoc in ( 'RISPOSTA_CONCORSO')
	begin
	
		exec AFS_CRYPTED_CLEAN 'CTL_DOC_ALLEGATI' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI'   , 'id,idRow,idHeader,EsitoRiga,DSE_ID,NotEditable' , '' 
	end

end
GO
