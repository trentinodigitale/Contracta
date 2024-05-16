USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_Prodotti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_view_Document_NoTIER_Prodotti] as
	select prod.*,
			c.idpfu as [owner]
		from Document_NoTIER_Prodotti prod with(nolock)
				INNER JOIN CTL_DOC ddt with(nolock) ON prod.idheader = ddt.id and ddt.TipoDoc IN ( 'NOTIER_DDT', 'NOTIER_INVOICE', 'NOTIER_CREDIT_NOTE' )
				INNER JOIN aziende b with(nolock) ON ddt.azienda = b.idazi
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi
				-- tolgo il controllo che non mi fa vedere i prodotti gia inseriti nel ddt (permetto quindi di duplicarli)
				--LEFT JOIN Document_NoTIER_Prodotti prodDDT with(nolock) ON prodDDT.IdHeader = prod.IdHeader and prodDDT.TipoDoc_collegato = 'DDT' and prod.DespatchLine_ID = prodDDT.DespatchLine_ID 
		where prod.TipoDoc_collegato = 'ORDINE' --and prodDDT.IdRow is null
GO
