USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SDA_XML_AMBITO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_BANDO_SDA_XML_AMBITO] as
	select isnull(descs.DMV_DescML, 'Altri Beni') as descAmbito
	   ,ambiti.Value as Ambito
	   ,doc.id
	   ,vals.idheader 	
	FROM ctl_doc DOC with(nolock) 
				-- Dal codice del modello risalgo al suo ambito
			LEFT JOIN ctl_doc_value vals with(nolock) ON vals.idheader = doc.id and vals.DZT_Name = 'id_modello' and vals.dse_id = 'TESTATA_PRODOTTI'
			LEFT JOIN ctl_doc_value ambiti with(nolock) ON vals.value = ambiti.idheader and ambiti.DSE_ID = 'AMBITO' and ambiti.DZT_Name = 'MacroAreaMerc'
			LEFT JOIN LIB_DomainValues descs ON descs.DMV_Cod = ambiti.Value and descs.DMV_DM_ID = 'Ambito'
	WHERE tipodoc = 'BANDO_SDA' and statofunzionale not in ('InLavorazione','InApprove', 'NEW_SEMPLIFICATO') and deleted = 0
GO
