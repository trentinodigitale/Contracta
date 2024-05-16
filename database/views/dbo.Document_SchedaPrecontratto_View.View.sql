USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SchedaPrecontratto_View]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Document_SchedaPrecontratto_View]
AS
SELECT s.Id
     , s.DataCreazione
     , s.ID_MSG_PDA
     , s.ID_MSG_BANDO
     , s.Stato
     , s.ProtocolloBando
     , s.PubblicazioneEsito
     , s.idAggiudicatrice
     , s.deleted
     , s.Oggetto
     , c.NRDeterminazione
     , c.DataDetermina
     , c.ProtocolloGenerale 
     , c.DataProt 
     , c.ResponsabileContratto
     , c.ImportoAggiudicato + c.OneriSic + c.OneriSicE + c.OneriSicI 
       + c.OneriDis + c.LavoriEconomia                                       AS ValoreContratto
     , e.ProtocolloGenerale                                                  AS ProtocolloGeneraleEsito 
     , e.DataProt                                                            AS DataProtEsito
     , DATEADD(day, 30, c.DataProt)                                          AS ScadenzaDocumentazione
     , DATEADD(day, 60, c.DataProt)                                          AS ScadenzaStipula
     , c.id                                                                  AS id_Com_Aggiudicataria 
     , e.id                                                                  AS id_EsitoGara 
     , CASE WHEN a.aziIdDscFormaSoc IN ('836418', '845321', '845323', '845322', '845320', '845326') THEN 1 
            ELSE 0 
       END                                                                   AS isAti
     , a.IdAzi                                                               AS IdAzi 
     , a.IdAzi                                                               AS  aziTs 
     , a.IdAzi                                                               AS  Fornitore 
     , CASE WHEN RIGHT(s.ProtocolloBando, 2) = '07' AND s.ProtocolloBando <> '053/2007' THEN 'Archiviato'
            WHEN ISNULL(r.StatoRepertorio, '') = ''                                     THEN 'InCorso'
            ELSE r.StatoRepertorio 
       END                                                                   AS StatoRepertorio
     , s.IstruttoriaControlli
     , s.DataInvioCom
     , s.TipoInvioCom
     , s.DataUltimoInvioCom
     , s.TipoUltimoInvioCom
     , s.ImpugnazioniControEsclusione
     , s.DecorsiTerminiImpugnazione 
     , s.NoteReportComunicazioneEsito
  FROM Document_SchedaPrecontratto s 
  LEFT OUTER JOIN Document_Com_Aggiudicataria c ON s.ID_MSG_PDA = c.ID_MSG_PDA
  LEFT OUTER JOIN Document_EsitoGara e ON s.ID_MSG_PDA = e.ID_MSG_PDA
  INNER JOIN Aziende AS a on a.idazi = s.idAggiudicatrice
  LEFT OUTER JOIN Document_Repertorio r ON r.ProtocolloBando = s.ProtocolloBando
GO
