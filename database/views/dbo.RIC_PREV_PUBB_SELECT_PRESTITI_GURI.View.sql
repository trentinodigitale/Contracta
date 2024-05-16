USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RIC_PREV_PUBB_SELECT_PRESTITI_GURI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RIC_PREV_PUBB_SELECT_PRESTITI_GURI]
AS
SELECT     DISTINCT doc.id, b.IdPfu, a.BDM_BDG_Periodo AS Periodo, a.RDA_ResidualBudget - ISNULL(pre.Quota, 0) AS RDA_ResidualBudget, a.Peg, a.idKey
FROM         (SELECT     BDM_BDG_Periodo, SUM(BDM_Importo) AS RDA_ResidualBudget, BDM_KeyPlant + '#~#' + BDM_KeyCDC AS Peg, 
                                              BDM_KeyCDC AS idKey
                       FROM          dbo.Budget_Movement
                       WHERE      (BDM_BDG_Periodo IN
                                                  (SELECT     BDG_Periodo
                                                    FROM          dbo.Budget_Anag
                                                    WHERE      (BDG_Stato = 'esercizio'))) AND (BDM_isOld = 0) AND (BDM_KeyVDS = '1326')
                       GROUP BY BDM_BDG_Periodo, BDM_KeyPlant, BDM_KeyCDC) AS a INNER JOIN
                          (SELECT     dbo.ProfiliUtenteAttrib.IdPfu, dbo.CTL_Relations.REL_ValueOutput
                            FROM          dbo.CTL_Relations INNER JOIN
                                                   dbo.ProfiliUtenteAttrib ON dbo.CTL_Relations.REL_ValueInput = dbo.ProfiliUtenteAttrib.attValue
                            WHERE      (dbo.CTL_Relations.REL_Type = 'UserRole_2_PlantCDC') AND (dbo.ProfiliUtenteAttrib.dztNome = 'UserRole')) AS b ON 
                      a.Peg = b.REL_ValueOutput CROSS JOIN
                      dbo.Document_RicPrevPubblic AS doc LEFT OUTER JOIN
                      dbo.Document_RicPrevPubblic_Prestiti AS pre ON doc.id = pre.idHeader AND a.Peg = pre.Peg AND pre.BurcGuri = 'BURC'
WHERE     (a.RDA_ResidualBudget > 0)


GO
