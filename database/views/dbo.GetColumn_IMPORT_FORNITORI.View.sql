USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GetColumn_IMPORT_FORNITORI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[GetColumn_IMPORT_FORNITORI]
as

select  '' as Codice_ditta,
		'' as Indicatore_cliente_fornitore,
		'' as Codice_cliente_fornitore,
		'' as Ragione_sociale_anagrafica,
		'' as Ragione_sociale_anagrafica_est,
		'' as Indirizzo_anagrafica,
		'' as Indirizzo_anagrafica_est,
		'' as Codice_comune_anagrafica,
		'' as Cap_anagrafica,
		'' as Citta_anagrafica,
		'' as Provincia_anagrafica,
		'' as Codice_stato_estero,
		'' as Partita_iva,
		'' as Partita_iva_estera,
		'' as Codice_fiscale,
		'' as Telefono_1,
		'' as Telefono_2,
		'' as Fax,
		'' as Indirizzo_email,
		'' as Indirizzo_web,
		'' as Data_creazione_clifor,
		1 as idheader,
		'IMPORT_FORNITORI' as tipodoc,
		1 as id
GO
