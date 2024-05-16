USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_NOTIER_DOCUMENT_PER_IMR]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_VIEW_NOTIER_DOCUMENT_PER_IMR] AS 

	SELECT  doc.id as idDoc,
			dm1.vatValore_FT as PARTICIPANTID,
			v1.Value as CHIAVE_NUMERO,
			--YEAR(doc.DataInvio) as CHIAVE_ANNO, -- nel collaudo del 2023-04-21 si è deciso che è più corretto usata la data documento e non l'invio
			left(v3.Value,4) as CHIAVE_ANNO,
			dm2.vatValore_FT AS IDNOTIER	
		FROM CTL_DOC doc with(nolock) 
				left join DM_Attributi dm1 with(nolock) on dm1.lnk = doc.Azienda and dm1.dztNome = 'PARTICIPANTID'
				inner join DM_Attributi dm2 with(nolock) on dm2.lnk = doc.Azienda and dm2.dztNome = 'IDNOTIER'
				inner join CTL_DOC_Value v1 with(nolock) on v1.IdHeader = doc.Id and v1.DSE_ID = 'INVOICE' and v1.DZT_Name = 'Order_ID'
				inner join CTL_DOC_Value v2 with(nolock) on v2.IdHeader = doc.Id and v2.DSE_ID = 'NOTIER' and v2.DZT_Name = 'URN' --facciamo una inner join sull'URN per prenderci solo i documenti inviati verso notier senza fare considerazioni sullo statofunzionale				
				inner join CTL_DOC_Value v3 with(nolock) on v3.IdHeader = doc.Id and v3.DSE_ID = 'INVOICE' and v3.DZT_Name = 'Order_IssueDate'
		WHERE doc.TipoDoc IN ( 'NOTIER_INVOICE', 'NOTIER_CREDIT_NOTE' )

	UNION ALL

	SELECT  doc.id as idDoc,
			dest.ID_PEPPOL as PARTICIPANTID,
			v1.Value as CHIAVE_NUMERO,
			left(v3.Value,4) as CHIAVE_ANNO,
			dest.ID_NOTIER AS IDNOTIER	
		FROM CTL_DOC doc with(nolock) 
				inner join DM_Attributi dm with(nolock) on dm.lnk = doc.Azienda and dm.dztNome = 'codicefiscale' and dm.idApp = 1
				inner join CTL_DOC_Value v1 with(nolock) on v1.IdHeader = doc.Id and v1.DSE_ID = 'INVOICE' and v1.DZT_Name = 'Order_ID'
				inner join CTL_DOC_Value v2 with(nolock) on v2.IdHeader = doc.Id and v2.DSE_ID = 'NOTIER' and v2.DZT_Name = 'URN' --facciamo una inner join sull'URN per prenderci solo i documenti inviati verso notier senza fare considerazioni sullo statofunzionale				
				inner join CTL_DOC_Value v3 with(nolock) on v3.IdHeader = doc.Id and v3.DSE_ID = 'INVOICE' and v3.DZT_Name = 'Order_IssueDate'
				inner join Document_NoTIER_Destinatari dest with(nolock) on dest.piva_cf = dm.vatValore_FT and dest.bDeleted = 0 
		WHERE doc.TipoDoc IN ( 'NOTIER_INVOICE', 'NOTIER_CREDIT_NOTE' )

GO
