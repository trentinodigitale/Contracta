USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_RTI_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[AZI_UPD_RTI_FROM_AZIENDA]
AS
SELECT     a.aziRagioneSociale,
			a.aziPartitaIVA, 
            a.IdAzi, 
            a.IdAzi AS ID_FROM,
			s.idAziPartecipante as idAziPartecipanteHide ,
            isnull( DM_Attributi_0.vatValore_FT , '' )AS ProtocolloBando,

			s.*


FROM         dbo.Aziende as a 
			left outer join  dbo.Document_Aziende_RTI   as s  on  a.idAzi = s.idAziRTI and isOld = 0
			LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_0 ON a.IdAzi = DM_Attributi_0.lnk AND DM_Attributi_0.idApp = 1 AND 
                      DM_Attributi_0.dztNome = 'ProtocolloBando'

GO
