USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DATI_NUOVO_REFERENTE_CONVENZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DATI_NUOVO_REFERENTE_CONVENZIONE] as
select 
	 ISNULL(AR.idAziPartecipante,a.idazi) as id,
	 'I' as Lingua,
	 ISNULL(AR.idAziPartecipante,a.idazi) as Azi_Dest,
	 isnull(P.idpfu,'') as ReferenteFornitore,
	 isnull(p1.pfucodicefiscale,'') as CodiceFiscaleReferente,
	 isnull(P.idpfu,'') as ReferenteFornitoreHide

from aziende a
	 left outer join Document_Aziende_RTI AR on  AR.idAziRTI=a.idazi and AR.isOld=0 and AR.Ruolo_Impresa='Mandataria'
	 left outer join profiliUtente p on p.pfuidazi=ISNULL(AR.idAziPartecipante,a.idazi) and p.pfudeleted=0
	 --left outer join ProfiliUtenteAttrib PA on PA.dztNome='Profilo' and PA.attValue='RapLegOE' and PA.idpfu=p.idpfu
	 left outer join profiliUtente p1 on p1.idpfu= P.idpfu	 
where a.azideleted=0


GO
