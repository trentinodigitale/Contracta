USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_EXP_VIEW_SUB]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_EXP_VIEW_SUB] as 

	select  v.IdRow, v.IdHeader, v.DSE_ID, v.Row, 
			case 

					when v.DZT_Name = 'Value' then 'PunteggioTecnico' 
					when v.DZT_Name = 'GiudizioTecnico' then 'PunteggioTecnicoAssegnato' 
					else DZT_Name 

				end as DZT_Name 

			, v.Value 
			
		from PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_VIEW as v
	


GO
