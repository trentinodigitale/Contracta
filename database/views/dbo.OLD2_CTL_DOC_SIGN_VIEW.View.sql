USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CTL_DOC_SIGN_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_CTL_DOC_SIGN_VIEW] as

	select 
		d.* ,
		s.* , 
		b.ClausolaFideiussoria , 
		isnull( numLotti , 0 ) as numLotti ,
		isnull( numFirme , 0 ) as numFirme ,
		b.TipoBandoGara as TB , 
		b.ProceduraGara as PG ,
		b.TipoBandoGara , 
		b.ProceduraGara ,
		case when ProceduraGara = '15477' and TipoBandoGara = '2'   then 'Domanda di partecipazione'
			 when ProceduraGara ='15583' and TipoBandoGara in ('4','5') then 'Risposta avviso'
			else ''
			end as CaptionDoc ,
		case when getdate() > DataScadenzaOfferta  then '1' else '0' end as DATA_INVIO_SUPERATA ,
		case when d.RichiestaFirma = 'si' AND ( F1_SIGN_LOCK <> 0 or F2_SIGN_LOCK <> 0 or F3_SIGN_LOCK <> 0 or F4_SIGN_LOCK <> 0 or isnull( numFirme , 0 ) <> 0   )
			then 1
			else 0
		end as FIRMA_IN_CORSO,
	
		case when 
		(
			(
				(
					( 
						-- è presente la firma della busta economica se presente
						(
							--( Conformita = 'Ex-Ante' or  CriterioAggiudicazioneGara = '15532' ) -- la presenza della conformità oppure economicamente vantggiosa
						
							( 
								Divisione_lotti <> '0'		-- prevede che ci siano le firme dei singoli lotti solo nel caso non sia una gara informale
								and 
								not (  ProceduraGara='15583' or ProceduraGara='15479' ) --AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO
							)
							or
								F1_SIGN_ATTACH <> '' 
						
						)
						--and 
						--( 
						--	-- è presente la firma della clausola se prevista
						--	F2_SIGN_ATTACH <> '' 
						--	or  
						--	ClausolaFideiussoria = '0' 
						--)
					) 
					and 
					( 
					
						-- sono state firmate le singole buste se previste
						--( Conformita <> 'Ex-Ante' and  CriterioAggiudicazioneGara <> '15532' )
						--or 
						--( isnull( numLotti , '' ) = isnull( numFirme , 0 )  and isnull( numLotti , 0 ) > 0 )
						( isnull( numFirme , 0 )  > 0  and isnull( numLotti , 0 ) > 0 )
						or
						Divisione_lotti = '0' 
						or 
						( ProceduraGara='15583' or ProceduraGara='15479' ) --AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO
					
					
					)
					and
					(
						-- la monolotto richiede la firma della tecnica
						( 
							( Divisione_lotti = '0' or ProceduraGara='15583' or ProceduraGara='15479'  ) -- senza lotti oppure AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO)
							and 
							isnull( F3_SIGN_ATTACH , '' ) <> '' 
						) 
						or 
						(	
							( Divisione_lotti = '0' or ProceduraGara='15583' or ProceduraGara='15479'  ) -- senza lotti oppure AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO)
							and 
							CriterioAggiudicazioneGara not in ('15532','25532') 
							and  Conformita = 'No' 
						
						) 
						or 
						(
							--Divisione_lotti <> '0' 
							Divisione_lotti <> '0'		-- si esclule la presenza della busta tecnica nel caso delle gare a lotti ma solo se non è una gara informale
							and 
							not (  ProceduraGara='15583' or ProceduraGara='15479' ) --AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO
						)
				
					)
				)  
			
				and 
				d.RichiestaFirma = 'si' 

				--ci devono essere lotti (anche per quelli non a lotti almeno 1)
				--and 
				-- isnull( numLotti , 0 ) > 0 

			) 

			or 
		
			--se la firma non è richiesta oppure sono nel caso delle ristrette-bando
			( 
				( 
				
					--RichiestaFirma = 'no' 
					--ci devo essere lotti anche se non richiesta la firma
					( d.RichiestaFirma = 'no' and isnull( numLotti , 0 ) > 0 )
					or  
					(  
						b.ProceduraGara = '15477' and b.TipoBandoGara = '2'   --Ristretta , Bando
					) 
					or 
						b.TipoBandoGara in ('1','4','5') --se avviso, avviso aperto, avviso con destinatari

				)  

			) 
		)

		--and 
	
		--   getdate() <= DataScadenzaOfferta 
	
		and 
		   d.StatoFunzionale = 'InLavorazione' 
    
		 and 
		   d.StatoDoc = 'Saved' 
    
		 and isnull(err_rti.value,'') <> '1'

		-- condizione usata sulla tolbar prima della modifica
		--(((( F1_SIGN_ATTACH <> '' and ( F2_SIGN_ATTACH <> '' or  ClausolaFideiussoria = '0' )) or ( numLotti = numFirme and numLotti > '0' ))  and StatoDoc = 'Saved' and RichiestaFirma = 'si' ) or ( IsReadOnly() = 'false' and  ( RichiestaFirma = 'no' or  (  PG = '15477' and TB = '2'   ) )  ) )
			then '1'
			else '0'
			end as CAN_SEND
			,cv.Value as PresenzaDGUE
			,ISNULL(CR.id,0) as id_ritira_offerta
			,ISNULL(sys1.DZT_ValueDef,'SI') as Ritira_offerta_Attivo 

			,case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled

			--, isnull(amb.value,'') as Ambito

			, case when m1.ma_id is null then '0' else '1' end as PresenzaAIC
			

			,case when ISNULL(b.DataScadenzaOfferta,getdate()) > getdate() then 1 else 0 end  as CAN_RITIRA_OFF
			,ISNULL(FLAG.value,0) as CONSENTI_INVIO_FT 

			,isnull(err_rti.value,'') as	Error_Associazione_RTI

			, case when
				F1_SIGN_ATTACH <> '' and ( F2_SIGN_ATTACH <> '' or  ClausolaFideiussoria = '0' ) then '1'
				else '0' end as CONDITION_1
			, b.Divisione_lotti

			--FLAG RETTIFICA OFFERTA
			,isnull(RettEco.id,0) as RettificaOffertaEco
			,isnull(RettTec.id,0) as RettificaOffertaTec
			,case
				when GETDATE() >= b.DataScadenzaOfferta 
					then 'si'
					else 'no'
				end as FlagDataScadenzaOfferta
			,case
				when isnull(FlagChiusaEco.APS_ID_ROW,0) = 0
					then 'no'
					else 'si'
				end as FlagChiusaValutazioneEco
			,case
				when isnull(FlagChiusaTec.APS_ID_ROW,0) = 0 
					then 'no'
					else 'si'
				end as FlagChiusaValutazioneTec
			,dbo.PARAMETRI('CERTIFICATION','certification_req_33245','Visible','0',-1) as FlagRettifica
			--,isnull(FlagRettifica.Valore,0) as FlagRettifica
		
			
			--FINE FLAG RETTIFICA OFFERTA

			,case when ISNULL(sys3.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_DM_Enabled
		,case 
			--se nel modello presente attributo CODICE_EAN oppure gli attributi CODICE_ARTICOLO_FORNITORE e NumeroRepertorio
			when ( M2.ma_id is not null  )
					--and isnull(pp.Valore ,'') = '1'  left join CTL_Parametri pp with (nolock) on pp.Contesto = 'OFFERTA' and pp.Oggetto = 'PRODOTTI' and pp.Proprieta = 'DM_ACTIVE'
					and dbo.PARAMETRI('OFFERTA','PRODOTTI','DM_ACTIVE','',-1) = '1'
						then '1' 
			else '0' 
		 end as PresenzaDM

		from ctl_doc d with (nolock)

			left outer join ctl_doc_sign s with (nolock)on id = idheader
			left outer join Document_Bando  b with (nolock) on d.LinkedDoc = b.idHeader

			left outer join ( 
		
				-- recupero il numero di Lotti firmati
				select D.idHeader , count(*) as numLotti , sum( 
								case when 
										(
											-- se la busta tecnica è firmata
											 ISNULL(DF.F2_SIGN_ATTACH,'') <> ''
											or
											-- non è necessaria la busta tecnica ( prezzo senza conformità
											( isnull( v1.Value , CriterioAggiudicazioneGara ) <> '15532' and  isnull( v1.Value , CriterioAggiudicazioneGara ) <> '25532'  and isnull( v2.Value , Conformita ) = 'No' ) 
										)
										-- la busta economica è sempre necessaria
										and ISNULL(DF.F1_SIGN_ATTACH,'') <> ''
														
								then 1 else 0 end ) as numFirme  
					from dbo.Document_MicroLotti_Dettagli D with (nolock)
						left outer join Document_Microlotto_Firme DF with (nolock) on DF.IdHEader=D.id
					
						inner join CTL_DOC C with (nolock) on C.id = D.idheader -- Offerta
						inner join ctl_doc b with (nolock) on b.id = C.linkeddoc -- BANDO
						inner join document_bando ba with (nolock) on  ba.idheader = b.id

						inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc and lb.Voce = D.Voce and lb.NumeroLotto = D.NumeroLotto 
						left outer join Document_Microlotti_DOC_Value v1 with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
						left outer join Document_Microlotti_DOC_Value v2 with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
					

						where d.TipoDoc = 'OFFERTA' and D.Voce = 0
					group by D.idHeader
			
			
				) as F on F.idHeader = d.id and d.TipoDoc = 'OFFERTA'

			left join CTL_DOC_Value CV with (nolock) on CV.IdHeader=d.LinkedDoc and cv.DSE_ID='DGUE' and cv.DZT_Name='PresenzaDGUE'
			--recupera il documento di ritiro offerta se esiste
			left outer join CTL_DOC CR with (nolock) on CR.LinkedDoc=d.id and CR.TipoDoc='RITIRA_OFFERTA' and CR.Deleted=0
			--RECUPERA LA SYS_ATTIVA_RITIRA_OFFERTA
			left join LIB_Dictionary sys1 with (nolock) on sys1.DZT_Name='SYS_ATTIVA_RITIRA_OFFERTA'
			--RECUPERA IL FLAG CONSENTI_INVIO_FT 
			 left join CTL_DOC_Value FLAG with (nolock)  on FLAG.IdHeader=d.id and FLAG.DSE_ID='OFFERTA' and FLAG.DZT_Name='CONSENTI_INVIO_FT' and FLAG.Row=0 and  flag.value >= '0'
			 --RECUPERA IL FLAG Errore_Associazione_RTI per l'offerta 
			 left outer join CTL_DOC_Value err_rti with (nolock) on err_rti.IdHeader=d.id and err_rti.DSE_ID='RTI' and err_rti.DZT_Name='Errore_Associazione_RTI' and err_rti.Row=0   
			 --RECUPERA LA SYS_AIC_URL_PAGE
			left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
			--RECUPERA LA SYS_AIC_URL_PAGE
			left join LIB_Dictionary sys3 with (nolock) on sys3.DZT_Name='SYS_DM_URL_PAGE'
			-- verifica se nel modello c'è la colonna AIC
			left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = d.id and x.DSE_ID = 'PRODOTTI'
			left outer join CTL_ModelAttributes M1  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on m1.MA_MOD_ID = x.MOD_Name and m1.MA_DZT_Name = 'CodiceAIC'
			left outer join CTL_ModelAttributes M2  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on m2.MA_MOD_ID = x.MOD_Name and m2.MA_DZT_Name = 'NumeroRepertorio' -- in ( 'CODICE_REGIONALE' ,'NumeroRepertorio')
			-- ambito
			--left outer join CTL_DOC_Value amb with (nolock) on amb.IdHeader=d.LinkedDoc and amb.DSE_ID='TESTATA_PRODOTTI' and amb.DZT_Name='Ambito'

			--RETTIFICA OFFERTA
			 --Flag presenza Rettifica Offerta Tecnica
			 left join CTL_DOC RettTec with (nolock) on RettTec.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and RettTec.deleted = 0 and RettTec.LinkedDoc = d.id and RettTec.StatoFunzionale = 'Inviato' and SUBSTRING(RettTec.JumpCheck, 3, LEN(RettTec.JumpCheck) - 2) = 'RETTIFICA_TECNICA_OFFERTA'
			 
			 --Flag presenza Rettifica Offerta Economica
			 left join CTL_DOC RettEco with (nolock) on RettEco.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and RettEco.deleted = 0 and RettEco.LinkedDoc = d.id and RettEco.StatoFunzionale = 'Inviato' and SUBSTRING(RettEco.JumpCheck, 3, LEN(RettEco.JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
			 
			 --Accedo alla PDA
			 left join CTL_DOC PDA with (nolock) on PDA.linkeddoc = d.linkeddoc and PDA.tipodoc = 'PDA_MICROLOTTI' and PDA.deleted = 0
			 
			 --Flag di Chiusa Valutazione Economica
			 left join CTL_APPROVALSTEPS FlagChiusaEco with (nolock) on FlagChiusaEco.aps_ID_DOC = PDA.ID and FlagChiusaEco.APS_State in ('Termina Valutazione Economica','Termina Valutazione Economica <Lotto N° 1>')

			 --Flag di Chiusa Valutazione Tecnica
			 left join CTL_APPROVALSTEPS FlagChiusaTec with (nolock) on FlagChiusaTec.aps_ID_DOC = PDA.ID and FlagChiusaTec.APS_State in ('Termina Valutazione Tecnica','Termina Valutazione Tecnica <Lotto N° 1>')

			 --Flag Attivazione Rettifica Offerta
			 --left join CTL_Parametri FlagRettifica with (nolock) on FlagRettifica.Contesto='CERTIFICATION' and FlagRettifica.Oggetto='certification_req_33245' and FlagRettifica.Proprieta = 'Visible'
			 -- FINE RETTIFICA OFFERTA --

			 --left join CTL_Parametri pp with (nolock) on pp.Contesto = 'OFFERTA' and pp.Oggetto = 'PRODOTTI' and pp.Proprieta = 'DM_ACTIVE'

GO
