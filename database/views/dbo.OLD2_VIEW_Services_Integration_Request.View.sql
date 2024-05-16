USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_Services_Integration_Request]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_Services_Integration_Request] AS
	select  [idRow] as id, 
			integrazione,
			operazioneRichiesta,
		    dbo.PARAMETRI( 'SERVICE_REQUEST', integrazione, operazioneRichiesta, 'NO_PARAM/endpoint.aspx', -1) as END_POINT
		from Services_Integration_Request with(nolock)
GO
