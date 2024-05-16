USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PCP_DATI_ESPD]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PCP_DATI_ESPD] (@idDoc int)
AS
BEGIN

	SET NOCOUNT ON

	select top 1 outputWS 
		from Services_Integration_Request with(nolock) 
		where idRichiesta = @idDoc and 
				integrazione = 'PCP' and
				--datoRichiesto = 'XML_ESPD'
				operazioneRichiesta = 'genera-xml-espd'
		order by idRow desc

END

GO
