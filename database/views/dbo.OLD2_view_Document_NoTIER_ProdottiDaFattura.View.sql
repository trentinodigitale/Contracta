USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ProdottiDaFattura]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_view_Document_NoTIER_ProdottiDaFattura] AS
	select prod.*,
			c.idpfu as [owner]
		from Document_NoTIER_Prodotti prod with(nolock)
				INNER JOIN CTL_DOC inv with(nolock) ON prod.idheader = inv.id and inv.TipoDoc IN ( 'NOTIER_CREDIT_NOTE' )
				INNER JOIN aziende b with(nolock) ON inv.azienda = b.idazi
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi
		where prod.TipoDoc_collegato in ( 'FATTURA' )

GO
