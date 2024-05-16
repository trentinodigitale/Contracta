USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ListaDDT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- inizialmente il folder visualizzava solo i DDT, ora anche le fatture e le note di credito
CREATE view [dbo].[OLD2_view_Document_NoTIER_ListaDDT] as
	select ddt.*,
			ddt.TipoDoc as TIPO_DOC_AF_PEPPOL,
			--cast( c.idpfu as varchar) as [owner],
			c.idpfu as [owner],
			ddt.TipoDoc as OPEN_DOC_NAME,
			d.Value as CHIAVE_NUMERO
		
		
		--from CTL_DOC ddt with(nolock)
		--		INNER JOIN aziende b  with(nolock) ON ddt.azienda = b.idazi
		--		INNER JOIN profiliutente c  with(nolock) ON c.pfuidazi = b.idazi
		--		LEFT JOIN CTL_DOC_Value d with(nolock) ON d.IdHeader = ddt.Id and d.DSE_ID IN ( 'INVOICE', 'DESPATCHADVICE' ) and d.DZT_Name in ( 'Order_ID', 'DespatchAdvice_ID' )
		--where ddt.tipodoc IN ('NOTIER_DDT', 'NOTIER_INVOICE','NOTIER_CREDIT_NOTE') 
		--	and ddt.deleted = 0 
		--ENRPAN
		--modificata la navigazione perchè entriamo per owner e forzato indice
		FROM profiliutente c  with(nolock, index(IX_ProfiliUtente))
				inner join CTL_DOC ddt with(nolock,index(ICX_CTL_DOC_LinkedDoc_Azienda_TipoDoc_StatoFunzionale_Deleted) ) 
					on   ddt.azienda = c.pfuidazi and ddt.deleted = 0  and linkeddoc is null and ddt.tipodoc IN ('NOTIER_DDT', 'NOTIER_INVOICE','NOTIER_CREDIT_NOTE') 
				LEFT JOIN CTL_DOC_Value d with(nolock) ON d.IdHeader = ddt.Id and d.DSE_ID IN ( 'INVOICE', 'DESPATCHADVICE' ) and d.DZT_Name in ( 'Order_ID', 'DespatchAdvice_ID' )
GO
