USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Aziende]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[View_Aziende]
as
select aziragionesociale as ragsoc from aziende,profiliutente where pfuidazi = idazi


GO
