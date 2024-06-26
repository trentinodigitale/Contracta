USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_MODELLI_MICROLOTTI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  CREATE VIEW [dbo].[OLD2_DASHBOARD_MODELLI_MICROLOTTI_VIEW] as 
  select 
	  DM.Id, 
	  DM.StatoDoc, 
	  DM.Deleted, 
	  DM.DataCreazione,
	  DM.Codice, 
	  DM.Descrizione, 
	  DM.ModelloBando, 
	  DM.ModelloOfferta, 
	  DM.ColonneCauzione, 
	  DM.Allegato, 
	  DM.ModelloPDA, 
	  DM.ModelloPDA_DrillTestata, 
	  DM.ModelloPDA_DrillLista, 
	  DM.ModelloOfferta_Drill,
	  DM.ModelloConformitaTestata, 
	  DM.ModelloConformitaDettagli--,
	 -- FormulaEconomica, 
	  --CriterioFormulazioneOfferte
  from dbo.Document_Modelli_MicroLotti DM
 -- inner join dbo.Document_Modelli_MicroLotti_Formula DF on DM.id=DF.IdHeader
GO
