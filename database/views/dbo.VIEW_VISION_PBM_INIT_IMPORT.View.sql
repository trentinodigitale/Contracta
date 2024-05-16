USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VISION_PBM_INIT_IMPORT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[VIEW_VISION_PBM_INIT_IMPORT] AS
	select  a.id as idComAggiudicazione,
			d.id as idGara,
			c.id as idPDA,
			case when d2.TipoBandoGara = 3 then 1 else 0 end as invito,
			case when d2.TipoSceltaContraente = 'ACCORDOQUADRO' then 1 else 0 end as accordoQuadro,
			b2.NumeroLotto,
			isnull(d2.CalcoloAnomalia,0) as CalcoloAnomalia,
			case when d2.Divisione_lotti = 0 then 1 else 0 end as monoLotto,
			isnull(lotti.CIG, d2.cig) as CIG,
			--case when v2.IdRow is null then 0 else 1 end as inviato,
			0 as inviato,
			--case when TipoAggiudicazione = 'multifornitore' then 1 else 0 end as multiAggiudicatario,
			case when BCL.TipoAggiudicazione = 'multifornitore' then 1 else 0 end as multiAggiudicatario,

			a.Protocollo as numeroVerbale,
			isnull(a.DataInvio, b.DataInvio) as dataVerbale,
			d.Azienda as idAziEnte,
			rel.REL_ValueOutput as idArchivio

			--,d2.* 
		from ctl_doc a with(nolock)
				inner join ctl_doc b with(nolock) ON b.id = a.LinkedDoc and b.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA'
				inner join Document_comunicazione_StatoLotti b2 with(nolock) on b2.idheader = b.id and b2.Deleted = 0
				inner join ctl_doc c with(nolock) ON c.id = b.LinkedDoc and c.TipoDoc = 'PDA_MICROLOTTI'
				inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = b.LinkedDoc and lotti.TipoDoc = 'PDA_MICROLOTTI' and lotti.NumeroLotto = b2.NumeroLotto and ISNULL(lotti.voce,0) = 0
				inner join ctl_doc d with(nolock) ON d.id = c.LinkedDoc and d.TipoDoc = 'BANDO_GARA'
				inner join Document_Bando d2 with(nolock) ON d2.idheader = d.id

				--per recuperare TipoAggiudicazione dal lotto
				inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO BCL on BCL.idBando = d.id and BCL.N_Lotto = b2.NumeroLotto 

				-- Espongo la colonna 'inviato' per dire se il CIG in esame è stato già inviato a VisionPBM
				--left join v_protgen v with(nolock) ON v.Appl_Id_Evento = cast( a.id as varchar ) and v.Flag_Annullato = 0
				--left join v_protgen_dati v2 with(nolock) ON v2.IdHeader = v.id and v2.DZT_Name = 'CIG' and v2.[Value] = isnull(lotti.CIG, d2.cig)

				-- SE E' ATTIVA LA CONFIGURAZIONE MULTIDB LATO VISION PBM, RECUPERO L'ID ARCHIVIO DALLA RELAZIONE 'INTEGRAZIONE_TEAMSYSTEM_PBM' ENTRANDO PER L'ID AZI DELL'ENTE CHE HA EMESSO LA GARA
				LEFT JOIN ctl_relations rel WITH(NOLOCK) ON rel.REL_Type = 'INTEGRAZIONE_TEAMSYSTEM_PBM' 
																and case when ISNULL(d2.EnteProponente,'') <> '' then LEFT(d2.EnteProponente, CHARINDEX('#',d2.EnteProponente,0)-1)
																		 else cast( d.Azienda as varchar ) --ente espletante
																	end = rel.REL_ValueInput

		where a.tipodoc = 'PDA_COMUNICAZIONE_GARA' and a.JumpCheck like '%-ESITO_DEFINITIVO_MICROLOTTI%' 





GO
