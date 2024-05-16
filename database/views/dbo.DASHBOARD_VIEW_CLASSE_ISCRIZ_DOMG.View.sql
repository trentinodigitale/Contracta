USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CLASSE_ISCRIZ_DOMG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_CLASSE_ISCRIZ_DOMG] as
SELECT
	  dgCodiceInterno as ID,	 
      dgCodiceInterno,
      dgTipoGerarchia,
	  dgCodiceEsterno,
	  dgPath,
	  dgLivello,
	  dgFoglia,
	  dgLenPathPadre,
	  dgIdDsc,
	  ISNULL(I.dscTesto,'')  as dscTestoI,
	  ISNULL(E.dscTesto,'')  as dscTestoE,
	  ISNULL(FRA.dscTesto,'')  as dscTestoFRA,
	  ISNULL(UK.dscTesto,'')  as dscTestoUK
          FROM DizionarioAttributi
             inner join DominiGerarchici on dgTipoGerarchia=dztIdTid  
             left join  DescsI as I on dgIdDsc=I.IdDsc
             left join  DescsE as E on dgIdDsc=E.IdDsc
             left join  DescsFRA as FRA on dgIdDsc=FRA.IdDsc
             left join  DescsUK as UK on dgIdDsc=UK.IdDsc
             
         WHERE dgDeleted = 0 and dztnome='ClasseIscriz'
GO
