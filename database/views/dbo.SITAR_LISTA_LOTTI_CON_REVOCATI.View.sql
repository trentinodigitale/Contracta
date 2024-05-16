USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_LISTA_LOTTI_CON_REVOCATI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SITAR_LISTA_LOTTI_CON_REVOCATI] AS

	select C.id as idGara ,

			L.Descrizione as  W3OGGETTO2 , -- Oggetto del lotto ALFANUMERICO  
			case when isnull(L.CIG,'') = '' then b.cig else l.cig end as W3CIG,
			--'false' as W3SOMMA_UR , -- Somma urgenza? SN  ( da fare capire )

			SL.SOMMA_URGENZA as W3SOMMA_UR,

			-- (W3I_LOTTO) dalla richiesta cig del lotto recuperiamo il campo  ( IMPORTO_LOTTO – IMPORTO_ATTUAZIONE_SICUREZZA ) 
			case when sl.idrow is null then ltrim( str( L.ValoreImportoLotto  , 25 , 2 ) ) 
											else ltrim( str( isnull(sl.IMPORTO_LOTTO,0) - isnull(sl.IMPORTO_ATTUAZIONE_SICUREZZA,0) , 25 , 2 ) ) 
									   end
				 as W3I_LOTTO , -- Importo del lotto al netto dei costi della sicurezza IMPORTO  

			isnull( CPV.DMV_CodExt , '' ) as W3CPV , -- Codice CPV ALFANUMERICO 

			SL2.ID_SCELTA_CONTRAENTE as W3ID_SCEL2	,

			sl.TIPO_CONTRATTO as W3TIPO_CON,

			case 
				WHEN V.CriterioAggiudicazioneGara in (  '25532' )  then '5' -- costo fisso
				when V.CriterioAggiudicazioneGara in (  '15531' , '16291' )  then '4' -- prezzo più basso
				when V.CriterioAggiudicazioneGara in (  '15532' )  then '3' -- Offerta economicamente più vantaggiosa 
				else '' 
				end as W3MOD_GAR , -- Criterio di aggiudicazione TABELLATO W3007

			sl.MODALITA_ACQUISIZIONE as W3ID_APP04,

			rtrim(ltrim(sl.ID_CATEGORIA_PREVALENTE)) as W3ID_CATE4,

			'false' as W3MANOLO , -- W3MANOLO Posa in opera o manodopera? 

			case 
				when geo.DMV_Level = 7  then 
												case when g.CodiceComune <> '' then dbo.ZeriInTesta( g.CodiceRegione,3) + dbo.ZeriInTesta(  g.CodiceProvincia ,3) + dbo.ZeriInTesta( g.CodiceComune ,3) 
													 else RIGHT( '0000' + dbo.GetColumnValue( I.Value ,'-', 8), 6) 
													 end
										else '' 
				end as W3LUOGO_IS, -- Se si è selezionato un nodo di livello comune / 7 prendo il codice istat dalla sua ultima parte dmv_cod

			case when geo.DMV_Level = 6 then dbo.GetColumnValue( I.Value,'-', 7)	-- se si è scelto una provincia prendo il suo codice NUTS
				 when geo.DMV_Level = 5 then dbo.GetColumnValue( I.Value,'-', 6)	-- se si è scelta una regione prendo il suo codice NUTS
					 else '' 
				 end as W3LUOGO_NU ,

			'1' as W3ID_TIPO , -- Prestazione comprese nell’appalto non perninente: cosa ci mettiamo??? TABELLATO W3003 (metterei 1 – Sola Esecuzione) ( da fare capire )

			SL.TIPOLOGIA_LAVORO  as W3ID_APP05

			, cast( L.numerolotto as int ) as idRiga
			, cast( L.numerolotto as int ) as W3NLOTTO
			, sl.IMPORTO_ATTUAZIONE_SICUREZZA as W3I_ATTSIC
			, sl.ANNUALE_CUI_MININF as W9CUIINT

		from CTL_DOC C with(nolock) 
			inner join document_bando B with(nolock) on B.idheader = C.id
			inner join document_microlotti_dettagli L with(nolock) on L.idheader = C.ID and L.tipodoc = c.TipoDoc and L.voce = 0
			inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO v on v.idBando = C.id and v.N_Lotto = L.NumeroLotto

			left join CTL_DOC_VALUE I with(nolock) on I.idheader = c.id and I.DSE_ID = 'InfoTec_SIMOG' and i.DZT_Name = 'COD_LUOGO_ISTAT'
			left join LIB_DomainValues geo		with(nolock) on geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = I.Value
			left join GEO_ISTAT_elenco_comuni_italiani g with(nolock) on g.CodiceIstatDelComune_formato_alfanumerico = dbo.getpos( I.Value, '-', 8 )

			-- collega il lotto alla richiesta CIG del SIMOG se presente
			left join ctl_doc S with(nolock) on S.LinkedDoc = C.id and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 
			left join Document_SIMOG_LOTTI SL with(nolock) on SL.idHeader = S.Id and SL.NumeroLotto = L.NumeroLotto 
			left join Document_SIMOG_gara SL2 with(nolock) on SL2.idHeader = S.Id

			-- trasforma il codice CPV nel codice esterno
			left join LIB_DomainValues CPV with(nolock) on CPV.DMV_DM_ID = 'CODICE_CPV' and isnull( SL.CPV , L.CODICE_CPV ) = CPV.DMV_Cod
GO
