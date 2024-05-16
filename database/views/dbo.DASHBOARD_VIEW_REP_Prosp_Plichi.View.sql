USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Prosp_Plichi]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[DASHBOARD_VIEW_REP_Prosp_Plichi] AS
SELECT     
	RIGHT(l.ProtocolloBando, 4) AS Anno ,
	left(l.DataAperturaOfferte, 4) AS AnnoPrimaSeduta ,
	ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA, --> PDA
	l.ProtocolloBando, 
	l.Oggetto, 
	NumPartecipanti
	,NumEscluse
FROM         dbo.DASHBOARD_VIEW_BANDILAVORI AS l 
					INNER JOIN dbo.MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' AND mfBando.mfIdMsg = l.IdMsg 
					LEFT OUTER JOIN dbo.MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' AND mf.mfFieldValue = mfBando.mfFieldValue AND mf.mfIsubType = 169 
					left outer join ( select IdPdA , 
											count( * ) as NumPartecipanti , 
											sum( case StatoPDA when '1' then 1 else 0 end ) as  NumEscluse 
											from Document_PDA_Aziende 
											group by IdPdA ) as a  on mf.mfIdMsg =  IdPdA
WHERE  RIGHT(l.ProtocolloBando, 4) NOT IN ('2007', '7/07')

GO
