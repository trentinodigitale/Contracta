USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI]
AS
	select 
		
		M.IdComFor, M.Name, M.Fascicolo, M.bRead, pu.idpfu as owner, M.DataCreazione, M.Protocollo, M.OPEN_DOC_NAME, M.StatoGD, M.OpenDettaglio
		, RichiestaRisposta	 , Scrittura , EnteAppaltante, AZI_Ente

	 from
		 profiliutente pu with (nolock)
		, Document_Aziende_RTI  RTI with (nolock)
		, profiliutente pu2  with (nolock)
		, DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_SUB M

	where 
		pu.pfuidazi = RTI.idAziPartecipante  
		and pu2.pfuidazi = RTI.idAziRTI
		and ( M.owner = pu2.idpfu or owner = pu.idpfu )

UNION

	select 
		
		M.IdComFor, M.Name, M.Fascicolo, M.bRead, M.owner, M.DataCreazione, M.Protocollo, M.OPEN_DOC_NAME, M.StatoGD, M.OpenDettaglio
		, RichiestaRisposta	 , Scrittura  , EnteAppaltante, AZI_Ente

	 from
		 DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_SUB M


GO
