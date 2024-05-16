USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_CODIFICA_PRODOTTI_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[RICHIESTA_CODIFICA_PRODOTTI_LISTA_DOCUMENTI] as
select c.* 
	, tipodoc as OPEN_DOC_NAME
	, isnull( az1.aziRagionesociale, az2.aziRagioneSociale) as aziRagioneSociale

	from ctl_doc c
	
		left outer join  aziende az1 on azienda = az1.idazi
		left outer join  aziende az2 on Destinatario_Azi = az2.idazi

	where deleted = 0
	and tipoDoc='CODIFICA_PRODOTTI' --and Statodoc <> 'Saved'
	

GO
