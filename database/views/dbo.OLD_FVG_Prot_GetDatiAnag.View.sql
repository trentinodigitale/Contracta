USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_FVG_Prot_GetDatiAnag]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--strRagSoc,  string strPIVA, string strlocalitaBS, string strStato,string strCAP,string strIndirizzo,
--string strProvincia, string strEmail,string strNome, string strCognome,string strTitolo
CREATE view [dbo].[OLD_FVG_Prot_GetDatiAnag]
as
	select 
		az.IdAzi,
		aziRagioneSociale ,
		case when substring(azipartitaiva,1,2)='IT' then substring(azipartitaiva,3,50) else azipartitaiva end as aziPartitaIVA ,
		isnull(aziLocalitaLeg,'') as aziLocalitaLeg ,
		isnull(aziStatoLeg,'') as aziStatoLeg ,
		isnull(aziCAPLeg,'') as aziCAPLeg ,
		isnull(aziIndirizzoLeg,'') as aziIndirizzoLeg , 
		isnull(aziProvinciaLeg,'') as aziProvinciaLeg ,
		isnull(aziE_Mail,'') as aziE_Mail ,
		isnull(g1.SiglaAuto,'') as ProvinciaSigla,
		isnull(p2.pfunomeutente,'') as nome  ,
		isnull(p2.pfuCognome,'') as cognome  ,
		isnull(p2.pfuTitolo ,'') as titolo

			from aziende az with(nolock)
				LEFT JOIN GEO_ISTAT_elenco_comuni_italiani g1 with(nolock) on g1.CodiceIstatDelComune_formato_alfanumerico = dbo.GetPos( az.aziLocalitaLeg2,'-',8)
				inner join (
								select pfuidazi as idazi, MIN(idpfu) as idpfu
									from ProfiliUtente with(nolock)
										where pfuDeleted = 0
											group by pfuidazi									
							) p on p.idazi=az.idazi
				inner join ProfiliUtente p2 with(nolock) on p.idpfu = p2.IdPfu 

					where aziDeleted = 0

GO
