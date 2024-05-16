USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SITAR_XML_DATI_GARA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[OLD_SITAR_XML_DATI_GARA] as 

	select  g.idRow, 
			g.idHeader,
			g.W3OGGETTO1 , --Oggetto della gara ALFANUMERICO
			g.W3IDGARA , --Codice della gara restituito dall’Autorità alla richiesta del CIG ALFANUMERICO ( da fare per le monolotto )
			 --Importo della gara IMPORTO ( Importo Base Asta [quello senza oneri])
			ltrim( str( g.W3I_GARA  , 25 , 2 ) ) as W3I_GARA,

			convert(varchar, g.W3DGURI, 126) as W3DGURI , -- Data pubblicazione del bando sulla GURI DATA ( ho preso data invio non so di preciso dove recuperare e sulla gara specifica manca
			convert(varchar, g.W3DSCADB, 126) as W3DSCADB  , --Data scadenza DATA
			g.W9GAMOD_IND,
			g.W9GAFLAG_ENT,
			g.W3TIPOAPP,
			g.W3ID_TIPOL,
			g.W9GASTIPULA , --La centrale di committenza procede alla stipula? SN ( da fare capire )
			g.CFTEC1 , -- Codice fiscale ALFANUMERICO (16)
			g.COGTEI , -- Cognome del tecnico ALFANUMERICO (40) 
			g.NOMETEI , -- Nome del tecnico ALFANUMERICO (20)
			'' as INDTEC1 , -- Indirizzo ALFANUMERICO 
			'' as NCITEC1 , -- Numero civico ALFANUMERICO
			'' as LOCTEC1 , -- Località di residenza ALFANUMERICO  
			'' as PROTEC  , -- Provincia ALFANUMERICO 
			'' as CAPTEC1 , -- Codice di avviamento postale ALFANUMERICO 
			'' as G_CITTECI , -- Codice ISTAT del comune ALFANUMERICO 
			g.TELTEC1 , -- Numero di telefono ALFANUMERICO 
			'' as FAXTEC1 , -- FAX 
			g.G_EMATECI , -- Indirizzo E-mail ALFANUMERICO 

			g.W3PROFILO1 , -- Profilo del committente ( da fare capire )
			g.W3MIN1 , -- Sito Informatico Ministero Infrastrutture ( da fare capire )
			g.W3OSS1 , -- Sito Informatico Osservatorio Contratti Pubblici ( da fare capire )
			g.W9CCCODICE,
			g.W9CCDENOM,
			g.CFEIN,
			g.W9GADURACCQ,

			isnull( o.SIGN_ATTACH, g.AllegatoPerOCP) as AllegatoPerOCP   ,

			COALESCE(p2.value, p.value,'') as W9PBCOD_PUBB,

			--W9PBDATAPUBB  = Nel caso dell’Appalto Specifico è la “data della determina di indizione dell’appalto”  W9PBDATAPR  altrimenti  la data di invio della gara 
			isnull(convert(varchar, g.DataIndizione, 126),'') as W9PBDATADEC,  --Data decreto

			isnull(convert(varchar, g.W9GADPUBB, 126),'') as W9GADPUBB,

			case when g.W3FLAG_SA = 'S' THEN 'true' else 'false' end W3FLAG_SA, 

			case when g.W9GACAM = '1' then 'true' else 'false' end W9GACAM, 
			case when g.W9SISMA = '1' then 'true' else 'false' end W9SISMA,

			g.W3NAZ1,
			g.W3REG1,

			convert(varchar, g.W3GUCE1, 126) as W3GUCE1,
			convert(varchar, g.W3GURI1, 126) as W3GURI1,
			convert(varchar, g.W3ALBO1, 126) as W3ALBO1,

			isnull(convert(varchar, g.W9PBDATAPUBB, 126),'') as W9PBDATAPUBB,
			isnull(convert(varchar, g.W9PBDATASCAD, 126),'') as W9PBDATASCAD,

			isnull(o.IdDoc,1) as W9PBTIPDOC, -- per l'istanzia documentazione
			isnull(o.titolo, 'Atto di indizione') as W9DGTITOLO

		from Document_OCP_GARA g with(nolock)
				inner join ctl_doc o with(nolock) on o.id = g.idHeader
				-- Versione precedente, prendevamo il "codice pubblicazione documentazione" collegato all'id della gara. Ritornato dopo il primo invio ed utilizzato negli invii successivi per andare in modifica
				left join ctl_doc_value p with(nolock) on p.IdHeader = o.LinkedDoc and p.DSE_ID = 'OCP' and p.DZT_Name = 'W9PBCOD_PUBB' 

				-- Versione nuova, prendiamo il "codice pubblicazione documentazione" collegato all'id dell'istanzia documentazione
				left join ctl_doc_value p2 with(nolock) on p2.IdHeader = o.id and p2.DSE_ID = 'OCP' and p2.DZT_Name = 'W9PBCOD_PUBB' 
GO
