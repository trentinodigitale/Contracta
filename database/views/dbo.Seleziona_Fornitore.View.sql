USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Seleziona_Fornitore]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Seleziona_Fornitore]
as
select distinct 
  dbo.Aziende.idazi as indrow ,
   dbo.Aziende.idazi AS idAziPartecipante,  
   dbo.Aziende.aziRagioneSociale 
  
from aziende
where azivenditore > 0   
    and aziacquirente = 0
    and azideleted=0
GO
