USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ORDINE_DA_CONVENZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_ORDINE_DA_CONVENZIONE] 
AS
SELECT o.* 
     , o.TotalIva - o.Total  AS ValoreIva 
     , p.idpfu 
	 , SIGN_ATTACH
  FROM Document_Ordine o
INNER JOIN ProfiliUtente p ON IdAziDest = pfuidazi
inner join document_odc on rda_id = o.idmsg
where ISNULL( deleted ,0 ) = 0
GO
