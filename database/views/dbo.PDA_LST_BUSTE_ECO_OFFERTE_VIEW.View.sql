USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_LST_BUSTE_ECO_OFFERTE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PDA_LST_BUSTE_ECO_OFFERTE_VIEW] as

select 

	dp.id
	, do.StatoRiga
	--, do.EsitoRiga as Motivazione
	, o.aziRagioneSociale
	, o.IdMsgFornitore
	, o.IdMsg

	--, do.PunteggioTecnico
	, case when isnull( do.ValoreOfferta , 0 ) - isnull( do.PunteggioTecnico , 0 ) < 0 then null else isnull( do.ValoreOfferta , 0 ) - isnull( do.PunteggioTecnico , 0 ) end as PunteggioEconomico

	, o.idAziPartecipante
	, do.id as IdRow
	, o.NumRiga

	-- riga del dettaglio lotto del fornitore
	, isnull( dof.id , do.idHeaderLotto ) as idHeaderLotto

	, case when ( isnull( BD.Value ,0) = 1 or isnull( v1.Value ,0) = 1 )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadDocumentazione
	, ReceivedDataMsg as DataInvio
	, ProtocolloOfferta as Protocollo
	, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( do.id  , 'ECONOMICA' ) as Motivazione
	, dp.idheader

	, do.ValoreEconomico		
	, do.ValoreImportoLotto
	, do.ValoreSconto			
	, do.ValoreRibasso

	--,do.PunteggioTecnicoRiparCriterio
	--,do.PunteggioTecnicoRiparTotale
	--,do.PunteggioTecnicoAssegnato

	from Document_MicroLotti_Dettagli dp with(nolock)
		inner join Document_PDA_OFFERTE o with(nolock) on dp.idheader = o.idheader

		-- recupero l'offerta del fornitore
		inner join Document_MicroLotti_Dettagli do with(nolock) on o.idrow = do.idheader and do.TipoDoc ='PDA_OFFERTE' and do.Voce = 0 and do.NumeroLotto = dp.NumeroLotto 
		
		-- prendo il dettaglio offerto dal fornitore
		left outer join Document_MicroLotti_Dettagli dof with(nolock) on o.IdMsgFornitore = dof.idheader and 
													( (dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA') or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
														and dof.Voce = 0 and dof.NumeroLotto = dp.NumeroLotto


		-- recupera l'evidenza di lettura del documento
		left outer join CTL_DOC_VALUE BD with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
		left outer join CTL_DOC_VALUE v1 with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_ECONOMICA' and v1.DZT_Name = 'LettaBusta' 

		left outer join CTL_DOC_VALUE BD2 on o.Tipodoc = 'OFFERTA' and o.idMsg = BD2.idHeader and BD2.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD2.DZT_Name = 'LettaBusta' and dof.id = BD2.row
		left outer join CTL_DOC_VALUE v2 on o.Tipodoc = 'OFFERTA' and o.idMsg = v2.idHeader and v2.DSE_ID = 'BUSTA_ECONOMICA' and v2.DZT_Name = 'LettaBusta' 

	where dp.Voce = 0





GO
