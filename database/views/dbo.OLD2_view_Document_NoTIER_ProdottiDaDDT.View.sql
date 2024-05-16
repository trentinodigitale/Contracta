USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ProdottiDaDDT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_view_Document_NoTIER_ProdottiDaDDT] as
	select prod.*,
			c.idpfu as [owner]
		from Document_NoTIER_Prodotti prod with(nolock)
				INNER JOIN CTL_DOC inv with(nolock) ON prod.idheader = inv.id and inv.TipoDoc IN ( 'NOTIER_INVOICE' )
				INNER JOIN aziende b with(nolock) ON inv.azienda = b.idazi
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi
				-- tolgo il controllo che non mi fa vedere i prodotti gia inseriti nel ddt (permetto quindi di duplicarli)
				--LEFT JOIN Document_NoTIER_Prodotti prodDDT with(nolock) ON prodDDT.IdHeader = prod.IdHeader and prodDDT.TipoDoc_collegato = 'DDT' and prod.DespatchLine_ID = prodDDT.DespatchLine_ID 
		where prod.TipoDoc_collegato in ( 'ORDINE', 'DDT' ) --and prodDDT.IdRow is null
GO
