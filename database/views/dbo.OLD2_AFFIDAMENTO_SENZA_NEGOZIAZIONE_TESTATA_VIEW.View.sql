USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AFFIDAMENTO_SENZA_NEGOZIAZIONE_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD2_AFFIDAMENTO_SENZA_NEGOZIAZIONE_TESTATA_VIEW] as 

	select 
		  d.id
		, d.Titolo
		, d.StatoFunzionale
		, d.Protocollo
		, d.DataInvio
		, b.idRow
		, b.idHeader
		, b.ImportoBando
		, b.dataCreazione
		, b.StatoBando
		, b.TipoBando
		, b.ProceduraGara
		, b.TipoBandoGara
		, b.CriterioAggiudicazioneGara
		, b.ImportoBaseAsta
		, b.ImportoBaseAsta2
		, b.CUP
		, b.CIG
		, b.TipoAppaltoGara
		, b.ProtocolloBando
		, b.Divisione_lotti
		, b.DirezioneEspletante
		, b.DataProtocolloBando
		, b.TipoProceduraCaratteristica
		, d.Azienda 
		, d.StrutturaAziendale
		, d.Body
		, v2.Value as UserRUP
		, d.Fascicolo

		, case when edit.Value = '1'
			then ''
			else ' aziRagioneSociale '
			end as Not_Editable

		, d.LinkedDoc
		, d.protocollogenerale
		, pda.id as idpda

		, '' as StatoProcedura

		, b.DataChiusura
		, d.Azienda as StazioneAppaltante
		, b.EnteProponente
		, b.RupProponente
		, DEST.IdAzi as  Destinatario_Azi 
		 
		--campi pnrr/pnc
		, lower(X.ATTIVA_MODULO_PNRR_PNC) as ATTIVA_MODULO_PNRR_PNC
		, b.Appalto_PNRR_PNC
		, b.Appalto_PNRR
		, b.Motivazione_Appalto_PNRR
		, b.Appalto_PNC
		, b.Motivazione_Appalto_PNC

		,b.pcp_UlterioriSommeNoRibasso
		,b.pcp_SommeRipetizioni
		   
		,PCP.pcp_TipoScheda

		,cf.Value as aziCodiceFiscale
		,rag.Value as aziRagioneSociale
		,d.IdPfu

	from CTL_DOC d with(nolock)
		inner join Document_Bando b with(nolock) on d.id = b.idheader
		inner join profiliutente p with(nolock) on d.idpfu = p.idpfu
		left join marketplace m with(nolock) on m.mpidazimaster = p.pfuidazi
		left outer join CTL_DOC_Value v1 with(nolock) on b.idheader = v1.idheader and v1.dzt_name = 'ArtClasMerceologica' and v1.DSE_ID = 'ATTI'
		left outer join CTL_DOC_Value v1_1 with(nolock) on b.idheader = v1_1.idheader and v1_1.dzt_name = 'TIPO_SOGGETTO_ART' and v1_1.DSE_ID = 'ATTI'
		left outer join CTL_DOC_Value v2 with(nolock) on b.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'

		left outer join Document_Bando bs with(nolock) on d.LinkedDoc = bs.idheader and bs.idHeader <> 0

		-- PDA
		left outer join CTL_DOC pda with(nolock) on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

		-- REVOCA
		left outer join ctl_doc rev with(nolock) on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id

		--BloccaCriteriEreditati
		left outer join CTL_DOC_Value v3 with(nolock) on b.idheader = v3.idheader and v3.dzt_name = 'BloccaCriteriEreditati' and v3.DSE_ID = 'InfoTec_comune'

		left outer join LIB_Dictionary l with(nolock) on l.DZT_Name='SYS_MODULI_RESULT' 

		--MODULO GROUP_PROGRAMMAZIONE_INIZIATIVE
		left join lib_dictionary Y with(nolock) on Y.dzt_name='SYS_MODULI_GRUPPI' and charindex(',GROUP_PROGRAMMAZIONE_INIZIATIVE,' , Y.DZT_ValueDef) > 0

		-- RICHIESTA CIG
		left join ctl_doc cig with(nolock) on cig.LinkedDoc = d.Id and cig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and cig.Deleted = 0 and cig.StatoFunzionale <> 'Annullato'

		--ABILITAZIONE SET ENTE PROPONENTE
		left join DM_Attributi DM with(nolock) on DM.lnk=p.pfuIdAzi and DM.dztNome='SetEnteProponente' and vatValore_FT='1'

		-- recupera le regole da utilizzare per consentire la scelta del campo InversioneBuste
		--cross join ( select  dbo.PARAMETRI('BANDO_GARA_TESTATA','InversioneBusteRegole','DefaultValue','',-1) as InversioneBusteRegole ) as Reg 
		
		--PER I RILANCI COMPETITIVI SE TROVA IL FLAG, BLOCCA IN TESTATA IL CAMPO "Criterio Formulazione Offerta Economica"
		--left outer join CTL_DOC_Value v4 with(nolock) on b.idheader = v4.idheader and v4.dzt_name = 'CriterioFormulazioneOffertaEconomica' and v3.DSE_ID = 'BLOCCA'
		
		cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 
		
		--vado sulla ctl_doc_destinatari per gli affidamenti diretti semplificati
		left outer join ctl_Doc_destinatari DEST with (nolock) on DEST.idheader = D.id  and b.TipoProceduraCaratteristica ='AffidamentoSemplificato'
		
		cross join ( select  dbo.PARAMETRI('ATTIVA_MODULO','MODULO_APPALTO_PNRR_PNC','ATTIVA','NO',-1) as ATTIVA_MODULO_PNRR_PNC ) as X 	

        -- Per GGAP (non usato): metto non editabiliu i campi per "Appalto PNRR/PNC" quando metto la spunta perchè i valori sono da prendere da GGAP.
        CROSS JOIN ( SELECT ISNULL( CHARINDEX('SIMOG_GGAP', (select DZT_ValueDef from LIB_Dictionary WITH(NOLOCK) where DZT_Name = 'SYS_MODULI_GRUPPI')) , -1) AS SimogGgap ) AS IsAbilitatoModulo

		Left join Document_PCP_Appalto PCP with(nolock) on PCP.idheader = d.id

		left join CTL_DOC_VALUE cf with(nolock) on d.id = cf.IdHeader and cf.DSE_ID = 'InfoTec_SIMOG' and cf.DZT_Name = 'aziCodiceFiscale'
		left join CTL_DOC_VALUE rag with(nolock) on d.id = rag.IdHeader and rag.DSE_ID = 'InfoTec_SIMOG' and rag.DZT_Name = 'aziRagioneSociale'
		left join CTL_DOC_VALUE edit with(nolock) on d.id = edit.IdHeader and edit.DZT_Name = 'isDescrizioneEditabile'
			
GO
