USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_DRILL_MICROLOTTO_LISTA_VIEW]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[PDA_DRILL_MICROLOTTO_LISTA_VIEW] AS

	select 	 m.id as IdRowLottoBando 
			, o.aziRagioneSociale
			,od.*
			, case when isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) < 0 then null else isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) end as PunteggioEconomico
			, od.id as IdOffertaLotto	
			, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( od.id , 'ECONOMICA' ) as Motivazione
			, o.idMsg 
			, o.TipoDoc as OPEN_DOC_NAME
			, d.id as idPDA

			, 
			case when isnull( cl1.value , CriterioAggiudicazioneGara ) in (  '15532' /*OEV*/ , '25532'  /*CostoFisso*/ ) or isnull( cl2.value, ba.Conformita ) <> 'No' 
						
				then
					case when ( isnull( BD.Value ,0) = 1 or isnull( v1.Value ,0) = 1 )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end 
				else	
					null
				end
				as bRead



			, case when ( isnull( BD2.Value ,0) = 1 or ( isnull( v2.Value ,0) = 1  and divisione_lotti = '0' ) ) and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadEconomica

			, cast( NumRiga as int ) as NumRiga

			,a.aziPartitaIVA
			,a.aziLocalitaLeg
			,a.aziE_Mail
			,m.ValoreImportoLotto as PrzBaseAsta
            ,od.ValoreSconto as PercentualeRibasso
			,od.ValoreRibasso as Ribasso		

			, case 
				
				when isnull( le.StatoLotto , '' ) = 'escluso' then '1'
				when isnull( le.StatoLotto , '' ) = 'ammesso' then '2'
				when isnull( le.StatoLotto , '' ) = 'AmmessoRiserva' then '22'
				
				else o.StatoPDA 

			  end as StatoPDA

			, ba.InversioneBuste
			, case 
				when m.StatoRiga in ( 'Completo' , 'Valutato' , 'daValutare' , 'InValutazione' ,    'SecondaFaseTecnica' , 'PrimaFaseTecnica' ) then '1'
				
				else
					case 					
						when  od.StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) then '1'
						when  od.StatoRiga in ( 'decaduta' ) then '2-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 ) , 20 , 5 ) + ']'
						when  od.StatoRiga in ( 'anomalo' , 'decaduta' ) then '3-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 )  , 20 , 5 ) + ']'
						when  od.StatoRiga  in ( 'esclusoEco' ,'escluso' , 'NonConforme' ) then '4-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 )  , 20 , 5 ) + ']'
						else '0'
					end

				end as Ordinamento,

				case when pending.idOfferta is null then '' else 'PENDING' end as Stato_Firma_PDA_AMM

		from Document_MicroLotti_Dettagli m with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI' --d.LinkedDoc = m.IdHeader
			inner join Document_Bando ba with(nolock) on d.LinkedDoc = ba.idHeader
			inner join Document_PDA_OFFERTE o with(nolock) on d.id =  o.idheader

			inner join Document_MicroLotti_Dettagli od with(nolock) on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = m.NumeroLotto and od.voce = 0 -- o.IdMsgFornitore = od.idHeader and od.NumeroLotto = m.NumeroLotto
			left outer join aziende a with(nolock) on a.idazi = o.idAziPartecipante


			-- prendo il dettaglio offerto dal fornitore
			left outer join Document_MicroLotti_Dettagli dof with(nolock) on o.IdMsgFornitore = dof.idheader and 
														( ( ( dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA' or dof.TipoDoc ='RISPOSTA_CONCORSO' and o.TipoDoc = 'RISPOSTA_CONCORSO')  ) or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
															and dof.Voce = 0 and dof.NumeroLotto = m.NumeroLotto


			---- recupera l'evidenza di lettura del documento
			left outer join CTL_DOC_VALUE BD with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc in ( 'OFFERTA','RISPOSTA_CONCORSO' ) and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
			left outer join CTL_DOC_VALUE v1 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc in ( 'OFFERTA','RISPOSTA_CONCORSO' ) and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 


			left outer join CTL_DOC_VALUE BD2 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD2.idHeader and BD2.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD2.DZT_Name = 'LettaBusta' and dof.id = BD2.row
			left outer join CTL_DOC_VALUE v2 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = v2.idHeader and v2.DSE_ID = 'BUSTA_ECONOMICA' and v2.DZT_Name = 'LettaBusta' 


			-- recupero i criteri del lotto se ci sono 
			inner join CTL_DOC bando with(nolock)  on bando.id =  ba.idHeader
			left outer join Document_MicroLotti_Dettagli bar with(nolock) on bar.idheader = bando.id and bar.tipoDoc = bando.TipoDoc and bar.NumeroLotto = m.NumeroLotto and bar.voce = 0 
			left outer join Document_Microlotti_DOC_Value cl1 with(nolock) on cl1.idheader = bar.id and cl1.dzt_name = 'CriterioAggiudicazioneGara' and cl1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			left outer join Document_Microlotti_DOC_Value cl2 with(nolock) on cl2.idheader = bar.id and cl2.dzt_name = 'Conformita' and cl2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'


			-- verifica una esclusione per il lotto
			left join ctl_doc e with(nolock) on e.LinkedDoc = o.IdMsg and e.IdDoc = d.id and e.TipoDoc='ESCLUDI_LOTTI' and e.StatoFunzionale = 'Confermato'
			left join Document_Pda_Escludi_Lotti le with(nolock) on le.IdHeader = e.id and le.NumeroLotto = m.NumeroLotto

			left join ( 
					select da.LinkedDoc as idOfferta,
							al.numeroLotto
						from ctl_doc da with(nolock)
								inner join Document_Offerta_Allegati al with(nolock) on al.Idheader = da.Id and al.SectionName = 'ECONOMICA' and al.statoFirma = 'SIGN_PENDING'
						where da.tipodoc = 'OFFERTA_ALLEGATI' and da.Deleted = 0
						group by da.LinkedDoc, al.numeroLotto

				) pending on pending.idOfferta = o.IdMsg and pending.numeroLotto = m.NumeroLotto

		where d.deleted = 0
			and m.voce = 0 







GO
