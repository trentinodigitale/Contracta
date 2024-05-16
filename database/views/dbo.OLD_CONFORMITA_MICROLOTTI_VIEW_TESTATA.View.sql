USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONFORMITA_MICROLOTTI_VIEW_TESTATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD_CONFORMITA_MICROLOTTI_VIEW_TESTATA] as
select 
		v.* 
		, t.* 
		, ModelloPDA
		, ModelloPDA_DrillTestata
		, ModelloPDA_DrillLista
		, ModelloOfferta_Drill
		, ModelloConformitaTestata 
		, ModelloConformitaDettagli

	 from CTL_DOC v
		inner join CTL_DOC d on v.LinkedDoc = d.id
		inner join Document_PDA_TESTATA t on d.id = t.idheader
		left outer join Document_Modelli_MicroLotti m on m.Codice = t.ListaModelliMicrolotti

	where v.deleted = 0
GO
