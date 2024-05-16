USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_TEC_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_TEC_CREATE_FROM_OFFERTA] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @idLotto int
	select @idLotto  = id  from Document_MicroLotti_Dettagli with(nolock) where tipodoc = 'OFFERTA' and idheader = @idDoc and NumeroRiga = '0'

	exec OFFERTA_AMPIEZZA_DI_GAMMA_TEC_CREATE_FROM_VOCE @idLotto   , @idUser 

end
GO
