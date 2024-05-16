USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_4]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_4] as
select Descrizione , TipoGara, round( N_Bandi ,2 ) as N_Bandi , round( N_Rettifiche  , 2 )as N_Rettifiche , round ( N_Annullamenti ,2 ) as N_Annullamenti  , round( N_Ricorsi ,2 ) as N_Ricorsi , round( N_Deserte , 2 ) as N_Deserte
  from REPORT_4_dati_Periodi

GO
