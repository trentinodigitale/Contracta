USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SIMOG_REQUISITI_DATI_WS]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[SIMOG_REQUISITI_DATI_WS] AS

	SELECT    gara.id as id_gara
			--, isnull(rup.[Value], odc.idpfuRup) as idPfuRup
			,isnull(dg.idpfuRup , odc.idpfuRup) as idPfuRup
			
			, usr.[LOGIN]
			, usr.[PASSWORD]
			, dg.id_gara as simog_id_gara
			, dg.indexCollaborazione
			, req.RequisitoGara as codice_dettaglio
			, req.[Valore] as valore
			, req.[Esclusione] as flag_esclusione
			, req.[ComprovaOfferta] as flag_comprova_offerta
			, req.[Avvalimento] as flag_avvalimento
			, req.[BandoTipo] as flag_bando_tipo
			--, case when req.[Riservatezza] = 'no' then 'N' else req.[Riservatezza] end as flag_riservatezza
			, req.[Riservatezza] as flag_riservatezza
			, req.[ElencoCIG]
			--, left(req.[DescrizioneRequisito], 80) as descrizione
			, req.[DescrizioneRequisito] as descrizione -- passata da 80 a 1024. la maxLen è nel modello
			, reqV.DMV_Father
			, case when reqV.DMV_Father <> 'REQUISITO DI ORDINE GENERALE' then 1 else 0 end as sendSimog
		FROM CTL_DOC gara WITH(NOLOCK)
				left join Document_Bando_Requisiti req with(nolock) on req.idHeader = gara.id 
				left join LIB_DomainValues reqV with(nolock) on reqV.DMV_DM_ID = 'RequisitoGara' and reqv.DMV_Cod = req.RequisitoGara 

				--left join ctl_doc_value rup with(nolock) on rup.idheader = gara.id and rup.dse_id = 'InfoTec_comune' and rup.dzt_name = 'UserRUP' 
				left join document_odc odc with(nolock) on odc.RDA_ID = gara.id -- per il giro cig derivati

				--inner join SIMOG_LOGIN_DATI_WS usr with(nolock) on usr.IdPfu = isnull(rup.[Value], odc.idpfuRup)
				
				--inner join (

				--		select max(id) as idRichCig, LinkedDoc 
				--			from ctl_doc with(nolock) 
				--			where TipoDoc = 'RICHIESTA_CIG' and Deleted = 0 and StatoFunzionale = 'Inviato'
				--			group by LinkedDoc

				--	) cig on cig.LinkedDoc = gara.Id

				left join ctl_doc cig with(nolock)  on cig.LinkedDoc = gara.Id and cig.TipoDoc = 'RICHIESTA_CIG' and cig.Deleted = 0 and cig.StatoFunzionale = 'Inviato'
				left join Document_SIMOG_GARA dg with(nolocK) on dg.idHeader = cig.id
				inner join SIMOG_LOGIN_DATI_WS usr with(nolock) on usr.IdPfu = isnull(dg.idpfuRup , odc.idpfuRup)

			
GO
