USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_PROFILI_FROM_COMMISSIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[USER_DOC_PROFILI_FROM_COMMISSIONE]
 as
select 
   
    idpfu  AS ID_FROM
	,'membrocommissione' as Profilo
from profiliutente


GO
