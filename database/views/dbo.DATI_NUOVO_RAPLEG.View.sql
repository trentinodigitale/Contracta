USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DATI_NUOVO_RAPLEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DATI_NUOVO_RAPLEG] as
select 
	 idpfu as id,
	 'I' as Lingua,
	pfunomeutente  as NomeRapLeg,
	pfucognome as CognomeRapLeg,
	pfuCodiceFiscale as CFRapLeg,
	pfuTel as TelefonoRapLeg,
	pfuCell as CellulareRapLeg,
	pfuE_Mail as EmailRapLeg

from ProfiliUtente
where pfudeleted=0
GO
