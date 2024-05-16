USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Festivita]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[View_Festivita] as 
select left( convert(varchar , Data , 121 ) , 10 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 0
union
select cast( year(getdate()) - 4 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) - 3 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) - 2 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) - 1 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate())     as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) + 1 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) + 2 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) + 3 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1
union
select cast( year(getdate()) + 4 as varchar ) + substring( convert(varchar , Data , 121 ),5 , 6 ) as data , Descrizione , color as Stile from dbo.Document_Festivita where deleted = 0 and ricorrente = 1

GO
