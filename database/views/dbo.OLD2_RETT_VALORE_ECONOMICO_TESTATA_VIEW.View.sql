USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_RETT_VALORE_ECONOMICO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_RETT_VALORE_ECONOMICO_TESTATA_VIEW] as
	
	select R.* ,l.CIG , l.NumeroLotto , l.Descrizione,b.Divisione_lotti
		from ctl_doc R 
			inner join Document_MicroLotti_Dettagli l on l.id=r.LinkedDoc and l.tipodoc='PDA_OFFERTE'
			left join document_pda_offerte O on O.idrow=l.idheader
			left join ctl_doc PDA on PDA.id=O.idheader
			left join document_bando B on B.idheader=PDA.linkeddoc
	where R.tipodoc='RETT_VALORE_ECONOMICO'

	


GO
