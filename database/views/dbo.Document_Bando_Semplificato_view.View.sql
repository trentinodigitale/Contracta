USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Bando_Semplificato_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[Document_Bando_Semplificato_view] as

	SELECT 
		d.Id, d.IdPfu,  d.IdDoc,  d.TipoDoc,  d.StatoDoc,  d.Data, d.Protocollo,  d.PrevDoc, 
		cast(  d.Deleted as int) as deleted,  d.Titolo,  d.Body,  d.Azienda,  d.StrutturaAziendale,  d.DataInvio,  d.DataScadenza,  d.ProtocolloRiferimento,  d.ProtocolloGenerale, 
		 d.Fascicolo,  d.Note,  d.DataProtocolloGenerale,  d.LinkedDoc,  d.SIGN_HASH,  d.SIGN_ATTACH,  d.SIGN_LOCK,  d.JumpCheck,  d.StatoFunzionale,  d.Destinatario_User,  d.Destinatario_Azi,  d.RichiestaFirma,  d.NumeroDocumento,  d.DataDocumento, 
		  d.Versione,  d.VersioneLinkedDoc,  d.GUID,  d.idPfuInCharge,  d.CanaleNotifica,  d.URL_CLIENT,  d.Caption
		, case when getdate() >= b.DataAperturaOfferte and d.StatoFunzionale <> 'InLavorazione' then '1' else '0' end as APERTURA_OFFERTE
		, case when getdate() >= b.DataScadenzaOfferta and d.StatoFunzionale <> 'InLavorazione' then '1' else '0' end as SCADENZA_INVIO_OFFERTE

		, b.TipoBandoGara 
	
		, case when b.TipoProceduraCaratteristica = 'RDO' then 'Richiesta di Offerta'
			   when b.ProceduraGara = '15477' and b.TipoBandoGara = '2' then 'BandoRistretta' -- Ristretta / Bando
			   else
					case when b.TipoSceltaContraente = 'ACCORDOQUADRO' 
						then 'Accordo Quadro'
					else
						case b.TipoBandoGara 
							when '1' then 'Avviso'
							when '3' then 'Invito'
							else 'Bando'	
						end 
					end
			end as CaptionDoc 

		,	case when b.TipoBandoGara  in ( '1' , '4' ) and b.ProceduraGara = '15478' --Negoziata / Avviso
				or b.TipoBandoGara  in ( '2' ) and b.ProceduraGara = '15477' -- Ristretta / Bando
				then '1'
				else '0'
				end PRIMA_FASE
		,	rup.Value as UserRUP

		, isnull(b.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		, b.Divisione_lotti		
		, b.tipobando
		, sb.RichiediProdotti as RichiediProdottiSDA
		, case  when  ISNULL(cod.idrow,'') = '' then 'NO' 
				when ISNULL(cod.idrow,'') <> '' and D2.DZT_ValueDef='YES' then 'SI' 
		 end as PRESENZA_COD_REG

		, ap.APS_IdPfu as  InChargeToApprove
		, case when getdate() >= b.DataPresentazioneRisposte then '1' else '0' end as BANDO_FABB_SCADUTO
		, isnull(b.GeneraConvenzione,'0') as GeneraConvenzione
		, d.StatoFunzionale as S_F

		, case when sortPub.Id is not null then '1' else '0' end as SORTEGGIO
		, case when sortPub2.Id is not null then '1' else '0' end as SORTEGGIO_AVVISO
		, case
			 when d.StatoFunzionale in ('Inviato','Completato') and analisi.id IS NULL then '1' 
			 else '0'
		  end as CAN_PROROGA

		, b.ProceduraGara
		, dbo.ListRiferimentiBando(d.id,'quesiti') as ListRiferimentiBando
		,ISNULL(CU.UtenteCommissione,0) as pres_com_A
		,case 
			when  b.ProceduraGara = '15477' and b.TipoBandoGara='2' then '0'  --DOMANDA PARTECIPAZIONE
			when  b.ProceduraGara = '15478' and b.TipoBandoGara='1' then '0'  --MANIFESTAZIONE_INTERESSE
			when ISNULL(CTP2.valore,0) = '1' and m.IdMp IS NULL  then '0'     --NON VEDIAMO IL COMANDO PER GARE NON APPARTENENTI AZIMASTER E DOVE RICHIESTO SUL CLIENTE solo per gare dell'ente aziMaster
			else  '1'
		 end	as RIAM_OFF_VIS_COMANDO

		, case when SUBSTRING( isnull( l.DZT_ValueDef , '' ) ,245,1)='1' /* and b.RichiestaCigSimog = 'si'*/ then 1 else 0 end as simog 
		, b.RichiestaCigSimog
		, case when rCig.id is null then '0' else '1' end as cigInviato

		, case  --ATTIVAZIONE COMANDO RIAMMISSIONE OFFERTA SOLO AL RUP
			when ISNULL(CTP.Valore,'0') = '1' then '1'
			else '0'	
		   end	as RIAM_OFF_ATT_SOLO_RUP

		 , b.TipoSceltaContraente

		 , case 
				when  b.DataRiferimentoFine is null then  'no' 
				when  b.DataRiferimentoFine < getdate() then  'si' 
				else 'no'
			end as	AQ_SCADUTO		

		, case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled
		, case when ma_id is null then '0' else '1' end as PresenzaAIC
		,'1' as abilitaComandi

		from ctl_doc d with (nolock)
			inner join document_bando b with (nolock) on d.id = b.idheader
			left join ctl_doc s with (nolock) on s.id=d.linkeddoc
			left join document_bando sb with (nolock)on sb.idheader=s.id
			left outer join ctl_doc_value rup with (nolock) on d.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
			left outer join ctl_doc_value idm with (nolock) on d.id = idm.idHeader and  idm.dzt_name = 'id_modello' and idm.dse_id = 'TESTATA_PRODOTTI'
			left outer join ctl_doc_value cod with (nolock) on idm.Value = cod.idHeader and  cod.dzt_name = 'DZT_Name' and cod.dse_id = 'MODELLI' and cod.Value='Codice_Regionale'
			left outer join LIB_Dictionary D2 with (nolock) on D2.DZT_Name='SYS_ATTIVA_CODICE_REGIONALE' 
			left outer join ctl_approvalsteps ap with (nolock) on APS_IsOld = 0 and d.TipoDoc = ap.APS_Doc_Type and ap.APS_State = 'InCharge' and ap.APS_ID_DOC = d.id

			-- Sorteggio associato alla gara/avviso
			left join CTL_DOC sortPub with(nolock) on sortPub.LinkedDoc = d.Id and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0

			-- Se siamo nel giro di invito, verifico la presenza del sorteggio pubblico associato alla precedente fase di avviso
			left join CTL_DOC sortPub2 with(nolock) on sortPub2.LinkedDoc = s.id and sb.TipoBandoGara = '1' and sortPub2.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub2.Deleted = 0
			--VERIFICA SE SONO PRESENTI ANALISI_FABBISOGNI
			left join ctl_doc ANALISI with(nolock) on ANALISI.LinkedDoc=d.Id and ANALISI.TipoDoc='ANALISI_FABBISOGNI' and ANALISI.Deleted=0
			--RECUPERO PRESIDENTE COMMISSIONE A
			left outer join ctl_doc COM with(nolock) on COM.linkeddoc=d.id and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
			left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'		
			left outer join LIB_Dictionary l  with (nolock) on l.DZT_Name='SYS_MODULI_RESULT'
			left outer join CTL_Parametri CTP  with (nolock) on CTP.Contesto='BANDO_GARA-BANDO_SEMPLIFICATO' and CTP.Oggetto='RiammissioneOfferta' and CTP.Proprieta='Riammissione_Offerta_SOLO_RUP'
			left outer join CTL_Parametri CTP2  with (nolock) on CTP2.Contesto='BANDO_GARA-BANDO_SEMPLIFICATO' and CTP2.Oggetto='RiammissioneOfferta' and CTP2.Proprieta='Riammissione_Offerta_SOLO_AZI_MASTER'
			left outer join MarketPlace m  with (nolock) on m.mpidazimaster = D.azienda and m.mpDeleted=0

			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = d.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' )

			--RECUPERA LA SYS_AIC_URL_PAGE
			left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
			-- verifica se nel modello c'è la colonna AIC
			left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = d.id and x.DSE_ID = 'PRODOTTI'
			left outer join CTL_ModelAttributes  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'
			



GO
