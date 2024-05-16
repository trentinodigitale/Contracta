USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_RICHIESTA_SMART_CIG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_RICHIESTA_SMART_CIG](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on

	declare @idRichiestaSimog  int


	select top 1 @idRichiestaSimog = idRow from [Service_SIMOG_Requests] with(nolock) where idrichiesta = @IdDoc order by idrow desc


	select 
		* 
		, isnull( @idRichiestaSimog , 0 ) as ID_REQUEST
		from CTL_DOC with(nolock) 
		where id = @IdDoc
	

end
GO
