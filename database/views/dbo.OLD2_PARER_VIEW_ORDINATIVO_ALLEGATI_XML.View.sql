USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PARER_VIEW_ORDINATIVO_ALLEGATI_XML]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_PARER_VIEW_ORDINATIVO_ALLEGATI_XML] AS
	select al.idHeader --chiave di ingresso
			
			-- FILE DA INVIARE
			, al.Allegato
	
			--- *** DOCUMENTO PRINCIPALE *** ---
			, dbo.getpos(al.Allegato,'*',4) as DOC_ALLEGATO_ATT_HASH
			, isnull(al.Descrizione,'Allegato') as DOC_ALLEGATO_DESCRIZIONE
			--, cast( (ROW_NUMBER() OVER(ORDER BY al.idrow ASC) + 1) as varchar ) as DOC_ALLEGATO_ORDINE_PRESENTAZIONE
			, dbo.getpos(al.Allegato,'*',1) as DOC_ALLEGATO_FILE_NAME
			--, dbo.getpos(al.Allegato,'*',2) as DOC_ALLEGATO_FILE_EXT
			, case when right(dbo.getpos(al.Allegato,'*',1), 8) = '.pdf.p7m' then 'PDF.P7M' else upper(dbo.getpos(al.Allegato,'*',2)) end as DOC_ALLEGATO_FILE_EXT
			, dbo.getpos(al.Allegato,'*',6) as DOC_ALLEGATO_FILE_HASH
			, CONVERT(VARCHAR(19),o.datainvio, 126) as ODC_DATA_FIRMA_ALLEGATO

			, al.idrow as idRiga -- il chiamante ordinerà su questa colonna. così da calcolare anche il valore di DOC_ALLEGATO_ORDINE_PRESENTAZIONE

		from ctl_doc o with(nolock)
				inner join CTL_DOC_ALLEGATI al with(nolocK) on al.idHeader = o.Id and al.Allegato <> ''
		where o.TipoDoc = 'ODC'-- AND o.id = 65123 
GO
