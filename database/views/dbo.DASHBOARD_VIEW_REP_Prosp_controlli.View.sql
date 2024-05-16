USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Prosp_controlli]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[DASHBOARD_VIEW_REP_Prosp_controlli] AS
SELECT     
	RIGHT(l.ProtocolloBando, 4) AS Anno ,
	left(l.DataAperturaOfferte, 4) AS AnnoPrimaSeduta ,
	ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA, --> PDA
	l.ProtocolloBando, 
	l.Oggetto, 
	l.DataAperturaOfferte ,
	l.DataIISeduta ,
	cg.idAggiudicatrice AS Fornitore,
	aziRagioneSociale ,
	cg.id as idDocControlli ,
	dbo.GetDitteControllate(cg.id , '4') as Sorteggiata ,  --> CONTROLLI_GARA
	dbo.GetEsecAmministrativo(cg.id , '4') as EsecSorteggiata ,
	dbo.GetDitteControllate(cg.id , '6') as IIclassificata , --> CONTROLLI_GARA
	dbo.GetEsecAmministrativo(cg.id , '6') as EsecIIclassificata ,
	dbo.GetDitteControllate(cg.id , '5') as Aggiudicataria , --> CONTROLLI_GARA
	dbo.GetEsecAmministrativo(cg.id , '5') as EsecAggiudicataria ,
	NumControlli 
FROM         dbo.DASHBOARD_VIEW_BANDILAVORI AS l 
					INNER JOIN dbo.MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' AND mfBando.mfIdMsg = l.IdMsg 
					LEFT OUTER JOIN dbo.MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' AND mf.mfFieldValue = mfBando.mfFieldValue AND mf.mfIsubType = 169 
					LEFT OUTER JOIN dbo.Document_ControlliGara AS cg ON mf.mfIdMsg =  cg.ID_MSG_PDA
					LEFT OUTER JOIN ( select count( * ) NumControlli , idHeader  from Document_ControlliGara_Fornitori where isATI = 0 group by idHeader ) as cgf on cgf.idHeader = cg.id
					LEFT OUTER JOIN Aziende on idazi = cg.idAggiudicatrice
WHERE  RIGHT(l.ProtocolloBando, 4) NOT IN ('2007', '7/07')

GO
