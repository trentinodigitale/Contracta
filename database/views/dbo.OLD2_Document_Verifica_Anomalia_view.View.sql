USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_Document_Verifica_Anomalia_view]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_Document_Verifica_Anomalia_view] as 

select  
	Graduatoria , Sorteggio , StatoRiga , Posizione , ValoreImportoLotto , ValoreSconto
	, v.*	--, d.*
	from Document_Verifica_Anomalia v
		inner join Document_MicroLotti_Dettagli d on id_rowLottoOff = d.id

GO
