USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_RicPrevPubblic_PrestitiGuri]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_RicPrevPubblic_PrestitiGuri]
AS
SELECT     IdRow, idHeader, Peg AS PegGuri, Quota AS QuotaGuri, BurcGuri AS BurcGuri_Guri
FROM         dbo.Document_RicPrevPubblic_Prestiti

GO
