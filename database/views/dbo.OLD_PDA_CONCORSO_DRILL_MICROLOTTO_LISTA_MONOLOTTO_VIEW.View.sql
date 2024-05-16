USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_CONCORSO_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[OLD_PDA_CONCORSO_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW] as

	select 	 
			m.id as IdRowLottoBando 


			--, o.aziRagioneSociale

			, case
				
				--i dati sono in chiaro
				when isnull(O_AN.Value,'') = '1'   then o.aziRagioneSociale
				
				--i dati NON sono ancora in chiaro
				else '' 

			  end AS aziRagioneSociale

			,od.*
			, case when isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) < 0 then null else isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) end as PunteggioEconomico
			, od.id as IdOffertaLotto	
			--, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( od.id , 'ECONOMICA' ) as Motivazione
			, o.idMsg 
			, o.TipoDoc as OPEN_DOC_NAME
			, d.id as idPDA

			, case when ( isnull( BD.Value ,'0') = '1' or isnull( v1.Value ,'0') = '1' )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bRead
			--, case when ( isnull( BD2.Value ,'0') = '1' or ( isnull( v2.Value ,'0') = '1'  and divisione_lotti = '0' ) ) and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadEconomica

			, cast( NumRiga as int ) as NumRiga
			, o.StatoPDA
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

				end as Ordinamento
			--,
				
			 -- case when pending.idOfferta is null then '' else 'PENDING' end as Stato_Firma_PDA_AMM
			  ,
			  R.Titolo as Progressivo_Risposta

			 ,
				case
					when isnull(od.Sorteggio ,0) =0 then
						case when isnull(od.ValoreImportoLotto ,0) <> 0 then '1' else '0'end
					
					when isnull(od.Sorteggio ,0) =1 then '1'

					else '0'
						

				end as AggiudicatarioLotto
		from 
			
			CTL_DOC d with(nolock)

				INNER JOIN Document_MicroLotti_Dettagli m with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI' AND m.voce = 0 
			
				--Document_MicroLotti_Dettagli m with(nolock)
				--inner join CTL_DOC d with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI'  --d.LinkedDoc = m.IdHeader
				--inner join ctl_doc gara with(nolock) on gara.id = d.linkeddoc

				--left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on c.idBando = gara.id and m.NumeroLotto = c.N_Lotto 

				inner join Document_Bando ba with (nolock) on d.LinkedDoc = ba.idHeader and ba.divisione_lotti = '0'
			
				inner join Document_PDA_OFFERTE o with(nolock) on d.id =  o.idheader

				inner join Document_MicroLotti_Dettagli od with(nolock) on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = m.NumeroLotto and od.voce = 0 -- o.IdMsgFornitore = od.idHeader and od.NumeroLotto = m.NumeroLotto
			
				left outer join aziende a with(nolock) on a.idazi = o.idAziPartecipante


				-- prendo il dettaglio offerto dal fornitore
				left outer join Document_MicroLotti_Dettagli dof with(nolock) on o.IdMsgFornitore = dof.idheader and 
															dof.TipoDoc ='RISPOSTA_CONCORSO' and o.TipoDoc = 'RISPOSTA_CONCORSO'
																and dof.Voce = 0 and dof.NumeroLotto = m.NumeroLotto
				
				--salgo sulla risposta per prendere progressivo risposta dal titolo
				left outer join CTL_DOC R with (nolock) on R.Id = o.IdMsgFornitore

				---- recupera l'evidenza di lettura del documento
				left outer join CTL_DOC_VALUE BD with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'RISPOSTA_CONCORSO' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
				left outer join CTL_DOC_VALUE v1 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'RISPOSTA_CONCORSO' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 

			
				--left join ( 
				--			select da.LinkedDoc as idOfferta 
				--				from ctl_doc da with(nolock)
				--						inner join Document_Offerta_Allegati al with(nolock) on al.Idheader = da.Id and al.SectionName = 'ECONOMICA' and al.statoFirma = 'SIGN_PENDING'
				--				where da.tipodoc = 'OFFERTA_ALLEGATI' and da.Deleted = 0
				--				group by LinkedDoc
		
				--		) pending on pending.idOfferta = o.IdMsg
				
				left join ctl_doc_value O_AN with(nolock) on O_AN.idheader = d.linkeddoc and O_AN.DSE_ID = 'ANONIMATO' and O_AN.DZT_Name = 'DATI_IN_CHIARO'  and O_AN.Row=0

		where d.tipodoc='PDA_CONCORSO' and d.deleted = 0 

		








GO
