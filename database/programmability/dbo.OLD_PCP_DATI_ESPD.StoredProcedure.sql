USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PCP_DATI_ESPD]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_PCP_DATI_ESPD] 
	-- Add the parameters for the stored procedure here
	(@idDoc int)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select top 1 outputWS from Services_Integration_Request with(nolock) 
	where 
		idRichiesta = @idDoc and 
		integrazione = 'PCP' and
		datoRichiesto = 'XML_ESPD'
	order by 1 desc


END
GO
