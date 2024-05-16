USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOM_GER_CLASSE_ISCRIZ_FROM_VIEW_CLASSE_ISCRIZ]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DOM_GER_CLASSE_ISCRIZ_FROM_VIEW_CLASSE_ISCRIZ] as
SELECT
	  dgCodiceInterno as ID,
	  dgCodiceInterno as ID_FROM,	
	  dgCodiceInterno as LinkedDoc, 
      dgCodiceInterno,
      dgTipoGerarchia,
	  dgCodiceEsterno,
	  dgPath,
	  dgLivello,
	  dgFoglia,
	  dgLenPathPadre,
	  dgIdDsc
	 
          FROM DizionarioAttributi
             inner join DominiGerarchici on dgTipoGerarchia=dztIdTid  
            
             
         WHERE dgDeleted = 0 and dztnome='ClasseIscriz'

GO
