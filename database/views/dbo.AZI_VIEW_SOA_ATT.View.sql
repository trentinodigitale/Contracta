USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_VIEW_SOA_ATT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[AZI_VIEW_SOA_ATT]
as
select * from dbo.Document_Aziende where isold = 0
GO
