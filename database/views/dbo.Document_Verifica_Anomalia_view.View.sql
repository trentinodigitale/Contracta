USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Verifica_Anomalia_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Verifica_Anomalia_view] as 

select  
	Graduatoria , Sorteggio , StatoRiga , Posizione , ValoreImportoLotto , ValoreSconto , ValoreRibasso
	, v.*	--, d.*
	,case when v.NotEdit = 1 then ' Motivazione , StatoAnomalia ' else '' end as NotEditable
	from Document_Verifica_Anomalia v
		inner join Document_MicroLotti_Dettagli d on id_rowLottoOff = d.id




GO
