USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_COM_DPE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_COM_DPE]
AS

	SELECT IdCom                                    AS IdDoc
		 , lngSuffisso                              AS LNG
		 , Protocollo                               AS Protocollo
		 , convert( varchar(10) , DataCreazione   , 103 )	AS Data
		 , convert( varchar(10) , DataScadenzaCom , 103 )   AS DataScadenza
		 , Aziragionesociale
		 , pfuNome
		 , Name as Titolo
		 , NotaCom as TestoComunicazione
	  FROM Document_Com_DPE WITH(NOLOCK) 
		CROSS JOIN  Lingue WITH(NOLOCK) 
		INNER JOIN ProfiliUtente WITH(NOLOCK)  ON idpfu = Owner 
		INNER JOIN AZIENDE WITH(NOLOCK) ON PFUIDAZI = IDAZI

     


GO
