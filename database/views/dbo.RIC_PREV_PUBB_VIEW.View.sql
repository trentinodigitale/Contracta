USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RIC_PREV_PUBB_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RIC_PREV_PUBB_VIEW]
AS
SELECT     b.ML_Description AS CoperturaGuri_lbl, dbo.LIB_Multilinguismo.ML_Description AS CoperturaBurc_lbl, dbo.Document_RicPrevPubblic.id, 
                      dbo.Document_RicPrevPubblic.StatoRicPrevPubblic, dbo.Document_RicPrevPubblic.PEG, dbo.Document_RicPrevPubblic.Protocol, 
                      dbo.Document_RicPrevPubblic.Oggetto, dbo.Document_RicPrevPubblic.Importo, dbo.Document_RicPrevPubblic.FAX, 
                      dbo.Document_RicPrevPubblic.NumQuotReg, dbo.Document_RicPrevPubblic.NumQuotNaz, dbo.Document_RicPrevPubblic.NumCaratteri, 
                      dbo.Document_RicPrevPubblic.RigoLungo, dbo.Document_RicPrevPubblic.NumRighe, dbo.Document_RicPrevPubblic.Allegato, 
                      dbo.Document_RicPrevPubblic.UserDirigente, dbo.Document_RicPrevPubblic.DataInvio, dbo.Document_RicPrevPubblic.Pratica, 
                      dbo.Document_RicPrevPubblic.UserProvveditore, dbo.Document_RicPrevPubblic.DataCompilazione, dbo.Document_RicPrevPubblic.NumRigheBollo, 
                      dbo.Document_RicPrevPubblic.AllegatoBURC, dbo.Document_RicPrevPubblic.AllegatoGURI, dbo.Document_RicPrevPubblic.LinkModified, 
                      dbo.Document_RicPrevPubblic.StatoDataPubb, dbo.Document_RicPrevPubblic.Deleted, dbo.Document_RicPrevPubblic.NumRigheGuri, 
                      dbo.Document_RicPrevPubblic.TipoDocumento, dbo.Document_RicPrevPubblic.Tipologia, dbo.Document_RicPrevPubblic.CostoBurc, 
                      dbo.Document_RicPrevPubblic.BudgetProgettoBurc, dbo.Document_RicPrevPubblic.BudgetPegBurc, dbo.Document_RicPrevPubblic.CoperturaBurc, 
                      dbo.Document_RicPrevPubblic.CostoGuri, dbo.Document_RicPrevPubblic.BudgetProgettoGuri, dbo.Document_RicPrevPubblic.BudgetPegGuri, 
                      dbo.Document_RicPrevPubblic.CoperturaGuri, dbo.Document_RicPrevPubblic.NoteRicPrev, dbo.Document_RicPrevPubblic.Storico, 
                      dbo.Document_RicPrevPubblic.RicPubDPE, dbo.Document_RicPrevPubblic.RicPubECO, dbo.Document_RicPrevPubblic.DataOperazione, 
                      dbo.Document_RicPrevPubblic.[User], dbo.Document_RicPrevPubblic.StatoDataPubbBG, dbo.Document_RicPrevPubblic.LinkDocRdBE
FROM         dbo.Document_RicPrevPubblic LEFT OUTER JOIN
                      dbo.LIB_DomainValues ON dbo.Document_RicPrevPubblic.CoperturaBurc = dbo.LIB_DomainValues.DMV_Cod AND 
                      dbo.LIB_DomainValues.DMV_DM_ID = 'Copertura' LEFT OUTER JOIN
                      dbo.LIB_Multilinguismo ON dbo.LIB_DomainValues.DMV_DescML = dbo.LIB_Multilinguismo.ML_KEY AND 
                      dbo.LIB_Multilinguismo.ML_LNG = 'I' LEFT OUTER JOIN
                      dbo.LIB_DomainValues AS a ON dbo.Document_RicPrevPubblic.CoperturaGuri = a.DMV_Cod AND a.DMV_DM_ID = 'Copertura' LEFT OUTER JOIN
                      dbo.LIB_Multilinguismo AS b ON a.DMV_DescML = b.ML_KEY AND b.ML_LNG = 'I'

GO
