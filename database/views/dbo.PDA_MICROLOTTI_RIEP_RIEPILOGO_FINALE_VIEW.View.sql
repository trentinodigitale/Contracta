USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_MICROLOTTI_RIEP_RIEPILOGO_FINALE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[PDA_MICROLOTTI_RIEP_RIEPILOGO_FINALE_VIEW] as
select 
				
			m.idheader as idDoc 
			, cast( m.NumeroLotto as int ) as Ordinamento 
			
			, case 
				when m.StatoRiga = 'OffertaMigliorativa'		then 'Offerta Migliorativa'
				when m.StatoRiga in ( 'Valutato' , 'completo' ) then 'Da Valutare Economicamente'
				when m.StatoRiga = 'daValutare'					then 'Da Valutare'
				when m.StatoRiga = 'InValutazione'				then 'In Valutazione Tecnica'
				when m.StatoRiga = 'NonGiudicabile'				then 'Non Giudicabile'
				when m.StatoRiga = 'Interrotto'					then 'Interrotto'
				when m.StatoRiga = 'GiustificazionePrezzi'		then 'Giustificazione Prezzi'
				when m.StatoRiga = 'NonAggiudicabile'			then 'Non Aggiudicabile'
				when m.StatoRiga = 'Revocato'					then 'Revocato'
				when m.StatoRiga = 'VerificaAnomalia'			then 'Verifica Anomalia'
				when m.StatoRiga = 'PercAggiudicazione'			then 'Determinazione Idoneità'

				--when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( TipoAggiudicazione , 'monofornitore' ) in (  'monofornitore' , '' ) and m.Aggiudicata <> 0	then aziRagioneSociale 
				--when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 	then dbo.CNV_ESTESA(  'Aggiudicatari multipli' , 'I' ) 
				
				when m.StatoRiga in ( 'AggiudicazioneDef'	)  then 'Aggiudicazione Definitiva' 
				when m.StatoRiga in ( 'AggiudicazioneProvv' )  then 'Aggiudicazione Proposta'
				when m.StatoRiga in ( 'AggiudicazioneCond'  )  then 'Aggiudicazione Definitiva Condizionata'
				when m.StatoRiga in ( 'Controllato'			)  then 'Controllato' 


				--when Exequo = 0 and m.Aggiudicata <> 0			then aziRagioneSociale 
				--when m.Aggiudicata = 0 and  Exequo = 0	and isnull( ba.TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' )	then 'Nessuna Offerta Conforme' 

				when m.Aggiudicata = 0 and  m.Exequo = 0	and isnull( CVL.TipoAggiudicazione , ba.TipoAggiudicazione ) not in (  'monofornitore' , '' )	then 'Nessuna Offerta Conforme' 
				when m.Aggiudicata is null and  m.Exequo is null and isnull( NumOfferte , 0 ) = 0 then 'Deserta' 
				when m.Aggiudicata is null and  m.Exequo is null and isnull( NumOfferte , 0 ) > 0 then 'Non Aggiudicabile'  
				
				--else 'Exequo' 
				else 'Ex aequo' 
				end as Stato_Aggiudicatario

			, case 
				--when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( ba.TipoAggiudicazione , 'monofornitore' ) in (  'monofornitore' , '' ) and m.Aggiudicata <> 0	then aziRagioneSociale 
				--when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( ba.TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 	then 'Aggiudicatari multipli' --dbo.CNV_ESTESA(  'Aggiudicatari multipli' , 'I' ) 
				when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( CVL.TipoAggiudicazione , ba.TipoAggiudicazione ) in (  'monofornitore' , '' ) and m.Aggiudicata <> 0	then aziRagioneSociale 
				when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( CVL.TipoAggiudicazione , ba.TipoAggiudicazione ) not in (  'monofornitore' , '' ) 	then 'Aggiudicatari multipli' --dbo.CNV_ESTESA(  'Aggiudicatari multipli' , 'I' ) 
				else '' 
			  end as aziRagioneSociale,
			
				m.id,
				m.idheader,
				
				m.tipodoc,
				m.StatoRiga,
				m.NumeroLotto,
				m.voce,
				m.Exequo,
				--ISNULL(m.cig,ba.cig) as cig,
				-- Se non presenti sulla PDA li recupero dalla gara perchè con la PCP sulla PDA 
				-- per gli AD ( affidamenti diretti ) sono vuoti in quanto il cig viene recuperato
				-- sulla PDA in seguito
				case
					when isnull(Divisione_lotti,'0')='0' then 
						case when ISNULL(m.cig,'')='' then ba.cig
							else m.cig
						end 
					else
						case when ISNULL(m.cig,'')='' then DB.cig
							else m.cig
						end 					
				end as cig,

				m.descrizione,
				m.ValoreImportoLotto,
				NumOfferte as NumeroOfferte
							

		from Document_MicroLotti_Dettagli m with(nolock) 

			left outer join ( select count(*) NumOfferte , o.NumeroLotto , d.idheader 
									from Document_PDA_OFFERTE d with(nolock) 
										inner join Document_MicroLotti_Dettagli o with(nolock) on d.idRow = o.idheader and o.TipoDoc = 'PDA_OFFERTE'
										where o.voce = 0
									group by o.NumeroLotto , d.idheader 
							) as d  on d.idheader =  m.idheader and d.NumeroLotto = m.NumeroLotto
			--inner join CTL_DOC d with(nolock) on d.LinkedDoc = m.idheader
			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata
			--left outer join ( select distinct id_Doc from CTL_DOC_READ with(nolock) where DOC_NAME = 'PDA_DRILL_MICROLOTTO' ) as r on id_Doc = m.id

			inner join ctl_doc pda with(nolock) on pda.id = m.IdHeader

			inner join Document_Bando ba with(nolock) on ba.idheader = pda.LinkedDoc
			
			

			--left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on ba.idHeader = c.idBando and m.NumeroLotto = c.N_Lotto

			inner join ctl_doc B with(nolock) on B.id = ba.idheader

			inner join document_microlotti_dettagli DB with (nolock) on DB.idheader =	B.id and db.tipodoc=B.tipodoc and db.voce=0 and isnull(db.numerolotto,1)= m.NumeroLotto

			--per recuperare TipoAggiudicazione del lotto
			left outer join  View_Criteri_Valutazione_Lotto CVL with (nolock) on  CVL.idheader = DB.id


		where m.TipoDoc = 'PDA_MICROLOTTI'
			and m.Voce = 0 
	

GO
