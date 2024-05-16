USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_SEDUTA_VIRTUALE_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[PARAMETRI_SEDUTA_VIRTUALE_FROM_USER]
as

select 
	u.idpfu as ID_FROM
      ,[Visualizza_Comunicazione]
      ,[Singolo_Lotto]
      ,[Lista_Lotti]
      ,[Visibilita_Lotti]
      ,[Visualizza_Dati_Amministrativi]
      ,[Chiusura]
      ,[Apertura]
      ,[Visibilita]
from profiliutente u
inner join [Document_Parametri_Sedute_Virtuali] p on p.deleted = 0
left outer join CTL_DOC d on d.tipodoc = 'PARAMETRI_SEDUTA_VIRTUALE' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 




GO
