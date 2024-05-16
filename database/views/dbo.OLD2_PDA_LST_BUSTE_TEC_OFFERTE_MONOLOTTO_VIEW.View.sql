USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_LST_BUSTE_TEC_OFFERTE_MONOLOTTO_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_PDA_LST_BUSTE_TEC_OFFERTE_MONOLOTTO_VIEW] as  

	Select
		--o.*

		dp.id
		, do.StatoRiga
		, o.aziRagioneSociale
		, o.IdMsgFornitore
		, o.IdMsg
		, do.PunteggioTecnico
		, o.idAziPartecipante
		, do.id as IdRow
		, o.NumRiga
		, isnull( dof.id , do.idHeaderLotto ) as idHeaderLotto
		, case when ( isnull( BD.Value ,0) = 1 or isnull( v1.Value ,0) = 1 )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadDocumentazione
		, ReceivedDataMsg as DataInvio
		, ProtocolloOfferta as Protocollo
		, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( do.id  , 'TECNICA' ) as Motivazione
		,dp.idheader
		,do.PunteggioTecnicoRiparCriterio
		,do.PunteggioTecnicoRiparTotale
		,do.PunteggioTecnicoAssegnato


		--,dbo.get_APERTURA_BUSTE_FROM_LOTTO_TEC (pda.id) as APERTURA_BUSTE_TECNICHE
		, coalesce(CEco.UtenteCommissione,CU.UtenteCommissione,0) as PresAgg

	 from 
		--PDA_LST_BUSTE_TEC_OFFERTE_VIEW o
		

		Document_MicroLotti_Dettagli dp with(nolock)

			inner join Document_PDA_OFFERTE o with(nolock) on dp.idheader = o.idheader

			-- recupero l'offerta del fornitore
			inner join Document_MicroLotti_Dettagli do with(nolock) on o.idrow = do.idheader and do.TipoDoc ='PDA_OFFERTE' and do.Voce = 0 and do.NumeroLotto = dp.NumeroLotto 
		
			-- prendo il dettaglio offerto dal fornitore
			left outer join Document_MicroLotti_Dettagli dof with(nolock) on o.IdMsgFornitore = dof.idheader and 
														( (dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA') or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
															and dof.Voce = 0 and dof.NumeroLotto = dp.NumeroLotto


			-- recupera l'evidenza di lettura del documento
			left outer join CTL_DOC_VALUE BD with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
			left outer join CTL_DOC_VALUE v1 with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 


			inner join ctl_doc pda with(nolock) on pda.id = o.idheader and pda.tipodoc='PDA_Microlotti'
			inner join document_bando bando with(nolock) on pda.linkeddoc = bando.idheader and bando.divisione_lotti = '0'
			inner join ctl_doc COM with(nolock) on COM.linkeddoc=bando.idHeader and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
			left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
			left outer join Document_CommissionePda_Utenti CEco with(nolock) on COM.id=CEco.idheader and CEco.TipoCommissione='C' and CEco.ruolocommissione='15548'

		
		where dp.TipoDoc ='PDA_MICROLOTTI' and  dp.Voce = 0  


GO
