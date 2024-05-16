USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CONFERMA_ISCRIZIONE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_CONFERMA_ISCRIZIONE_VIEW] as 
	select d.*
		,i.Azienda as LegalPub
		,i.Protocollo as ProtocolloOfferta
		,bando.ResponsabileProcedimento 
		,i.tipodoc as colonnatecnica
		,bando.protocollo as ProtocolloCapostipite
		,ISNULL(CV.value,'') as Conferma_Parziale
		,ISNULL(n.value,'') as NumGiorni

	from CTL_DOC  d												--conferma
		inner join CTL_DOC i on d.LinkedDoc = i.id				-- istanza
		left join CTL_DOC_VIEW bando ON bando.id = i.LinkedDoc  -- bando sda

		left join CTL_DOC_Value CV on CV.IdHeader=d.id and CV.DSE_ID='CLASSI' and CV.DZT_Name='Conferma_Parziale'		
		left join CTL_DOC_Value n on n.IdHeader=d.id and n.DSE_ID='ALLEGATO' and n.DZT_Name='NumGiorni'		


GO
