USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UTENTI_AZI_ENTE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[UTENTI_AZI_ENTE] 
AS

SELECT IdPfu
     , pfuIdAzi
     , pfuNome                                  AS cognomeutente
     , pfuruoloaziendale                        AS ruoloutente
     , pfutel                                   AS telefonoutente
     , pfucell                                  AS cellulareutente
     , pfue_mail                                AS emailutente
     , pfufunzionalita
     , pfuprofili + '###' + pfufunzionalita     AS funzionalitautente
     , pfuprofili
  FROM ProfiliUtente
 WHERE IdPfu NOT IN (-10, 35793)
   AND pfuDeleted = 0
   
GO
