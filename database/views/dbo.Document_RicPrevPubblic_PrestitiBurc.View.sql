USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_RicPrevPubblic_PrestitiBurc]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_RicPrevPubblic_PrestitiBurc]
AS
SELECT     IdRow, idHeader, Peg AS PegBurc, Quota AS QuotaBurc, BurcGuri AS BurcGuri_Burc
FROM         dbo.Document_RicPrevPubblic_Prestiti

GO
