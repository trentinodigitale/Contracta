USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUOTIDIANI_PUBBLICITA_LEGALE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[DASHBOARD_VIEW_QUOTIDIANI_PUBBLICITA_LEGALE]

as

select 
		c.id ,
		P.idpfu as owner,
		Pratica,
		Giornale,Fornitore,q.Importo,aps_date,
		C.titolo,
		C.body,
		Protocol,
		C.Protocollo,
		JumpCheck as Guri_Quotidiani,
		C.StatoFunzionale,
		Tipologia,
		C.datainvio
	from 
		CTL_DOC C with (nolock)
			LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
			inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=C.Azienda and pfuDeleted=0
			inner join 	Document_RicPrevPubblic_Quotidiani Q with (nolock) on q.idHeader = c.id
			inner join 
					--max data per PreventivoDaLavorare
					(
					select 
						APS_ID_DOC , MAX (aps_date) as aps_date
						from 
							PUBBLICITA_LEGALE_WORKFLOW_VIEW
						where 
							Statofunzionale ='PreventivoDaLavorare'
							and APS_Date is not null
						group by APS_ID_DOC 
					) PQ on PQ.APS_ID_DOC = c.id
	where 
		TipoDoc='PUBBLICITA_LEGALE'	
		and JumpCheck='QUOTIDIANI'
		and StatoFunzionale not in ('Annullato','InLavorazione' )
		and c.Deleted =0
		and Giornale <>''
		and q.Importo<>0
			

	
GO
