USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_DOSSIER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--Creata vista COM_DPE_DOSSIER per visualizzazione nel dossier
---------------------------------------------------------------

CREATE VIEW [dbo].[COM_DPE_DOSSIER]
AS
--Versione=2&data=2012-10-24&Attvita=40258&Nominativo=Sabato
--Versione=1&data=2012-05-23&Attvita=38328&Nominativo=Carla
SELECT      IdCom, IdCom AS ID
           , document_com_dpe.Owner AS Doc_Owner
           , document_com_dpe.Name 
          , document_com_dpe.DataCreazione AS data
          , document_com_dpe.DataCreazione AS ReceivedDataMsg
          , a.idAZI AS AZI
          , document_com_dpe.Protocollo AS NumOrdCliente
          , document_com_dpe.Protocollo AS ProtocolloOfferta
          , a.aziRagioneSociale AS ragsoc
          , 1 AS IDMP
          , document_com_dpe.Protocollo AS Protocol
          
FROM       document_com_dpe INNER JOIN
              profiliutente  ON owner = idpfu INNER JOIN 
              Aziende AS a ON  pfuidazi = a.IdAzi
GO
