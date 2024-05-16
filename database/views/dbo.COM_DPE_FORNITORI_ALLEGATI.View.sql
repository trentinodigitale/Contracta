USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_FORNITORI_ALLEGATI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[COM_DPE_FORNITORI_ALLEGATI]
AS
SELECT IDComAll
     , IdComFor
     , A.Allegato
  FROM Document_Com_DPE_ALLEGATI A with(nolock)
	inner join Document_Com_DPE_Fornitori F with(nolock) on A.IdCom=F.IdCom
GO
