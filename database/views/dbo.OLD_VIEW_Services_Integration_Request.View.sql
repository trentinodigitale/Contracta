USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_Services_Integration_Request]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VIEW_Services_Integration_Request] AS
	select  [idRow] as id, 
			integrazione,
			operazioneRichiesta,

			-- l'endpoint da invocare. in presenza di parametri aggiuntivi li troveremo in forma query string 'P1=VAL&P2=VAL' separati da # rispetto all'endpoint. es : DIR/pag.aspx#param1=x
			dbo.GetPos( dbo.PARAMETRI( 'SERVICE_REQUEST', integrazione, operazioneRichiesta, 'NO_PARAM/endpoint.aspx', -1) ,'#',1) as END_POINT

		from Services_Integration_Request with(nolock)
GO
