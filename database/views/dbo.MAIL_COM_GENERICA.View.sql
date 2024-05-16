USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_COM_GENERICA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[MAIL_COM_GENERICA]
AS
SELECT 'I' AS LNG
     , Document_Comunicazione.id AS idDoc
     , Document_Comunicazione.DataCreazione
     , Document_Comunicazione.ID_MSG_Tabulato
     , Document_Comunicazione.ID_MSG_BANDO
     , Document_Comunicazione.StatoEsclusione
     , Document_Comunicazione.Oggetto
     , Document_Comunicazione.Segretario
     , Document_Comunicazione.Protocol
     , Document_Comunicazione.ProtocolloGenerale
     , convert ( varchar(10),getdate(),103) as DataInvio
	 , 'COM_GENERICA' as TipoDocumento
  FROM   dbo.Document_Comunicazione
GO
