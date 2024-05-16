USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ws_getUsers_view]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ws_getUsers_view] as 
        SELECT    utente.IdPfu as id,
				          utente.pfuLogin as username,
				          isnull(utente.pfuE_Mail,'') as email , 
				          isnull(utente.pfuNome,'') as NomeRapLeg, 
				          utente.pfuProfili as Profilo, 
				          utente.pfuRuoloAziendale as ruolo,
				          azienda.aziRagioneSociale as RagioneSociale
        				
        FROM         ProfiliUtente AS utente INNER JOIN
                              Aziende AS azienda ON utente.pfuIdAzi = azienda.IdAzi 
                              
        WHERE     (utente.IdPfu > 0) AND (utente.pfuDeleted != 1) AND (ISNULL(utente.pfuE_Mail, N'') != '')
GO
