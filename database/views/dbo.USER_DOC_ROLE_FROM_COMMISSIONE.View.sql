USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_ROLE_FROM_COMMISSIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--[OK] creare un nuovo utente dal viewer Profili Utenti
---------------------------------------------------------------

CREATE view [dbo].[USER_DOC_ROLE_FROM_COMMISSIONE]
 as
select 
    'membrocommissione' as UserRole
    ,'1' as Obbligatorio
    ,idpfu  AS ID_FROM
from 
	profiliutente


GO
