USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DATI_NUOVO_REFERENTE_FORNITORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DATI_NUOVO_REFERENTE_FORNITORE] as
select 
	 idpfu as id,
	 'I' as Lingua,	 
	 p.pfucodicefiscale as CodiceFiscaleReferente,
	 P.idpfu as ReferenteFornitoreHide

from profiliUtente p 	 
	where p.pfudeleted=0

GO
