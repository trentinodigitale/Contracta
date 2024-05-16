USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AZI_UPD_RAPLEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_AZI_UPD_RAPLEG]
AS
SELECT 
     pfuNome ,
     document_Aziende.aziRagioneSociale,
     convert(varchar(20),document_Aziende.aziDataCreazione,106) as data,
	'I' as lng   ,
	id as iddoc
FROM  
  document_Aziende,
  profiliutente
where idazi=pfuidazi and TipoOperAnag='AZI_UPD_RAPLEG'
GO
