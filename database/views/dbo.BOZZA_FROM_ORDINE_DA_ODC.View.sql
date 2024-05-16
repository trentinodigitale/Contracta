USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BOZZA_FROM_ORDINE_DA_ODC]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[BOZZA_FROM_ORDINE_DA_ODC] 
AS 
SELECT ID                                         AS ID_FROM
     , ID                                         AS Id_Ordine
     , IdMsg                                      AS Id_ODC
     , IdMittente                                 AS IdDestinatario	
     , IdDestinatario                             AS IdMittente 
     , IdAziDest
     , Id_Convenzione
     , NumeroConvenzione
     , ODC_PEG
     , Capitolo
     , Plant
     , NumOrd
     , ''                                         AS Name
     , ImpegnoSpesa
     , Protocol                                   AS ProtocolOrdine
  FROM Document_Ordine



GO
