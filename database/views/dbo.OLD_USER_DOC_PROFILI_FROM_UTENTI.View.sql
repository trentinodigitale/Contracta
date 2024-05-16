USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_USER_DOC_PROFILI_FROM_UTENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_USER_DOC_PROFILI_FROM_UTENTI] as
select 
    
    a.attValue as profilo
    ,a.idpfu  AS ID_FROM
	,case when  a.attValue like 'RapLeg%' then ' profilo ' else '' end as NotEditable
    ,a.dataultimamod   
    from profiliutenteattrib a
     where a.dztnome='Profilo'
GO
