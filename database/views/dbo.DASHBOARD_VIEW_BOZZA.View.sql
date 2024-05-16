USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BOZZA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_BOZZA]
AS
SELECT ID          
     , IdMsg
     , iType
     , iSubType
     , DataIns
     , NumOrd
     , Protocol
     , ProtocolOrdine
     , StatoBozza
     , Plant
     , Name
     , b.IdPfu                  AS IdDestinatario
     , IdAziDest
     , IdAziDest                AS AZI_Dest
     , IdMittente
     , Nota
     , Deleted
     , ODC_PEG
     , Capitolo
     , NumeroConvenzione
     , Id_Convenzione
     , Id_Ordine
     , Id_ODC
     , ImpegnoSpesa
     , NoteComunicazione
  FROM Document_Bozza 
     , ProfiliUtenteAttrib b
 WHERE Deleted = 0
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'
   AND StatoBozza <> 'Saved'
GO
