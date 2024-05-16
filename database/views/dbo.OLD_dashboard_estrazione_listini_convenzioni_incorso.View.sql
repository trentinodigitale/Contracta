USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_dashboard_estrazione_listini_convenzioni_incorso]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_dashboard_estrazione_listini_convenzioni_incorso] as 

	select 
		--E.*,
		E.[Id], E.[IdDoc], E.[TipoDoc], F.[Titolo] ,  
		E.[DataInizio], E.[PercAvanzamento], E.[Deleted], E.[DataUltimaElaborazione], 
		E.[DPR_DOC_ID], E.[DPR_ID],
		F.StatoFunzionale 
		,DataInizio as DataInizioAl,
		
		e.tipodoc as OPEN_DOC_NAME,
		F.jumpcheck as Ambito,

		case 
			when percavanzamento <> 100 and  percavanzamento <> 0 then
			case 
				when datediff(second,datainizio,getdate()) < 120 then cast(  datediff(second,datainizio,getdate()) as varchar) + ' secondi'
				when datediff(second,datainizio,getdate())  > 120 and datediff(second,datainizio,getdate())  < 7200 then cast(  datediff(minute,datainizio,getdate()) as varchar) + ' minuti'

				--fino a 120 minuti
				--poi passa a ore
				 else cast(  datediff(HOUR,datainizio,getdate()) as varchar) + ' ore'
			end
			else 
			case
				when datediff(second,datainizio,DataUltimaElaborazione) < 120 then cast(  datediff(second,datainizio,DataUltimaElaborazione) as varchar) + ' secondi'
				when datediff(second,datainizio,DataUltimaElaborazione)  > 120 and datediff(second,datainizio,DataUltimaElaborazione)  < 7200 then cast(  datediff(minute,datainizio,DataUltimaElaborazione) as varchar) + ' minuti'

				--fino a 120 minuti
				--poi passa a ore
				 else cast(  datediff(HOUR,datainizio,DataUltimaElaborazione) as varchar) + ' ore'
			end
			  
		end as TempoDiElaborazione,

		case 
			when percavanzamento <> 100 and  percavanzamento <> 0 then
			case
				
				 when cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(second,datainizio,getdate() ) as int)  < 120 then
					cast (  cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(second,datainizio,getdate() ) as int  )  as varchar) + ' secondi'
				
				 when cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(second,datainizio,getdate() ) as int ) > 120 and cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(second,datainizio,getdate() ) as int ) < 7200 then
					cast (  cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(second,datainizio,getdate() )/60 as int  )  as varchar) + ' minuti'

				 else
					cast (  cast ( (  ( 100.00 - PercAvanzamento ) / PercAvanzamento  ) * datediff(HOUR,datainizio,getdate() ) as int  )  as varchar) + ' ore'
			end
						
			else '' 
		end
			as StimaTempoResiduo, 
		
		dbo.HTML_Progress_Bar(PercAvanzamento) as EsitoRiga,
		F.Protocollo
		
		from 
			CTL_ELABORAZIONI_SCHEDULATE E with (nolock)
				
				inner join ctl_doc F with (nolock) on F.ID = E.IdDoc  and F.tipodoc = e.tipodoc 
			
		where 
			e.tipodoc ='ESTRAZIONE_LISTINI_CONVENZIONI' 
			and F.Deleted=0
		
	
		


GO
