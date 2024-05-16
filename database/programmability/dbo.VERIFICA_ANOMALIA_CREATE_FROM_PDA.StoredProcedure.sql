USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERIFICA_ANOMALIA_CREATE_FROM_PDA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VERIFICA_ANOMALIA_CREATE_FROM_PDA]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	declare @id int
	select @id = id from Document_MicroLotti_Dettagli with (nolock) where idheader = @idDoc and tipodoc = 'PDA_MICROLOTTI' and Voce = 0

	exec VERIFICA_ANOMALIA_CREATE_FROM_LOTTO @id , @IdUser
end
GO
