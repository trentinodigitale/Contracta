USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_COM_DPE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_MAIL_COM_DPE]
AS

SELECT IdCom                                    AS IdDoc
     , lngSuffisso                              AS LNG
     , Protocollo                               AS Protocollo
     , DataCreazione                            AS Data
     , DataScadenzaCom                          AS DataScadenza
     , (Select pfuNome from ProfiliUtente where idpfu=[Owner])									AS Aziragionesociale
  FROM Document_Com_DPE
     , Lingue
     



GO
