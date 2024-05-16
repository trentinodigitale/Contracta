USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_SIMOG_GARA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_Document_SIMOG_GARA_VIEW] as 

	select 
			g.idrow, g.idHeader, [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], g.[CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], 
	
			r.StatoRichiesta as [StatoRichiestaGARA], case when r.idrow is null then [EsitoControlli] else msgError end as [EsitoControlli], [id_gara], g.[idpfuRup]
 
			, r.idrow as ID_RICHIESTA
			, g.idHeader as id
			, [MOTIVAZIONE_CIG]
			, [MOTIVO_CANCELLAZIONE_GARA]
			, [AzioneProposta]
			, d.StatoFunzionale			
			, r.isOld
			, DB.TipoAppaltoGara
			, bando.TipoDoc as TipoDoc_collegato -- controllato lato JS,  se è un bando_semplificato chiediamo conferma al cambio di scelta del contraente

			-- nuove colonne per versione simog 3.4.2
			, g.STRUMENTO_SVOLGIMENTO
			, g.ESTREMA_URGENZA 
			, g.MODO_INDIZIONE

			-- nuove colonne per versione simog 3.4.3
			, g.ALLEGATO_IX
			, g.DURATA_ACCQUADRO_CONVENZIONE
			, g.CIG_ACC_QUADRO

			, isnull(g.NotEditable,'') as NotEditable
			, g.link_affidamento_diretto
		 from Document_SIMOG_GARA g with(nolock)
				left outer join Service_SIMOG_Requests r with(nolock) on g.idrow = r.idRichiesta and r.operazioneRichiesta in ( 'garainserisci' , 'garamodifica' , 'garacancella' ) and r.isOld = 0 
				inner join CTL_DOC d with(nolock) on d.id = g.idHeader
				inner join ctl_doc bando with(nolock) on bando.id=d.LinkedDoc
				left join Document_Bando DB with(nolock) on DB.idHeader=d.LinkedDoc -- passiamo a left join invece di inner per gestire anchegli ODF ed i cig derivati
GO
