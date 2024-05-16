USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_MICROLOTTI_LST_LOTTI_TEC_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[PDA_MICROLOTTI_LST_LOTTI_TEC_VIEW] as 

	--select lo.* , NumeroOfferte
	--	from CTL_DOC C  with (nolock) -- PDA

	--		inner join ctl_doc b  with (nolock) on b.id = C.linkeddoc -- BANDO
	--		inner join document_bando ba  with (nolock) on  ba.idheader = b.id
	--		inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc and lb.Voce = 0
	--		inner join document_microlotti_dettagli lo with (nolock) on C.id = lo.idheader and lo.tipodoc = 'PDA_MICROLOTTI' and lb.Voce = lo.Voce and lb.NumeroLotto = lo.NumeroLotto 
			
	--		left outer join Document_Microlotti_DOC_Value v1  with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
	--		left outer join Document_Microlotti_DOC_Value v2  with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			
	--		left outer join ( select count( * ) as NumeroOfferte , id from PDA_LST_BUSTE_TEC_OFFERTE_VIEW group by id ) as cnt on cnt.id = lo.id 

	--		where C.TipoDoc = 'PDA_MICROLOTTI' 
	--				and ( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532'  or isnull( v2.Value , Conformita ) = 'Ex-Ante'  )



	select lo.* , NumeroOfferte  

			from CTL_DOC C  with (nolock) -- PDA

				inner join ctl_doc b  with (nolock) on b.id = C.linkeddoc -- BANDO
				inner join document_bando ba  with (nolock) on  ba.idheader = b.id
				inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc and lb.Voce = 0
				inner join document_microlotti_dettagli lo with (nolock) on C.id = lo.idheader and lo.tipodoc = 'PDA_MICROLOTTI' and lb.Voce = lo.Voce and lb.NumeroLotto = lo.NumeroLotto 
			
				left outer join Document_Microlotti_DOC_Value v1  with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
				left outer join Document_Microlotti_DOC_Value v2  with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			

				--left outer join ( select count( * ) as NumeroOfferte , id from PDA_LST_BUSTE_TEC_OFFERTE_VIEW group by id ) as cnt on cnt.id = lo.id 

				-- recupero le offerte ricevute per lotto
				left join (
							select po.idheader , o.NumeroLotto,  count(*) as  NumeroOfferte
								from document_pda_offerte po with(nolock) 
									inner join document_microlotti_dettagli o with (nolock) on po.idrow = o.idheader and o.tipodoc = 'PDA_OFFERTE' and o.voce = 0 --lb.Voce = o.Voce  and lb.NumeroLotto = o.NumeroLotto 
								group by po.idheader , o.NumeroLotto
						) as po on po.idheader = lo.idheader and lb.NumeroLotto = po.NumeroLotto 

			where C.TipoDoc = 'PDA_MICROLOTTI' 
						and ( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532' or isnull( v1.Value , CriterioAggiudicazioneGara ) = '25532'  or isnull( v2.Value , Conformita ) = 'Ex-Ante'  )



			


GO
