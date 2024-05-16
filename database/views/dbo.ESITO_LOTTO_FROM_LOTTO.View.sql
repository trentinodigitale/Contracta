USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_LOTTO_FROM_LOTTO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[ESITO_LOTTO_FROM_LOTTO] as

select 
	L.id  as ID_FROM,
	o.idMsg as IdDoc,
	--idAziPArtecipante as Azienda,
	case
		when b.TipoDoc ='PDA_CONCORSO' then 
			
			case 
				when isnull(AN.Value,'0') = '1' then idAziPArtecipante
				else null
			end

		else
			idAziPArtecipante
		
	end as Azienda,
	Fascicolo,
	L.id as LinkedDoc, --, 'InLavorazione' as StatoFunzionale
	case 
		when Divisione_lotti <> '0' then  L.NumeroLotto 
		else ''
	end as NumeroDocumento

	from Document_MicroLotti_Dettagli L with (nolock)
		inner join Document_PDA_OFFERTE o with (nolock) on L.idHeader = o.idrow 
		inner join ctl_doc b with (nolock) on o.idheader = b.id
		inner join Document_Bando DETT_GARA with (nolock) on DETT_GARA.idHeader = b.LinkedDoc 
		left join CTL_DOC_VALUE AN with (nolock) on b.id = AN.IdHeader and DSE_ID = 'ANONIMATO' and DZT_NAME = 'DATI_IN_CHIARO'

GO
