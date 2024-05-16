USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_GARA_AQ_QUOTE_CREATE_FROM_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BANDO_GARA_AQ_QUOTE_CREATE_FROM_AQ] 
	( @idAQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @errore as varchar(800)
	set @errore=''
	
	set @id=@idAQ

			
	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
				
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end



END

	
GO
