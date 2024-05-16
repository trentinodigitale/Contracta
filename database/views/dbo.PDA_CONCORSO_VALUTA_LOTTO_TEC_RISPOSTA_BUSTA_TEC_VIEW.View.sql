USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_CONCORSO_VALUTA_LOTTO_TEC_RISPOSTA_BUSTA_TEC_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[PDA_CONCORSO_VALUTA_LOTTO_TEC_RISPOSTA_BUSTA_TEC_VIEW] as 

		select v.id as idLottoOfferto , D.*
			from 
				CTL_DOC v
					inner join document_microlotti_dettagli S on v.linkedDoc = S.id
					--inner join document_microlotti_dettagli D on D.idheaderlotto = S.idheaderlotto and D.tipodoc = 'PDA_OFFERTE' and s.idheader = d.idheader

					inner join document_pda_offerte o on o.idrow = s.idHeader

					inner join CTL_DOC P on P.id = o.IdHeader
					inner join document_bando B on b.idHeader = P.LinkedDoc
					-- salgo sulla busta documentazione tecnica della risposta
					inner join 
						ctl_doc_allegati D with (nolock) on D.idHeader = O.IdMsgFornitore and D.DSE_ID ='DOCUMENTAZIONE_RICHIESTA_TECNICA'
					--left outer join CTL_DOC_VALUE rz on	rz.IdHeader = P.LinkedDoc and rz.DSE_ID = 'TESTATA_PRODOTTI' and rz.DZT_Name = 'RigaZero' and rz.Value = '1' 
			--where	
					--( b.Divisione_lotti = '0' and D.Voce <> 0 ) 
					--or	
					--( b.Divisione_lotti <> '0' )
					--or	
					--( b.Divisione_lotti = '0' and isnull( rz.Value , '0' ) = '1' ) 






GO
