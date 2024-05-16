USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view  [dbo].[OFFERTA_TESTATA_VIEW] as
select 
	--d.* , b.* 
    --COLONNE OFFERTA
     d.Id
    ,d.IdPfu
    ,d.TipoDoc
    ,d.StatoDoc
    ,d.Protocollo
    ,d.PrevDoc
    ,d.Titolo
    ,d.Body
    ,d.Azienda
    ,d.DataInvio
    ,b.DataScadenzaOfferta as DataScadenza
    ,d.ProtocolloRiferimento
    ,d.ProtocolloGenerale
    ,d.Fascicolo
    ,d.Note
    ,d.DataProtocolloGenerale
    ,d.LinkedDoc
    ,d.SIGN_ATTACH
    ,d.SIGN_LOCK
    ,d.JumpCheck
    ,d.StatoFunzionale
    ,d.Destinatario_User
    ,d.Destinatario_Azi
    ,d.RichiestaFirma
    ,d.NumeroDocumento
    ,d.idPfuInCharge
    --FINE COLONNE OFFERTA

    --COLONNE BANDO
    ,b.idRow
    ,b.idHeader
    ,b.TipoBando
    ,b.ProceduraGara
    ,b.TipoBandoGara
    ,b.CriterioAggiudicazioneGara
    ,b.ClausolaFideiussoria
    ,b.CIG
    ,b.ProtocolloBando
    ,b.Conformita
    ,b.Divisione_lotti
    ,b.NumDec
    ,b.ListaAlbi
    --FINE COLONNE BANDO

	,F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK ,
	
	case when F1_SIGN_LOCK <> 0 or F2_SIGN_LOCK <> 0 or F3_SIGN_LOCK <> 0 or F4_SIGN_LOCK <> 0 or isnull( F.nFirme , 0 ) <> 0  then 1
		else 0
		end as FIRMA_IN_CORSO
	
	, ba.tipodoc as TipoDocBando
	
	,DF.FormulaEconomica as colonnatecnica
	
	,M.MOD_Name as ModelloOfferta
	
	,isnull( F.nFirme , 0 ) as nFirme
	
	--campo per indicare se ho generato pdf di tutte le buste
	,case 
	   
	   when d.RichiestaFirma = 'no' then 'noone'
	   
	   when d.RichiestaFirma = 'si' then
		  
		  case 
			 
			 when isnull(b.Divisione_lotti ,0)=0 then
				--monolotto
				case
				    --solo busta economica presente
				    when b.CriterioAggiudicazioneGara <> '15532' and b.CriterioAggiudicazioneGara <> '25532'  and b.Conformita = 'No' and ISNULL(F1_SIGN_LOCK,'') <> '' then 'all'
				    
				    --solo busta economica presente
				    when  b.CriterioAggiudicazioneGara <> '15532'  and  b.CriterioAggiudicazioneGara <> '25532'  and b.Conformita = 'No' and ISNULL(F1_SIGN_LOCK,'') = '' then 'noone'

				    --busta tecnica e busta economica presenti
				    when ( b.CriterioAggiudicazioneGara = '15532'  or b.CriterioAggiudicazioneGara = '25532'  or b.Conformita <> 'No') and ISNULL(F1_SIGN_LOCK,'') <> '' and ISNULL(F3_SIGN_LOCK,'') <> '' then 'all'

				    --busta tecnica e busta economica presenti
				    when ( b.CriterioAggiudicazioneGara = '15532'  or b.CriterioAggiudicazioneGara = '25532'  or b.Conformita <> 'No') and ISNULL(F1_SIGN_LOCK,'') = '' and  ISNULL(F3_SIGN_LOCK,'') = '' then 'noone'

				    --busta tecnica e busta economica presenti
				    when ( b.CriterioAggiudicazioneGara = '15532' or b.CriterioAggiudicazioneGara = '25532'  or b.Conformita <> 'No') and (ISNULL(F1_SIGN_LOCK,'') = '' or  ISNULL(F3_SIGN_LOCK,'') = '') then 'partial'

				end
			 
			 else 
				--lotti
				case
		  		    --ho generato pdf tecniche ed economiche di tutte le buste
				    when isnull(NumLottiPDF,0) = isnull( numLotti , 0 )  and isnull( numLotti , 0 )<>0  then 'all'
				    
				    when isnull(NumLottiPDF,0) = 0 then
				
					   --case	   
						  --when isnull(NumPDF,0) <> 0 then 'partial'
						  --else 'noone'
					   --end

					   case 
						  when isnull( F.nFirme , 0 ) <> 0 then 'partial'
						  else 'noone'
					   end

				    else 'partial'

				    
				end
		  end
		  		  
     end as STATE_PDF_BUSTE
	,
	
	--dbo.Get_Estensioni_Allegati_Prodotti_Bando(d.id) as Estensioni_Prodotti_Gara
	'' as Estensioni_Prodotti_Gara
	--,NumLottiPDF
	--,numLotti
	,ISNULL(b.Num_max_lotti_offerti,'') as Num_max_lotti_offerti
	,ISNULL(LZ.DZT_ValueDef,'NO') as  SYS_OFFERTA_PRESENZA_ESECUTRICI
	,ISNULL(b.Richiesta_terna_subappalto,'') as Richiesta_terna_subappalto_sul_bando
	,ISNULL(CR.id,0) as id_ritira_offerta
	
	, case when getdate() <= DataScadenzaOfferta then '0' else '1' end as DATA_INVIO_SUPERATA
	,isnull(b.Concessione,'no') as Concessione
	,ISNULL(FLAG.value,0) as CONSENTI_INVIO_FT 

	, dbo.ISPBMInstalled() as ISPBMInstalled
	,b.Complex
	,ISNULL(JSON_DOMINI_CRITERI.Value,'') as LstAttrib_DOMINI_CRITERI
	
	,bp.Value as AttivaFilePending
	,d.Versione 
	,d.VersioneLinkedDoc 
	,cobust.value aS ControlloFirmaBuste
	,isnull(ampGamma.Value, 'no') as PresenzaAmpiezzaDiGamma
	, case 
		when isnull((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'), '') = '' then 'no'
		else 'si'
	end as PresenzaModuloAmpiezzaGamma

	--Rettifica Offerte Flag
	,isnull(RettEco.id,0) as RettificaOffertaEco
	,isnull(RettTec.id,0) as RettificaOffertaTec
	,isnull(FlagRettifica.Valore,0) as FlagRettifica
	--,isnull(CommTec.UtenteCommissione,0) as PresidenteTec
	--,isnull(CommEco.UtenteCommissione,0) as PresidenteEco

from CTL_DOC d with(nolock)
	
	inner join Document_Bando b with(nolock) on d.LinkedDoc = b.idHeader
	
	inner join CTL_DOC ba with(nolock) on d.LinkedDoc = ba.id
	left join ctl_doc_value bp with(nolock) on bp.idheader = ba.id and bp.DSE_ID = 'PARAMETRI' and bp.DZT_Name = 'AttivaFilePending'
	left join CTL_DOC Mo with(nolock)  on Mo.LinkedDoc = ba.Id  and mo.TipoDoc = 'CONFIG_MODELLI_LOTTI' and mo.Deleted = 0 
	left join ctl_doc_value as ampGamma with(nolock) on ampGamma.idheader = Mo.id and ampGamma.DSE_ID = 'AMBITO' and ampGamma.DZT_Name = 'PresenzaAmpiezzaDiGamma'

	left outer join CTL_DOC_SIGN s with(nolock) on s.idHeader = d.id
	
	-- verifica 
	left outer join (
				
				select d.idheader , count(*) as numLotti,
				    sum( case when DF.F1_SIGN_LOCK <> 0 then 1 else 0 end + case when DF.F2_SIGN_LOCK <> 0 then 1 else 0 end ) as nFirme,
				    
				     sum( 
							    case when 
									    (
										    -- se pdf della busta tecnica è generato
											ISNULL(DF.F2_SIGN_LOCK,'') <> ''
										    or
										    -- non è necessaria la busta tecnica ( prezzo senza conformità
										    ( isnull( v1.Value , CriterioAggiudicazioneGara ) <> '15532' and  isnull( v1.Value , CriterioAggiudicazioneGara ) <> '25532'  and isnull( v2.Value , Conformita ) = 'No' ) 
									    )
									    
									    -- se pdf della busta economica è generato
									    and ISNULL(DF.F1_SIGN_LOCK,'') <> ''
														
							    then 1 else 0 end 
				    ) as NumLottiPDF  

				    --,sum( 
							 --   case when 
								--	    (
								--		    -- se pdf della busta tecnica è generato
								--			ISNULL(DF.F2_SIGN_LOCK,'') <> ''
								--		    or
								--		    -- non è necessaria la busta tecnica ( prezzo senza conformità
								--		    ( isnull( v1.Value , CriterioAggiudicazioneGara ) <> '15532'  and isnull( v1.Value , CriterioAggiudicazioneGara ) <> '25532' and isnull( v2.Value , Conformita ) = 'No' ) 
								--	    )
									    
								--	    -- se pdf della busta economica è generato
								--	    or ISNULL(DF.F1_SIGN_LOCK,'') <> ''
														
							 --   then 1 else 0 end 
				    --) as NumPDF
				      
							     
				     from 
					   Document_MicroLotti_Dettagli d with (nolock)
							inner join Document_Microlotto_Firme DF with (nolock) on d.id = DF.idheader
							inner join CTL_DOC C with (nolock) on C.id = D.idheader -- Offerta
							inner join ctl_doc b with (nolock) on b.id = C.linkeddoc -- BANDO
							inner join document_bando ba with (nolock) on  ba.idheader = b.id
							inner join document_microlotti_dettagli lb with (nolock)  on b.id = lb.idheader and lb.tipodoc = b.Tipodoc and lb.Voce = D.Voce and lb.NumeroLotto = D.NumeroLotto 
								left outer join Document_Microlotti_DOC_Value v1 with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
								left outer join Document_Microlotti_DOC_Value v2 with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
					
							where d.Tipodoc in ('OFFERTA', 'RISPOSTA_CONCORSO')
							group by d.idheader
	
				) as F on F.idheader = d.id
		 
		  left join Document_Modelli_MicroLotti_Formula DF with(nolock) on DF.CriterioFormulazioneOfferte= b.criterioformulazioneofferte and b.TipoBando=DF.Codice and DF.deleted = 0 
		  -- recupera il modello utlizzato sui prodotti
		  left outer join CTL_DOC_SECTION_MODEL M with (nolock) on M.IdHeader = d.id and M.DSE_ID = 'PRODOTTI'
		  left join LIB_Dictionary LZ with (nolock) on Lz.DZT_Name='SYS_OFFERTA_PRESENZA_ESECUTRICI' 
		  --recupera il documento di ritiro offerta se esiste
	   	 left outer join CTL_DOC CR with(nolock) on CR.LinkedDoc=d.id and CR.TipoDoc='RITIRA_OFFERTA' and CR.Deleted=0

		 --RECUPERA IL FLAG CONSENTI_INVIO_FT 
		 left join CTL_DOC_Value FLAG with (nolock)  on FLAG.IdHeader=d.id and FLAG.DSE_ID='OFFERTA' and FLAG.DZT_Name='CONSENTI_INVIO_FT' and FLAG.Row=0 and  flag.value >= '0'
		  --RECUPERA IL OGGETTO JSON_DOMINI_CRITERI 
		 left join CTL_DOC_Value JSON_DOMINI_CRITERI with (nolock)  on JSON_DOMINI_CRITERI.IdHeader=b.idHeader and JSON_DOMINI_CRITERI.DSE_ID='CRITERI_TEC' and JSON_DOMINI_CRITERI.DZT_Name='JSON_DOMINI_CRITERI' and JSON_DOMINI_CRITERI.Row=0 
		 left join ctl_doc_value cobust with(nolock) on cobust.idheader = b.idheader and cobust.DSE_ID = 'PARAMETRI' and cobust.DZT_Name = 'ControlloFirmaBuste'

		 --Flag presenza Rettifica Offerta Tecnica
		 left join CTL_DOC RettTec with (nolock) on RettTec.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and RettTec.deleted = 0 and RettTec.LinkedDoc = d.id and RettTec.StatoFunzionale = 'Inviato' and SUBSTRING(RettTec.JumpCheck, 3, LEN(RettTec.JumpCheck) - 2) = 'RETTIFICA_TECNICA_OFFERTA'
			 
		 --Flag presenza Rettifica Offerta Economica
		 left join CTL_DOC RettEco with (nolock) on RettEco.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and RettEco.deleted = 0 and RettEco.LinkedDoc = d.id and RettEco.StatoFunzionale = 'Inviato' and SUBSTRING(RettEco.JumpCheck, 3, LEN(RettEco.JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
			 
		 --Flag Attivazione Rettifica Offerta
		 left join CTL_Parametri FlagRettifica with (nolock) on FlagRettifica.Contesto='CERTIFICATION' and FlagRettifica.Oggetto='certification_req_33245' and FlagRettifica.Proprieta = 'Visible'
		
		 ----Accedo al doc della commissione
		 --left join CTL_DOC Commissione with (nolock) on d.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'

		 ----IdPfu Presidente Commissione Tecnica
		 --left join Document_CommissionePda_Utenti CommTec with(nolock) on Commissione.id = CommTec.IdHeader and CommTec.RuoloCommissione = 15548 and CommTec.TipoCommissione = 'G'

		 ----IdPfu Presidente Commissione Economica
		 --left join Document_CommissionePda_Utenti CommEco with(nolock) on Commissione.id = CommEco.IdHeader and CommEco.RuoloCommissione = 15548 and CommEco.TipoCommissione = 'C'












GO
