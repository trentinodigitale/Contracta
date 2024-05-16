USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_START_OFFERTA_CHECK]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   procedure [dbo].[OLD_START_OFFERTA_CHECK]( @iddoc int , @idPfu int )
as 
begin

	declare @TipoDoc as varchar(100)

	--recupero tipo del documento
	select @TipoDoc= Tipodoc from CTL_DOC where id = @iddoc 


	if @TipoDoc in ( 'RISPOSTA_CONCORSO')
	begin
		exec AFS_DECRYPT_DATI  @idpfu ,  'CTL_DOC_ALLEGATI' , 'BUSTA_AMMINISTRATIVA' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI'  , 'id,idRow,idHeader,EsitoRiga,DSE_ID,NotEditable' , '' , 0 
	end
	else

	begin
		exec AFS_DECRYPT_DATI  @idpfu ,  'CTL_DOC_ALLEGATI' , 'BUSTA_AMMINISTRATIVA' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI'  , 'idrow,idheader,EsitoRiga' , '' , 0 
	end

end

GO
