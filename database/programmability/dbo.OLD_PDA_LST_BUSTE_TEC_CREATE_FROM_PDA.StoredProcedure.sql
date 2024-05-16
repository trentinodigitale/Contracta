USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_LST_BUSTE_TEC_CREATE_FROM_PDA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   PROCEDURE [dbo].[OLD_PDA_LST_BUSTE_TEC_CREATE_FROM_PDA] 
	( @idDoc int -- rappresenta l'id dela riga del lotto, legato alla PDA, sul quale si fa la valutazione
	, @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT

	declare @Errore as nvarchar(2000)
	set @Errore = ''


	if @Errore = '' 
	begin



		set @Id = @idDoc
		update Document_MicroLotti_Dettagli set StatoRiga = 'InValutazione' where id = @Id and StatoRiga = 'daValutare'




	end
		
	



	if @Errore = ''
	begin
		-- rirorna l'id del documento
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END
GO
