USE [AFLink_TND]
GO
/****** Object:  View [dbo].[HD_MESSAGE_FROM_RICHIESTA_HD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HD_MESSAGE_FROM_RICHIESTA_HD]
AS
SELECT   distinct  l.id as ID_FROM,
     
	id as LinkedDoc                      
FROM         dbo.ctl_DOC as l


GO
