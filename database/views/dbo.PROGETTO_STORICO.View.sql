USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROGETTO_STORICO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[PROGETTO_STORICO]
AS
SELECT     TOP 100 PERCENT dbo.Document_Progetti.IdProgetto, Document_Progetti_1.IdProgetto AS LinkModified, 
                      dbo.Document_Progetti.LinkModified AS Expr1, dbo.Document_Progetti.StatoProgetto, dbo.Document_Progetti.PEG, 
                      dbo.Document_Progetti.Protocol, CAST(dbo.Document_Progetti.Oggetto AS nvarchar(200)) AS Sintesi, 
                      dbo.Document_Progetti.Importo, dbo.Document_Progetti.Tipologia, dbo.Document_Progetti.TipoProcedura, 
                      dbo.Document_Progetti.NumLotti,dbo.Document_Progetti.AllegatoDpe, dbo.Document_Progetti.UserDirigente, 
                      dbo.Document_Progetti.DataInvio, dbo.Document_Progetti.Versione, dbo.Document_Progetti.UserProvveditore, 
                      dbo.Document_Progetti.DataDetermina, dbo.Document_Progetti.NumDetermina, dbo.Document_Progetti.ProtocolloBando, 
                      CASE when dbo.Document_Progetti.[User]  in (35774,40687,41316) then dbo.Document_Progetti.ReferenteUffAppalti else null end as ReferenteUffAppalti,dbo.Document_Progetti.Pratica, 'PROGETTO' AS STORICOGrid_OPEN_DOC_NAME, 
                      dbo.Document_Progetti.idProgetto AS STORICOGrid_ID_DOC, dbo.Document_Progetti.DataOperazione, 
                      dbo.Document_Progetti.[User]
FROM         dbo.Document_Progetti INNER JOIN
                      dbo.Document_Progetti AS Document_Progetti_1 ON 
                      dbo.Document_Progetti.LinkModified = Document_Progetti_1.LinkModified
					 
WHERE     (dbo.Document_Progetti.Storico = 1)





GO
