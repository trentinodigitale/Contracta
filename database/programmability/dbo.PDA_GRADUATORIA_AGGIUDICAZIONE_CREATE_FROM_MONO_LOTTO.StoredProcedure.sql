USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_MONO_LOTTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_MONO_LOTTO] ( @idDoc int , @IdUser int  )
AS
BEGIN

	declare @Id as INT

	select @Id = id  from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idDoc and NumeroLotto = '1' and ISNULL(voce,0) = 0

	exec PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_LOTTO @Id, @IdUser
	
END


GO
