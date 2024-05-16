USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ESTRAZIONE_LISTINI_CONVENZIONI_RIEPILOGO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[VIEW_ESTRAZIONE_LISTINI_CONVENZIONI_RIEPILOGO] as 

	select 
			E.*,
			
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

			F.DataScadenza --,

			--case 
			--	when F.DataScadenza is null then ''
			--	else
			--		case

			--			when datediff(second,F.DataScadenza , dateadd(d,P.NumGiorni,F.DataScadenza)) < 120 then cast(  datediff(second,F.DataScadenza,dateadd(d,P.NumGiorni,F.DataScadenza)) as varchar) + ' secondi'
			--			when datediff(second,F.DataScadenza,dateadd(d,P.NumGiorni,F.DataScadenza))  > 120 and datediff(second,F.DataScadenza,dateadd(d,P.NumGiorni,F.DataScadenza))  < 7200 then cast(  datediff(minute,F.DataScadenza,dateadd(d,P.NumGiorni,F.DataScadenza)) as varchar) + ' minuti'

			--			--fino a 120 minuti
			--			--poi passa a ore
			--			else cast(  datediff(HOUR,F.DataScadenza,dateadd(d,P.NumGiorni,F.DataScadenza) ) as varchar) + ' ore'
			--		end
			-- end as TempoResiduoCancellazione


		from 
			
			CTL_ELABORAZIONI_SCHEDULATE E with (nolock) 
				inner join ctl_doc F on F.id = E.iddoc and F.TipoDoc = E.TipoDoc
				--cross join (
						
				--			select 
				--				NumGiorni 
				--				from ctl_doc with (nolock) 
				--					inner join Document_Config_FascicoloGara with (nolock)  on idheader = id 
				--				where 
				--					tipodoc='PARAMETRI_FASCICOLO_GARA' and statofunzionale='Confermato'
								 
									
				
				--			) P 
		where 
			e.tipodoc ='ESTRAZIONE_LISTINI_CONVENZIONI' 
GO
