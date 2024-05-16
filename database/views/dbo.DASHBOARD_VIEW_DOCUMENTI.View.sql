USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_DOCUMENTI]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     ,iType as  msgIType
     , iSubType as msgISubType
     ,stato
     ,Name
     ,ProtocolloBando
     ,Stato as StatoGD
     ,ProtocolloOfferta
     ,ReceivedDataMsg
     ,expirydate
     ,ProtocolBG as Fascicolo
     ,Object_Cover1 as Oggetto
     ,ImportoBaseAsta as importo
     ,tipoappalto as Tipo_Appalto
     ,CriterioAggiudicazioneGara as CriterioAggiudicazioneGara
     ,TipoProcedura 
     ,ReceivedQuesiti as NumeroQuesiti
     ,ReceivedOff as NumeroOfferte
     ,NameBG
     ,tb.Data
     ,ProceduraGara as Tipo_Procedura
     ,DataInizioAsta as DataInizio
     ,TipoAsta as Tipologia
     ,ImportoAppalto as ImportoAggiudicato
     ,AuctionState 
     ,CriterioFormulazioneOfferte as CriterioFormulazioneOfferta2 
     ,RAGSOC as aziRagioneSociale
     ,ReceivedDomanda as NumeroDomande
     ,FaseGara
     ,CIG
     ,DataAperturaOfferte
     ,DataAperturaDomande
     ,DataIISeduta
     ,DataSedutaGara
     ,TermineRichiestaQuesiti
     ,[Read] as Bread
 

                                                                      
  FROM 
tab_utenti_messaggi
inner join TAB_MESSAGGI_FIELDS as tb on umIdMsg=IdMsg

WHERE 

  umInput = 0
  AND umstato=0
GO
