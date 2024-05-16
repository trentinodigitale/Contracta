USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_Dettaglio_Utenti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_VIEW_Dettaglio_Utenti] 
AS
SELECT p.IdPfu     
     ,p.IdPfu as ID
     , pfuIdAzi
     , case isnull(pfuTitolo,'') 
			when '' then pfunomeutente + ' ' + pfuCognome   else pfuTitolo + ' ' + pfuNomeUtente + ' ' + pfuCognome 
	   end  As cognomeutente
--     , pfuruoloaziendale                        AS ruoloutente
     , pfutel                                   AS telefonoutente
     , pfucell                                  AS cellulareutente
     , pfue_mail                                AS emailutente
     , pfufunzionalita
     , pfuprofili + '###' + pfufunzionalita     AS funzionalitautente
     --, pfuprofili
     ,'USER_DOC' as OPEN_DOC_NAME
	 , pfuvenditore
	 
	, dbo.GetRuoliUser( p.idpfu ) as RuoloUtente
	, dbo.GetProfiliUser( p.idpfu ) as pfuprofili
    , pfuRuoloAziendale
    , pfuLogin
    , case when a.idpfu is not null then 1 else null end as IsRapLeg
 	 
  FROM ProfiliUtente p 
	left outer join profiliutenteattrib a on a.dztnome = 'Profilo' and a.attvalue in ( 'RapLegEnte' , 'RapLegOE' ) and p.idpfu = a.idpfu
 WHERE p.IdPfu NOT IN (-10, 35793)
   AND pfuDeleted = 0


GO
