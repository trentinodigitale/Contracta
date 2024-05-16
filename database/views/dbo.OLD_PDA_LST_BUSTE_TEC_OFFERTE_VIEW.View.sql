USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_LST_BUSTE_TEC_OFFERTE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [AFLink_RER]
--GO

--/****** Object:  View [dbo].[PDA_LST_BUSTE_TEC_OFFERTE_VIEW]    Script Date: 09/10/2018 11:27:36 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE view [dbo].[OLD_PDA_LST_BUSTE_TEC_OFFERTE_VIEW] as
select 

	dp.id
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

	where dp.TipoDoc ='PDA_MICROLOTTI' and  dp.Voce = 0  



GO
