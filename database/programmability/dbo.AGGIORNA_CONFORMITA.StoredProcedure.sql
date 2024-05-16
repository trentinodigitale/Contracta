USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AGGIORNA_CONFORMITA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AGGIORNA_CONFORMITA]( @idDocConformita INT )
as
BEGIN

	-- SE NON SONO RIMASTI LOTTI DA VERIFICARE (SONO TUTTI REGREDITI O SOSPESI) ANNULLIAMO ANCHE IL DOCUMENTO DI [CONFORMITA_MICROLOTTI].
	IF NOT EXISTS ( select Id from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idDocConformita and StatoRiga not in ( 'Sospeso', 'regredito' ) and tipodoc = 'CONFORMITA_MICROLOTTI')
	BEGIN

		UPDATE CTL_DOC
				SET StatoFunzionale = 'Annullato' 
			where ID = @idDocConformita

	END

END


GO
