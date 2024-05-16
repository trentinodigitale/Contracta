USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CLASS_ISCRIZ_DOMG_DESC_FROM_VIEW_CLASSE_ISCRIZ]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_CLASS_ISCRIZ_DOMG_DESC_FROM_VIEW_CLASSE_ISCRIZ] as
select  
	
	dgCodiceInterno as ID_FROM
	,LngSuffisso as Lingua
	,'' as descrizione

 FROM DizionarioAttributi
      inner join DominiGerarchici on dgTipoGerarchia=dztIdTid  
	  ,Lingue
	 where lngDeleted=0 and dgDeleted = 0 and dztnome='ClasseIscriz'
GO
