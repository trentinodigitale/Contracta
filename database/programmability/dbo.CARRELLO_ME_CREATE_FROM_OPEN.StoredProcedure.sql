USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CARRELLO_ME_CREATE_FROM_OPEN]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[CARRELLO_ME_CREATE_FROM_OPEN] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	
	set @id = @IdUser
	set @Errore = ''

	if @Errore = ''
	begin
		-- rirorna l'id del carrello
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

SET NOCOUNT OFF
END







GO
