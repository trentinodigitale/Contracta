USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CAMBIO_UTENTE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CAMBIO_UTENTE_VIEW] as

select *
      
from 
   CTL_DOC

   where tipodoc='CAMBIO_UTENTE'
   
GO
