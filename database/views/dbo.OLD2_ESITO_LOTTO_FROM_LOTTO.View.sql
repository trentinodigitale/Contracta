USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_ESITO_LOTTO_FROM_LOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_ESITO_LOTTO_FROM_LOTTO] as
select 
	L.id  as ID_FROM , o.idMsg as IdDoc,  idAziPArtecipante as Azienda
	,  Fascicolo , L.id as LinkedDoc --, 'InLavorazione' as StatoFunzionale
	, 
	case 
		when Divisione_lotti <> '0' then  L.NumeroLotto 
		else ''
	end as NumeroDocumento

	from Document_MicroLotti_Dettagli L with (nolock)
		inner join Document_PDA_OFFERTE o with (nolock) on L.idHeader = o.idrow 
		inner join ctl_doc b with (nolock) on o.idheader = b.id
		inner join Document_Bando DETT_GARA with (nolock) on DETT_GARA.idHeader = b.LinkedDoc 
GO
