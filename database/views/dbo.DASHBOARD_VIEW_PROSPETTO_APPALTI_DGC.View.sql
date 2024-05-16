USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROSPETTO_APPALTI_DGC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PROSPETTO_APPALTI_DGC]
AS
SELECT SUBSTRING(ProtocolloBando, 1, 3) AS NumeroBando
     , SUBSTRING(ProtocolloBando, 5, 4) AS AnnoBando
     , a.IdRow
     , a.IdProgetto
     , a.Lotto
     , a.ScadenzaIstanza
     , a.ScadenzaOfferta
     , CASE WHEN CAST(ISNULL(a.Importo, 0) AS VARCHAR) = '0' OR b.NumLotti IN (0, 1) 
                 THEN '-' 
            ELSE STR(a.Importo, 9, 2) 
       END AS Importo
     , b.IdProgetto AS Expr1
     , b.StatoProgetto
     , b.DataInvio
     , b.Protocol
     , b.UserDirigente
     , b.Peg
     , b.Importo AS ImportoProcedura
     , b.Tipologia
     , b.TipoProcedura
     , b.CriterioAggiudicazione
     , b.NumLotti
     , b.Oggetto
     , b.Versione
     , b.NumDetermina
     , b.DataDetermina
     , b.ProtocolloBando
     , b.ReferenteUffAppalti
     , b.UserProvveditore
     , b.AllegatoDpe
     , b.NoteProgetto
     , b.DataCompilazione
     , b.Storico
     , b.DataOperazione
     , b.[User]
     , b.Deleted
     , b.LinkModified
     , b.Pratica
     , SUBSTRING(Programma, 6, LEN(Programma)) AS Programma
     , a.notelotto
     , a.dataconsegnaverbale
     , a.rettifica
     , a.annullamento
     , a.ricorso
     , a.Deserta_MaiIndetta
     , a.DataTrasmContratto
     , a.DataAvvioIstr
     , a.DurataIstruttoria
     , a.NoteAggiudicazione
     , b.NumDeterminaAggiudica
     , b.DataDeterminaAggiudica
     , dbo.GetDittaAggiudicataria(a.IdRow, a.annullamento, a.Deserta_MaiIndetta) AS DittaAggiudicataria
     , isnull(pfunome,b.ReferenteUffAppalti) as  Descrizione
  FROM Document_Progetti_Lotti  a 
	INNER JOIN Document_Progetti  b ON a.IdProgetto = b.IdProgetto
	inner join Peg on ProPro = SUBSTRING(Peg, CHARINDEX('#~#', Peg) + 3, 10)
	left outer join profiliutente on b.ReferenteUffAppalti = cast(idpfu as varchar)
 WHERE 
   Tipologia = '2'

GO
