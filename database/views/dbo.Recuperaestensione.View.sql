USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Recuperaestensione]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Recuperaestensione] as 

  

 
    
select idHeader, substring(Allegato,Position + 1, Position2-Position-1) as estensione  
from 
(select idHeader as idHeader,[Allegato],CHARINDEX ('*',[Allegato]) as Position ,charindex ('*',[ALLEGATO], CHARINDEX ('*',[Allegato])+1)as Position2
from [Document_Richiesta_Atti])

as aa



GO
