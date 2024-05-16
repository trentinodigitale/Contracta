USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_PROFILI_FROM_UTENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[USER_DOC_PROFILI_FROM_UTENTI] as
select 
    
    a.attValue as profilo
    ,a.idpfu  AS ID_FROM
	,case when  a.attValue like 'RapLeg%' then ' profilo ' else '' end as NotEditable
    ,a.dataultimamod   
    from profiliutenteattrib a with(nolock)
		inner join ProfiliUtente P with(nolock) on P.IdPfu=a.IdPfu
		inner join Aziende Azi with(nolock) on P.pfuIdAzi=Azi.idazi
		inner join Profili_Funzionalita PF with(nolock) on PF.Codice=a.attValue and Azi.aziProfili like '%' + PF.aziProfilo + '%'
     where a.dztnome='Profilo' 
GO
