USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_BUSTE_DA_GENERARE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  view [dbo].[OFFERTA_BUSTE_DA_GENERARE] as


	select lotti.NumeroLotto, lotti.id, 'ECONOMICA' as Busta  , lotti.idheader
		from document_microlotti_dettagli lotti with (nolock) 
			inner join Document_Microlotto_Firme firme with (nolock) ON lotti.id = firme.idheader and firme.f1_sign_attach = '' 
	
		where lotti.TipoDoc = 'OFFERTA' and (lotti.EsitoRiga='<img src="../images/Domain/State_OK.gif">' or lotti.EsitoRiga like '%<img src="../images/Domain/State_Warning.gif">%'  )

union all

	select lo.NumeroLotto, lo.id, 'TECNICA' as Busta , lo.idheader 
		from CTL_DOC d -- offerta

			inner join ctl_doc b on b.id = d.linkeddoc -- BANDO
			inner join document_bando ba on  ba.idheader = b.id
			inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			inner join document_microlotti_dettagli lo with (nolock) on d.id = lo.idheader and lo.tipodoc = 'OFFERTA' and lb.Voce = lo.Voce and lb.NumeroLotto = lo.NumeroLotto 
			inner join Document_Microlotto_Firme firme with (nolock) ON lo.id = firme.idheader and firme.f2_sign_attach = '' 
			
			left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			left outer join Document_Microlotti_DOC_Value v2 on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			
			where d.TipoDoc = 'OFFERTA' and 
					( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532' or isnull( v1.Value , CriterioAggiudicazioneGara ) = '25532'  or isnull( v2.Value , Conformita ) <> 'No' ) --= "Ex-Ante"  
			and (lo.EsitoRiga='<img src="../images/Domain/State_OK.gif">'  or lo.EsitoRiga like '%<img src="../images/Domain/State_Warning.gif">%' )

union all

	select L.NumeroLotto, L.idHeaderLotto as id, 'AMPIEZZA_GAMMA' as Busta  , l.idheader
		from document_microlotti_dettagli l -- lotti offerti
		where l.tipodoc = 'OFFERTA_AMPIEZZA'  
			and (not l.EsitoRiga like '%State_ERR.gif"%'
			or l.EsitoRiga='<img src="../images/Domain/State_ERR.gif"><br><img src="../images/Domain/State_ERR.gif"><br>Il file pdf riepilogativo dell''ampiezza di gamma generato non è firmato digitalmente<br>' )

GO
