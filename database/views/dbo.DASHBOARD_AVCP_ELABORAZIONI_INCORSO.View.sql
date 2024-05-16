USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_AVCP_ELABORAZIONI_INCORSO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_AVCP_ELABORAZIONI_INCORSO] as 

	select 
		E.*,
		DataInizio as DataInizioAl,
		V.idpfu as Owner,
		azienda as azi_ente,
		e.tipodoc as OPEN_DOC_NAME,
		--datediff(second,datainizio,getdate()) as TempoDiElaborazione
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
		
		dbo.HTML_Progress_Bar(PercAvanzamento) as EsitoRiga


		
		from 
			CTL_ELABORAZIONI_SCHEDULATE E
				inner join VIEW_GET_ENTI_FROM_CF_USER_AZI V on idAziEnte = Azienda
				
		--where 
		--	E.deleted=0


	--select cast( (100.00-10)/10 * 7 as int)
			

GO
