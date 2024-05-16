USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_Document_NoTIER_ListaDocumentiEnte]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_view_Document_NoTIER_ListaDocumentiEnte] as
	select a.*, c.idpfu as idOwner, isnull( e.aziRagioneSociale, '') as aziRagioneSociale, case when STATOGIACENZA = 'DA_RECAPITARE' then 1 else 0 end as bread
		from Document_NoTIER_ListaDocumenti a with(nolock)
				INNER JOIN aziende b with(nolock) ON a.idazi = b.idazi 
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi

				LEFT JOIN DM_Attributi at with(nolock) ON at.idapp=1 and a.CHIAVE_CODICEFISCALEMITTENTE = at.vatValore_FT and at.dztNome = 'codicefiscale'
				LEFT JOIN aziende e with(nolock) on at.lnk = e.idazi and e.aziVenditore <> 0 and e.aziDeleted = 0

		where a.deleted = 0


GO
