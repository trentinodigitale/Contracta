USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARER_VIEW_ORDINATIVO_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[PARER_VIEW_ORDINATIVO_XML] AS
	select o.id --chiave di ingresso

			-- FILE DA INVIARE
			, o.SIGN_ATTACH as Allegato
			
			--- *** INTESTAZIONE *** ---
			, isnull(s2.DZT_ValueDef,'1.5') as CONSERVAZIONE_VERSIONE
			, case when s1.DZT_ValueDef = 'PRODUZIONE' then 'PARER' else 'PARER_PRE' end as CONSERVAZIONE_AMBIENTE
			, case when s1.DZT_ValueDef = 'PRODUZIONE' then 'regione_emilia-romagna' else 'PRE_regione_emilia-romagna' end as CONSERVAZIONE_ENTE
			, 'intercenter' as CONSERVAZIONE_STRUTTURA
			, case when s1.DZT_ValueDef = 'PRODUZIONE' then 'AF_SATER_INTERCENTER' else 'AF_SATER_INTERCENTER_PRE' end as CONSERVAZIONE_USER_ID
			, o.Protocollo as CONSERVAZIONE_CHIAVE_NUMERO
			, YEAR(o.DataInvio) as CONSERVAZIONE_CHIAVE_ANNO
			, 'PI' as CONSERVAZIONE_CHIAVE_TIPO_REGISTRO

			--- *** PROFILO UNITA DOCUMENTARIA *** ---
			, isnull(co.titolo,'') AS CONVENZIONE_OGGETTO
			, isnull(c.NumOrd,'') AS CONVENZIONE_NUMERO
			, CONVERT(varchar(10), o.DataInvio, 126) AS ODC_DATAINVIO

			--- *** DATI SPECIFICI *** ---
			, isnull(o.Titolo,'Senza Titolo') as ODC_TITOLO
			, CONVERT(VARCHAR(19),isnull(f1.DataApposizioneFirma,o.datainvio), 126) as ODC_DATA_FIRMA_PO
			, isnull(do.cig_madre,'') as ODC_CIG_MASTER
			, isnull(do.cig,'') as ODC_CIG_DERIVATO
			, a.aziRagioneSociale as ODC_ENTE_ADERENTE
			, d1.vatValore_FT as ODC_ENTE_ADERENTE_CF
			, a2.aziRagioneSociale as ODC_FORNITORE_DESTINATARIO
			, a2.aziPartitaIVA as ODC_FORNITORE_DESTINATARIO_PIVA
			, d2.vatValore_FT as ODC_FORNITORE_DESTINATARIO_CF 
			, isnull(c.NumOrd,'') AS CONVENZIONE_COMPLETA_NUMERO
			, isnull(co.titolo,'') AS CONVENZIONE_COMPLETA_OGGETTO
			, isnull(s3.DZT_ValueDef,'1') as AFLINK_VERSIONE
			
			--- *** DOCUMENTI COLLEGATI *** ---
			-- Sono previsti i seguenti collegamenti:
			--    - dell'Ordinativo integrativo all'ordinativo iniziale
			--	  - dell'Ordinativo di riduzione all'ordinativo iniziale
			--	  - alla Convenzione / Accordo Quadro (Repertorio RSPIC)

			, case when isnull(do.IdDocIntegrato,0) > 0 then 'INTEGRAZIONE'
				  when isnull(do.IdDocRidotto,0) > 0 then 'RIDUZIONE'
				  else 'CONVENZIONE / ACCORDO QUADRO'
			  end as DOC_COLLEGATO_DESC_COLLEGAMENTO

			, case when isnull(do.IdDocIntegrato,0) > 0 then odci.Protocollo
				   when isnull(do.IdDocRidotto,0) > 0 then odcr.Protocollo
				   else case when co.ProtocolloGenerale <> '' then dbo.getpos(replace( isnull(tr.ValOut,co.ProtocolloGenerale) ,'.','-'),'-',3) 
							 else dbo.getpos(co.Protocollo, '-', 2)
						 end --rspic
				  -- else replace(isnull(co.ProtocolloGenerale,co.Protocollo),'.','-') --rspic
			  end as DOC_COLLEGATO_NUMERO

			  

			, case when isnull(do.IdDocIntegrato,0) > 0 then YEAR(odci.DataInvio)
				  when isnull(do.IdDocRidotto,0) > 0 then YEAR(odcr.DataInvio)
				  else YEAR(co.DataInvio)
			  end as DOC_COLLEGATO_ANNO

			, case when isnull(do.IdDocIntegrato,0) > 0 or isnull(do.IdDocRidotto,0) > 0 or co.ProtocolloGenerale is null then 'PI' else 'RSPIC' end as DOC_COLLEGATO_TIPOREGISTRO

			--- *** EXTRA *** ---
			, cast( isnull(al.totAllegati,0) as varchar) as ODC_NUMERO_ALLEGATI

			--- *** DOCUMENTO PRINCIPALE *** ---
			, dbo.getpos(o.sign_attach,'*',4) as DOC_PRINCIPALE_ATT_HASH
			, isnull(f1.firmatario,'') as ODC_PO_NOMINATIVO
			, replace(dbo.getpos(o.sign_attach,'*',1),'&','E') as DOC_PRINCIPALE_FILE_NAME -- non è chiaro perchè la & non viene convertita dall'html encode che fa il codice. questa mancanza ci porta all'errore "Errore in fase di canonicalizzazione XML"
			, case when right(dbo.getpos(o.sign_attach,'*',1), 8) = '.pdf.p7m' then 'PDF.P7M' else upper(dbo.getpos(o.sign_attach,'*',2)) end as DOC_PRINCIPALE_FILE_EXT
			, dbo.getpos(o.sign_attach,'*',6) as DOC_PRINCIPALE_FILE_HASH

		from ctl_doc o with(nolock)
				inner join aziende a with(nolock) on a.idazi = o.azienda
				inner join DM_Attributi d1 with(nolock) on d1.lnk = a.idazi and d1.idApp = 1 and d1.dztNome = 'codicefiscale'
				cross join LIB_Dictionary s1 with(nolock) --SYS_AFUPDATE_AMBIENTE
				cross join LIB_Dictionary s2 with(nolock) --SYS_CONSERVAZIONE_VERSIONE
				cross join LIB_Dictionary s3 with(nolock) --SYS_RELEASE_AFLINK
				inner join Document_ODC do with(nolock) on do.rda_id = o.id 
				inner join Document_Convenzione c with(nolock) on o.LinkedDoc = c.ID
				inner join ctl_doc co with(nolock)on co.id = c.id 
				left join CTL_SIGN_ATTACH_INFO f1 with(nolock) on o.sign_attach <> '' and f1.ATT_Hash = dbo.getpos(o.sign_attach,'*',4)
				inner join aziende a2 with(nolock) on a2.idazi = do.IdAziDest
				inner join DM_Attributi d2 with(nolock) on d2.lnk = a2.idazi and d2.idApp = 1 and d2.dztNome = 'codicefiscale'
				left join ctl_doc odci with(nolocK) on odci.id = do.IdDocIntegrato
				left join ctl_doc odcr with(nolocK) on odcr.id = do.IdDocRidotto

				left join (
						select count(*) as totAllegati, idHeader
							from CTL_DOC_ALLEGATI with(nolocK)
							group by idHeader
					) al on al.idHeader = o.Id

				left join CTL_Transcodifica tr with(nolock) on tr.dztNome = 'rspic_rettificato' and Sistema = 'parer' and ValIn = co.ProtocolloGenerale

		where o.TipoDoc = 'ODC' --AND o.id = 419722 
				and s1.DZT_Name = 'SYS_AFUPDATE_AMBIENTE'
				and s2.DZT_Name = 'SYS_CONSERVAZIONE_VERSIONE'
				and s3.DZT_Name = 'SYS_RELEASE_AFLINK'
GO
