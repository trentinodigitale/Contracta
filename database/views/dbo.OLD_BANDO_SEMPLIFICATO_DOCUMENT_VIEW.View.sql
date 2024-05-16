USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SEMPLIFICATO_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_BANDO_SEMPLIFICATO_DOCUMENT_VIEW] as
	select d.* 
			, case when s.id is null then 0 else 1 end docRichiestaCig,
			dbo.attivoSimog() as attivoSimog,

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
			GARE_IN_MODIFICA_O_RETTIFICA
		from CTL_DOC d
				inner join Document_Bando b with(nolock) on b.idHeader = d.Id
				left join ctl_doc s with(nolock) on s.LinkedDoc = d.Id and s.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and s.Deleted = 0 and s.StatoFunzionale in ( 'InvioInCorso', 'Inviato' )
				left join DM_Attributi dm with(nolock) on dm.lnk = d.Azienda and dm.dztNome = 'DataAttivazioneOCP'
				cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm
GO
