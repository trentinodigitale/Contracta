USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_START_OFFERTA_CHECK]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   procedure [dbo].[OLD2_START_OFFERTA_CHECK]( @iddoc int , @idPfu int )
as 
begin


	begin
		exec AFS_DECRYPT_DATI  @idpfu ,  'CTL_DOC_ALLEGATI' , 'BUSTA_AMMINISTRATIVA' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI'  , 'idrow,idheader,EsitoRiga' , '' , 0 
	end

end


GO
