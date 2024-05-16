USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_DPE_ALLEGATI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_COM_DPE_ALLEGATI]
AS
SELECT IdComAll
     , b.IdCom
     , Linguaall
     , Allegato
  FROM Document_Com_DPE a
     , Document_Com_DPE_Allegati b
 WHERE a.IdCom = b.IdCom


GO
