USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_GARA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  view [dbo].[OLD_BANDO_GARA_DOCUMENT_VIEW] as

	select d.* , 
			b.Concessione , 
			b.TipoProceduraCaratteristica,
			case when s.id is null then 0 else 1 end as docRichiestaCig,
			dbo.attivoSimog() as attivoSimog,
			isnull(SUBSTRING(Diz.DZT_ValueDef,266,1),0) as ATTIVA_COMPOSIZIONE_AZI_MANIFESTAZIONE,
			isnull(SUBSTRING(Diz.DZT_ValueDef,267,1),0) as ATTIVA_COMPOSIZIONE_AZI_DOMANDA ,
			GARE_IN_MODIFICA_O_RETTIFICA,

			case when ( dm.vatValore_FT <> '' and left( convert(varchar,getdate(), 126), 10) >= dm.vatValore_FT ) --SE LA DATA DELLA GARA è MAGGIORE O UGUALE DELLA DATA DI INIZIO ATTIVAZIONE OCP
						AND
					NOT ( b.ProceduraGara = '15477' and b.TipoBandoGara = '2' ) --SE SIAMO SU UN GIRO DI BANDO RISTRETA
						AND
					NOT ( b.ProceduraGara = '15478' and b.TipoBandoGara = '1' ) --O NEGOZIATA CON AVVISO
						AND
					NOT ( b.Divisione_lotti = '0' and s.id is null ) --SE LA PROCEDURA E' UNA MONOLOTTO PRIVA DELL'INTEGRAZIONE CON IL SIMOG 
				  then 'si'
				  else 'no'
			END AS Attiva_OCP,

			case when s2.id is null then 0 else 1 end as docRichiestaTED,

			case 
				when dm.vatValore_FT <> '' and left( convert(varchar,getdate(), 126), 10) >= dm.vatValore_FT then '1'
				else '0'
			end Show_Attrib_OCP

			, isnull(SIMOG.DZT_ValueDef , '') as SYS_VERSIONE_SIMOG
			, isnull(FaseConcorso,'') as FaseConcorso
			
			, CU.Cottimo_Gara_Unificato_Attivo

		from 
			CTL_DOC d  with (nolock)  
				inner join Document_Bando b with(nolock) on b.idHeader = d.Id
				left join ctl_doc s with(nolock) on s.LinkedDoc = d.Id and s.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and s.Deleted = 0 and s.StatoFunzionale in ( 'InvioInCorso', 'Inviato' )
				left join ctl_doc s2 with(nolock) on s2.LinkedDoc = d.Id and s2.TipoDoc = 'DELTA_TED' and s2.Deleted = 0 and s2.StatoFunzionale in ( 'InvioInCorso', 'Inviato' )
				left join LIB_Dictionary Diz with(nolock) on Diz.DZT_Name='SYS_MODULI_RESULT'
				cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm

				left join DM_Attributi dm with(nolock) on dm.lnk = d.Azienda and dm.dztNome = 'DataAttivazioneOCP'
				
				--prendo la versione simog in essere
				left outer join lib_dictionary SIMOG with (nolock) on SIMOG.dzt_name='SYS_VERSIONE_SIMOG'

				--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
				cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato_Attivo ) CU  
		


GO
