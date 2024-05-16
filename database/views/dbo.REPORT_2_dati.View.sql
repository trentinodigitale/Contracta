USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_2_dati]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[REPORT_2_dati] as 
select 
	Periodo ,
	isnull( REL_ValueOutput , TipoProcedura ) as TipoProcedura ,
	Tipologia , 
	case when REL_Type is null then 'Tradizionali' else 'Telematiche' end as TipoGara,
	Importo , N_Bandi
from REPORT_2_dati_base 
	left outer join CTL_Relations on REL_Type = 'GARE_TELEMATICHE' and TipoProcedura = REL_ValueInput



GO
