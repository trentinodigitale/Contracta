USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_DATI_LOTTO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[SITAR_DATI_LOTTO] as

	select 
			C.Linkeddoc as idPDA , 
			L.numerolotto  , 
			--'1' as W3MOD_IND ,
			s2.modo_indizione as W3MOD_IND,

			W3IMPR_AMM , 
			W3IMPR_OFF , 
			convert( varchar(19) , c.datainvio , 126  ) as W3DVERB , 
			convert( varchar(19) , B.datascadenzaofferta ,  126 ) as W3DSCAPO ,
			ltrim( str(  isnull( cast( impAggM.value as float ) , l.Importo  )    , 25 , 2 ) ) as W3IMP_AGGI , --Importo di aggiudicazione
			ltrim( str( LP.ValoreImportoLotto , 25 , 2 ) ) as W3I_SUBTOT ,
			convert( varchar(19) , c.datainvio , 126  ) as W9APDATA_STI , -- da recuperare, temporaneamente è la data di invio della comunicazione

			'false' as W3PROCEDUR , -- E' stata utilizzata la procedura accelerata? ( da fare capire )
			'false' as W3PREINFOR , -- E' stata effettuata la preinformazione? ( da fare capire )
			'false' as W3TERMINE , -- E' stato utilizzato il termine ridotto? ( da fare capire ) 

			case 
				when B.Richiesta_terna_subappalto = '1' then 'true'
				else 'false'
				end W3FLAG_RIC , -- L'affidatario ha richiesto di subappaltare ( da fare capire ) 
			'false' as W9APOUSCOMP , -- Opere di urbanizzazione a scomputo? ( da fare capire ) 
			'' as W3COD_STRU ,-- Codice dello strumento di programmazione ( da fare capire ) 
			'B' as W3ID_FINAN , --Fondi di bilancio dell'amministrazione competente

			--ltrim( str( ((( LP.ValoreImportoLotto - l.Importo ) / LP.ValoreImportoLotto ) * 100 ) , 25 , 2 ))  
			--CASE WHEN ValoreSconto < 0 THEN 0 ELSE ValoreSconto END as W3PERC_RIB

			case when isnull( cast( impAggM.value as float ) , l.Importo  ) <= lp.VALORE_BASE_ASTA_IVA_ESCLUSA 
				
				then 100 - ( isnull( cast( impAggM.value as float ) , l.Importo  ) / lp.VALORE_BASE_ASTA_IVA_ESCLUSA ) * 100
				else null 

			END as W3PERC_RIB
			,

			--se si è superato il valore a base d'asta, passiamo questo nuovo tag 'W3PERC_OFF' contenente la percentuale di rialzo
			--case when l.Importo > b.ImportoBaseAsta2 then ltrim( str( (((  l.Importo - b.ImportoBaseAsta2 ) / b.ImportoBaseAsta2 ) * 100 ) , 25 , 2 ))  else NULL end as W3PERC_OFF, -- Offerta in aumento %

			case when isnull( cast( impAggM.value as float ) , l.Importo  ) > lp.VALORE_BASE_ASTA_IVA_ESCLUSA 
					then ltrim( 
								str( 
										case when (((  isnull( cast( impAggM.value as float ) , l.Importo  ) - lp.VALORE_BASE_ASTA_IVA_ESCLUSA ) / lp.VALORE_BASE_ASTA_IVA_ESCLUSA ) * 100 ) > 100 
													then 100 
													else (((  isnull( cast( impAggM.value as float ) , l.Importo  ) - lp.VALORE_BASE_ASTA_IVA_ESCLUSA ) / lp.VALORE_BASE_ASTA_IVA_ESCLUSA ) * 100 )	end


									  , 25 , 2 
								    )
								)  
					else NULL 
				end 
			 
			 as W3PERC_OFF, -- Offerta in aumento %


			--'99.9' as W3OFFE_MAX ,
			--'99.9' as W3OFFE_MIN ,
			case when W3OFFE_MAX < 0 then 0 else W3OFFE_MAX end W3OFFE_MAX ,
			case when W3OFFE_MIN < 0 then 0 else W3OFFE_MIN end W3OFFE_MIN  ,

			'0' as W9APDURACCQ ,

			--ltrim( str( isnull( cast( impAggM.value as float ) , l.Importo  ) , 25 , 2 ) ) as W3I_FINANZ,
			--mettiamo il valore base asta del lotto ( tecnicamente possiamo prendere valoreimportolotto preso dalla gara )
			ltrim( str( lp.ValoreImportoLotto , 25 , 2 ) ) as W3I_FINANZ,

			b.ImportoBaseAsta2 as baseAstaGara,
			lp.VALORE_BASE_ASTA_IVA_ESCLUSA as baseAstaLotto,
			isnull( cast( impAggM.value as float ) , l.Importo  ) as importoOfferto


		from CTL_DOC C with(nolock) 
			--inner join Document_comunicazione_StatoLotti L with(nolock) on L.idheader = C.Id  and l.deleted = 0 
			inner join (

							select idheader, NumeroLotto , min(Importo) as Importo 
								from Document_comunicazione_StatoLotti l1 with(nolock)
								where l1.Deleted = 0
								group by l1.IdHeader, l1.NumeroLotto

						) L ON L.idheader = C.Id 

			-- W3MOD_IND Modalità di indizione della gara TABELLATO W3008  

			-- W3IMPR_AMM Numero offerte ammesse NUMERO
			inner join ( select o.idheader as idPDA , d.NumeroLotto ,  count(*) as W3IMPR_AMM    
							, max( case when StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  then ValoreSconto else null end ) as W3OFFE_MAX
							, min( case when StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  then ValoreSconto else null end ) as W3OFFE_MIN

							from document_PDA_OFFERTE o with(nolock)
								inner join document_microlotti_dettagli d with(nolock) on d.idheader = o.idrow and d.voce = 0 and d.tipodoc = 'PDA_OFFERTE'
							where o.StatoPDA in ( '2' , '22' , '222' ) 
							group by o.idheader  , d.NumeroLotto
						) as IA on IA.idPDA = C.Linkeddoc and IA.Numerolotto = L.numerolotto 
		
			--W3IMPR_OFF Numero imprese che hanno presentato offerta NUMERO
			inner join ( select o.idheader as idPDA , d.NumeroLotto ,  count(*) as W3IMPR_OFF   
							from document_PDA_OFFERTE o with(nolock)
								inner join document_microlotti_dettagli d with(nolock) on d.idheader = o.idmsg and d.voce = 0 and d.tipodoc = 'OFFERTA'
							where o.statopda not in ( '99' , '999' )
							group by o.idheader  , d.NumeroLotto
						) as IM on IM.idPDA = C.Linkeddoc and IM.Numerolotto = L.numerolotto 

			inner join CTL_DOC P with(nolock) on P.ID = C.Linkeddoc
			inner join Document_bando B with(nolock) on B.idheader = P.linkeddoc

			inner join document_microlotti_dettagli LP with(nolock) on LP.idheader = C.Linkeddoc and LP.tipodoc = 'PDA_MICROLOTTI' and LP.voce = 0 and LP.numeroLotto =  L.numerolotto 

			--risaliamo alla graduatoria di aggiudicazione per gestire le gare con multi aggiudicazione ( in particolare per prendere l'importo. campo gestito come singolo lato sitar )
			left join ctl_doc magg with(nolock) on magg.linkeddoc = LP.id and magg.tipodoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and magg.deleted = 0 and magg.statofunzionale = 'Confermato'
			left join ctl_doc_value impAggM with(nolock) on impaggm.idheader = magg.id and impAggM.dse_id = 'IMPORTO' and impAggM.dzt_name = 'ImportoAggiudicatoInConvenzione'

			left join ctl_doc P2 with(nolock) on P2.tipodoc = 'PDA_MICROLOTTI' and P2.deleted = 0 and P2.ID = LP.idheader

			-- collega la procedura alla richiesta CIG del SIMOG se presente
			left join ctl_doc S with(nolock) on S.LinkedDoc = p2.LinkedDoc and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 
			left join Document_SIMOG_GARA s2 with(nolock) on s2.idHeader = S.Id

		where C.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' 
			and C.JumpCheck in (  '0-ESITO_DEFINITIVO' , '0-ESITO_DEFINITIVO_MICROLOTTI' ) 
			and c.statofunzionale = 'Inviato'


GO
