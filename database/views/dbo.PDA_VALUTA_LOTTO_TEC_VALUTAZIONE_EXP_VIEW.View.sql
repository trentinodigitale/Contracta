USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_EXP_VIEW]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_EXP_VIEW] as 

	select * from 
	(
		select idheader, value, dzt_name , row
		from PDA_VALUTA_LOTTO_TEC_VALUTAZIONE_EXP_VIEW_SUB  p with(nolock)
		where dse_id = 'PDA_VALUTA_LOTTO_TEC' 
        
	) as P
		pivot
		(
			min( value   )
			for p.dzt_name in (
							
								DescrizioneCriterio,
								CriterioValutazione,
								PunteggioMax,
								Descrizione,
								AttributoCriterio,
								--GiudizioTecnico, -- coefficiente
								PunteggioTecnicoAssegnato , 
								--Formula,
								Note,
								PunteggioTecnico , -- --Value, Punteggio Tecnico
								GiudizioRiparametrato,
								PunteggioRiparametrato		
								)
		
		) as PIV


GO
