USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COPY_OFFERTA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PDA_COPY_OFFERTA]( @idSource int , @idDest int , @Escludi varchar(4000))
AS
begin

	declare @sql as varchar(8000)


	set @sql = 'update D set '




	set @sql = 'from Document_MicroLotti_Dettagli as D , Document_MicroLotti_Dettagli as S
			Where D.id = ' + cast( @idDest as varchar ) + ' and S.id = ' + cast( @idSource as varchar ) 


end
GO
