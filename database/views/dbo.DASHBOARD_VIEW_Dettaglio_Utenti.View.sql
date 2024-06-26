USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Dettaglio_Utenti]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_Dettaglio_Utenti] 
AS
SELECT p1.IdPfu     
      ,p2.IdPfu as ID
     , p2.pfuIdAzi
     , p2.pfuNome                                  AS cognomeutente
     , p2.pfuruoloaziendale                        AS ruoloutente
     , p2.pfutel                                   AS telefonoutente
     , p2.pfucell                                  AS cellulareutente
     , p2.pfue_mail                                AS emailutente
     , p2.pfufunzionalita
     , p2.pfuprofili + '###' + p2.pfufunzionalita  AS funzionalitautente
     , p2.pfuprofili
     , p2.pfuRuoloAziendale
     , p2.pfuLogin
     , p2.pfuCognome
     , p2.pfunomeutente
	--, dbo.GetRuoliUser( p2.idpfu ) as RuoloUtente
	--, dbo.GetProfiliUser( p2.idpfu ) as pfuprofili
     , 
	CASE ISNULL(p2.pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(p2.pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti
     
  FROM ProfiliUtente p1
      inner join ProfiliUtente p2 on p2.pfuIdAzi=p1.pfuIdAzi
 WHERE p2.IdPfu NOT IN (-10)
   --AND p2.pfuDeleted = 0
GO
