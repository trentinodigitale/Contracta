USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_LISTA_MICROLOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_PDA_LISTA_MICROLOTTI_VIEW] as
select 
			--d.id as idDoc			
			m.idheader as idDoc 
			, cast( m.NumeroLotto as int ) as Ordinamento 
--			, m.id as Ordinamento 
--			, case when Exequo = 0 then a.aziRagioneSociale else 'Exequo' end as aziRagioneSociale
--,m.StatoRiga , NumOfferte
			--, case 
			--	when m.StatoRiga = 'OffertaMigliorativa'		then 'Offerta Migliorativa'
			--	when m.StatoRiga in ( 'Valutato' , 'completo' ) then 'Da Valutare Economicamente'
			--	when m.StatoRiga = 'daValutare'					then 'Da Valutare'
			--	when m.StatoRiga = 'InValutazione'				then 'In Valutazione Tecnica'
			--	when m.StatoRiga = 'NonGiudicabile'				then 'Non Giudicabile'
			--	when m.StatoRiga = 'Interrotto'					then 'Interrotto'
			--	when m.StatoRiga = 'GiustificazionePrezzi'		then 'Giustificazione Prezzi'
			--	when m.StatoRiga = 'NonAggiudicabile'			then 'Non Aggiudicabile'
			--	when m.StatoRiga = 'Revocato'					then 'Revocato'
			--	when m.StatoRiga = 'VerificaAnomalia'			then 'Verifica Anomalia'
			--	when m.StatoRiga = 'PercAggiudicazione'			then 'Determinazione Idoneità'
			--	--when Exequo = 0 and m.Aggiudicata <> 0			then aziRagioneSociale 
			--	--when m.Aggiudicata = 0 and  Exequo = 0	and isnull( RegoleAggiudicatari , '' ) = ''			then 'Nessuna Offerta Conforme'
			--	--when m.Aggiudicata = 0 and  Exequo = 0	and isnull( RegoleAggiudicatari , '' ) = 'tutti'	then 'Idoneità Determinata'
			--	when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( TipoAggiudicazione , 'monofornitore' ) in (  'monofornitore' , '' ) and m.Aggiudicata <> 0	then aziRagioneSociale 
			--	when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 	then dbo.CNV_ESTESA(  'Aggiudicatari multipli' , 'I' ) 
			--	when Exequo = 0 and m.Aggiudicata <> 0			then aziRagioneSociale 
			--	when m.Aggiudicata = 0 and  Exequo = 0	and isnull( TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' )	then 'Nessuna Offerta Conforme' 
			--	when m.Aggiudicata is null and  Exequo is null and isnull( NumOfferte , 0 ) = 0 then 'Deserta' 
			--	when m.Aggiudicata is null and  Exequo is null and isnull( NumOfferte , 0 ) > 0 then 'Non Aggiudicabile'  
				
			--	--else 'Exequo' 
			--	else 'Ex aequo' 
			--	end as aziRagioneSociale

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
				when m.Aggiudicata = 0 and  m.Exequo = 0	and isnull( ba.TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' )	then 'Nessuna Offerta Conforme' 
				when m.Aggiudicata is null and  m.Exequo is null and isnull( NumOfferte , 0 ) = 0 then 'Deserta' 
				when m.Aggiudicata is null and  m.Exequo is null and isnull( NumOfferte , 0 ) > 0 then 'Non Aggiudicabile'  
				
				--else 'Exequo' 
				else 'Ex aequo' 
				end as Stato_Aggiudicatario

			, case 
				when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( ba.TipoAggiudicazione , 'monofornitore' ) in (  'monofornitore' , '' ) and m.Aggiudicata <> 0	then aziRagioneSociale 
				when m.StatoRiga in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' ) and isnull( ba.TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 	then dbo.CNV_ESTESA(  'Aggiudicatari multipli' , 'I' ) 
				else '' 
				end as aziRagioneSociale
			--, m.* 
			,m.id,m.idheader,m.tipodoc,m.StatoRiga,m.NumeroLotto,m.voce,m.Exequo,
				--m.cig,
				ISNULL(m.cig,ba.cig) as cig,
			 m.descrizione,m.ValoreImportoLotto
			, case when isnull( id_Doc , 0  ) = 0 then 1 else 0 end as bRead
			,NumOfferte as NumeroOfferte
			
			--,c.num_criteri_eco 
			--,c.ValutazioneSoggettiva  

			,isnull( LOTTI.num_criteri_eco  , BANDO.num_criteri_eco ) as num_criteri_eco,
			
			isnull( LOTTI.ValutazioneSoggettiva  , BANDO.ValutazioneSoggettiva ) as ValutazioneSoggettiva


		from
			 Document_MicroLotti_Dettagli m with(nolock) 

				left outer join ( select count(*) NumOfferte , o.NumeroLotto , d.idheader 
									from Document_PDA_OFFERTE d with(nolock) 
										inner join Document_MicroLotti_Dettagli o with(nolock) on d.idRow = o.idheader and o.TipoDoc = 'PDA_OFFERTE'
										where o.voce = 0
									group by o.NumeroLotto , d.idheader 
							) as d  on d.idheader =  m.idheader and d.NumeroLotto = m.NumeroLotto

				--inner join CTL_DOC d with(nolock) on d.LinkedDoc = m.idheader
				left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata

				left outer join ( select distinct id_Doc from CTL_DOC_READ with(nolock) where DOC_NAME = 'PDA_DRILL_MICROLOTTO' ) as r on id_Doc = m.id

				inner join ctl_doc pda with(nolock) on pda.id = m.IdHeader
				
				inner join Document_Bando ba with(nolock) on ba.idheader = pda.LinkedDoc
				
				--left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on ba.idHeader = c.idBando and m.NumeroLotto = c.N_Lotto
				--invece di andare sulla vista che recupero le info dei lotti
				--andiamo direttamente in tabella dei dettagli del bando per prendere idlotto del bando
				inner join ctl_doc B with(nolock) on B.id = ba.idheader
				inner join document_microlotti_dettagli DB with (nolock) on DB.idheader =	B.id and db.tipodoc=B.tipodoc and db.voce=0 and isnull(db.numerolotto,1)= m.NumeroLotto

				left outer join (select COUNT(*) as num_criteri_eco,MAX(idheader) as IDLOTTO, MAX ( case when FormulaEconomica = 'Valutazione soggettiva' then 1 else 0 end ) as ValutazioneSoggettiva from [BANDO_GARA_CRITERI_ECO_RIGHE_VIEW] where TipoDoc = 'LOTTO' group by idHeader) LOTTI on LOTTI.IDLOTTO = DB.id --c.idlotto
				left outer join (select COUNT(*) as num_criteri_eco,MAX(idheader) as IDBANDO, MAX ( case when FormulaEconomica = 'Valutazione soggettiva' then 1 else 0 end ) as ValutazioneSoggettiva from [BANDO_GARA_CRITERI_ECO_RIGHE_VIEW] where TipoDoc <> 'LOTTO' group by idHeader) BANDO on BANDO.IDBANDO = ba.idheader

		where m.TipoDoc = 'PDA_MICROLOTTI'
			and m.Voce = 0 
		

GO
