USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO_AUTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO_AUTO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN

	declare @Id as INT
	declare @NumeroLotto varchar(200)
	declare @ML_Note nvarchar (4000)
	declare @idRow int 
	declare @NewDoc int 

	
	exec PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO  @idDoc , @IdUser , @id output
		

	-- per ogni lotto creo il documento di sorteggio automatico	
				
	declare @getDate datetime
	set @getDate = getDate()		

	set @ML_Note = dbo.CNV_ESTESA( 'ML_Eseguito sorteggio automatico delle offerte in exequo' , 'I' )

	-- per ogni microlotto del bando in exequo
	declare crs_pccfs cursor static for 
		select NumeroLotto , m.id from CTL_DOC d
				inner join Document_MicroLotti_Dettagli m on m.idheader = d.id 
															and m.tipodoc = 'PDA_MICROLOTTI'
															and m.Exequo = 1
		where d.id = @idDoc 
		order by cast( NumeroLotto as int )

	open crs_pccfs 
	fetch next from crs_pccfs into @NumeroLotto ,@idRow
	while @@fetch_status=0 
	begin 



		exec PDA_SORTEGGIO_OFFERTA_CREATE_FROM_SORTEGGIO @idRow , @IdUser 
		


		fetch next from crs_pccfs into @NumeroLotto ,@idRow
	end 
	close crs_pccfs 
	deallocate crs_pccfs



	-- ritorna l'id della nuova comunicazione appena creata
	select @Id as id

END


GO
