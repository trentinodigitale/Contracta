USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FAX_RIC_PUBB]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FAX_RIC_PUBB]
AS
SELECT     'I' AS LNG, id as iddoc,* from Document_RicPubblic

GO
