USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_LST_BUSTE_TEC_OFFERTE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PDA_LST_BUSTE_TEC_OFFERTE_VIEW] as
 select 	dp.id
		, do.StatoRiga
		--, do.EsitoRiga as Motivazione
		, o.aziRagioneSociale
		, o.IdMsgFornitore
		, o.IdMsg
		, do.PunteggioTecnico
		, o.idAziPartecipante
		, do.id as IdRow
		, o.NumRiga
		-- riga del dettaglio lotto del fornitore
		, isnull( dof.id , do.idHeaderLotto ) as idHeaderLotto
		--, '1' as bReadDocumentazione 
		, case when ( isnull( BD.Value ,0) = 1 or isnull( v1.Value ,0) = 1 )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadDocumentazione
		, ReceivedDataMsg as DataInvio
		, ProtocolloOfferta as Protocollo
		, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( do.id  , 'TECNICA' ) as Motivazione
		,dp.idheader
		,do.PunteggioTecnicoRiparCriterio
		,do.PunteggioTecnicoRiparTotale
		,do.PunteggioTecnicoAssegnato
		,case when pending.idOfferta is null then '' else 'PENDING' end as Stato_Firma_PDA_AMM

	from Document_MicroLotti_Dettagli dp with(nolock , index(IX_Document_MicroLotti_Dettagli_Id_NumeroLotto) )
		inner join Document_PDA_OFFERTE o with(nolock , index( IX_Document_PDA_OFFERTE_IdHeader_TipoDoc ) ) on dp.idheader = o.idheader

		-- recupero l'offerta del fornitore
		inner join Document_MicroLotti_Dettagli do with(nolock index( icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc ) ) on o.idrow = do.idheader and do.TipoDoc ='PDA_OFFERTE' and do.Voce = 0 and do.NumeroLotto = dp.NumeroLotto 
		
		-- prendo il dettaglio offerto dal fornitore
		left outer join Document_MicroLotti_Dettagli dof with(nolock, index ( icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc) ) on o.IdMsgFornitore = dof.idheader and 
													( (dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA') or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
														and dof.Voce = 0 and dof.NumeroLotto = dp.NumeroLotto


		-- recupera l'evidenza di lettura del documento
		left outer join CTL_DOC_VALUE BD with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
		left outer join CTL_DOC_VALUE v1 with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 

		left join ( 
					select da.LinkedDoc as idOfferta,
							al.numeroLotto
						from ctl_doc da with(nolock)
								inner join Document_Offerta_Allegati al with(nolock) on al.Idheader = da.Id and al.SectionName = 'TECNICA' and al.statoFirma = 'SIGN_PENDING'
						where da.tipodoc = 'OFFERTA_ALLEGATI' and da.Deleted = 0
						group by da.LinkedDoc, al.numeroLotto

				) pending on pending.idOfferta = o.IdMsg and pending.numeroLotto = dp.NumeroLotto

	where dp.TipoDoc ='PDA_MICROLOTTI' and  dp.Voce = 0  



GO
