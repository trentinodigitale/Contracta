USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_PCP_DETTAGLIO_ERRORE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[GET_PCP_DETTAGLIO_ERRORE] ( @idUser int , @param varchar(max)='')
AS
BEGIN
	
	--@param contiene idrow della Services_Integration_Request

	select 
		*
		from 
		Services_Integration_Request with (nolock)
			where idrow = CAST(@param as int)

	

END
GO
