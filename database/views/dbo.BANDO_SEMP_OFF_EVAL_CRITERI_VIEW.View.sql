USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_SEMP_OFF_EVAL_CRITERI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[BANDO_SEMP_OFF_EVAL_CRITERI_VIEW] as

	select C.*  
		, AttributoCriterio as CampoTesto_1 
		, case 
				when isnull(FaseConcorso,'') = 'prima' then ' DescrizioneCriterio PunteggioMax '
				when CriterioValutazione = 'ereditato' then ' CriterioValutazione DescrizioneCriterio PunteggioMax Formula AttributoCriterio '
				else '' 
		  end as  NotEditable
		

	from  Document_Microlotto_Valutazione C with (nolock)
		
		left join document_bando DB with (nolock) on DB.idHeader= C.idHeader
GO
