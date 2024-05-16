USE [AFLink_TND]
GO
/****** Object:  View [dbo].[dashboard_view_Services_Integration_Request]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[dashboard_view_Services_Integration_Request] AS
	select  [idRow],
			[idRichiesta], 
			[integrazione], 
			[operazioneRichiesta], 
			[statoRichiesta], 
			[datoRichiesto],
			[msgError],
			[numRetry],
			[inputWS], 
			[outputWS],
			[isOld],
			[dateIn],
			[DataExecuted],
			[DataFinalizza], 
			[idPfu],
			--[idAzi], 
			--[InOut],
			s.dateIn as DataDA,
			s.datein as DataA,
			'DOCUMENT_INTEGRATION_REQUEST' as OPEN_DOC_NAME
	From Services_Integration_Request s with(nolock)

union all 
	
	select  [idRow],
		    [idRichiesta],
		    'SIMOG' as [integrazione],
		    [operazioneRichiesta], 
			[statoRichiesta], 
			[datoRichiesto],
			[msgError],
			[numRetry],
			[inputWS], 
			[outputWS],
			[isOld],
			[dateIn],
			[DataExecuted],
			[DataFinalizza], 
			[idPfuRup] as idPfu,
			--[idAzi], 
			--[InOut],
			simog.dateIn as DataDA,
			simog.datein as DataA,
			'DOCUMENT_INTEGRATION_SIMOG_REQUEST' as OPEN_DOC_NAME
	from Service_SIMOG_Requests as simog with(nolock)
GO
