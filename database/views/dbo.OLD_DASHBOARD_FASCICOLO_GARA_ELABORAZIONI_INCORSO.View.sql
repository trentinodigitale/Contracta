USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_FASCICOLO_GARA_ELABORAZIONI_INCORSO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [dbo].[OLD_DASHBOARD_FASCICOLO_GARA_ELABORAZIONI_INCORSO] as 

	select 
		--E.*,
		E.[Id], E.[IdDoc], E.[TipoDoc], E.[Idpfu], E.[Azienda], E.[Titolo], E.[DataInizio], E.[PercAvanzamento], E.[Deleted],E.[DataUltimaElaborazione], E.[DPR_DOC_ID], E.[DPR_ID],

		DataInizio as DataInizioAl,
		V.idpfu as Owner,
		--azienda as azi_ente,
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
		,
		F.Fascicolo , 
		F.NumeroDocumento,
		F.StatoFunzionale,
		F.Protocollo,
		Dett_Gara.IdentificativoIniziativa,
		DocS.Tipodoc as TipoDoc_collegato,
		isnull(Dett_Gara.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica,
		isnull(TipoSceltaContraente,'') as TipoSceltaContraente
		
		, C.Cottimo_Gara_Unificato

		from 
			CTL_ELABORAZIONI_SCHEDULATE E with (nolock)
				inner join VIEW_VISIBILITA_FASCICOLO_GARA V  on V.id = E.IdDoc 
				inner join ctl_doc F with (nolock) on F.ID = E.IdDoc  and F.tipodoc = e.tipodoc
				inner join ctl_doc DocS with (nolock) on DocS.fascicolo=F.Fascicolo and DocS.tipodoc in ('bando_gara', 'bando_semplificato','BANDO_CONCORSO') and Docs.deleted = 0 and CHARINDEX('###' + DocS.StatoFunzionale + '###', (dbo.PARAMETRI('FASCICOLO_DI_GARA', 'EsportazioneFascicolo', 'Stati_Per_Attivazione', '###Chiuso###', -1))) > 0
				--DocS.StatoFunzionale ='Chiuso' --vecchia condizione, adesso viene presa dai parametri
				inner join document_bando Dett_Gara with (nolock) on Dett_Gara.idHeader = DocS.Id

				--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
				cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) C  


		where 
			e.tipodoc ='FASCICOLO_GARA' 
		
	
		



GO
