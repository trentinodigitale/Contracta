USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_LISTA_LOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SITAR_XML_LISTA_LOTTI] as

	select  l.idRow, 
			l.idHeader,
			W3OGGETTO2 , -- Oggetto del lotto ALFANUMERICO  
			left(ltrim(rtrim(W3CIG)),10) as W3CIG, -- Codice individuazione CIG ALFANUMERICO X 
			'' as W3SOMMA_UR, -- campo non più utilizzato
			ltrim(str( l.W3I_LOTTO , 25 , 2 )) as W3I_LOTTO , -- Importo del lotto al netto dei costi della sicurezza IMPORTO  
			l.W3CPV , -- Codice CPV ALFANUMERICO 
			l.W3ID_SCEL2,
			l. W3TIPO_CON,
			l.W3MOD_GAR , -- Criterio di aggiudicazione TABELLATO W3007
			l.W3ID_APP04,
			replace(l.W3ID_CATE4, ' ','') as W3ID_CATE4, -- i codici simog e sitar non si trovano. il simog ha degli spazzi al centro mentre il sitar no
			l.W3MANOLO , -- W3MANOLO Posa in opera o manodopera? 
			l.W3LUOGO_IS , -- Se si è selezionato un nodo di livello comune / 7 prendo il codice istat dalla sua ultima parte dmv_cod
			l.W3LUOGO_NU ,
			l.W3ID_TIPO , -- Prestazione comprese nell’appalto non perninente: cosa ci mettiamo??? TABELLATO W3003 (metterei 1 – Sola Esecuzione) ( da fare capire )
			l.W3ID_APP05,
			l.numerolotto as idRiga,
			l.numerolotto,

			convert(varchar, W9INSCAD, 126) as W9INSCAD,
			convert(varchar, W9INDECO, 126) as W9INDECO,
			convert(varchar, W3DATA_ESE, 126) as W3DATA_ESE,
			convert(varchar, W3DATA_STI, 126) as W3DATA_STI,

			ltrim(str( l.W3I_ATTSIC , 25 , 2 )) as W3I_ATTSIC,
			W9CUIINT

		from Document_OCP_LOTTI l with(nolock)
				inner join Document_OCP_GARA g with(nolock) on g.idHeader = l.idHeader


GO
