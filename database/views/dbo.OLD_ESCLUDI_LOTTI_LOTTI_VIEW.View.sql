USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ESCLUDI_LOTTI_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_ESCLUDI_LOTTI_LOTTI_VIEW] AS
select 
	L.*,
	ISNULL(CV.Value,'') as EsitoRiserva

from Document_Pda_Escludi_Lotti L
	inner join ctl_doc C on C.id=L.IdHeader and C.TipoDoc='ESCLUDI_LOTTI' 
	inner join Document_PDA_OFFERTE DO on DO.IdHeader=C.IdDoc and idAziPartecipante=Azienda
	inner join Document_MicroLotti_Dettagli D on D.IdHeader=DO.IdMsg and D.TipoDoc='OFFERTA' and D.Voce=0 and L.NumeroLotto=D.NumeroLotto
	left join CTL_DOC CS on CS.LinkedDoc=D.Id and CS.StatoFunzionale='Confermato'
	left join CTL_DOC_VALUE CV on CV.IdHeader=CS.Id and CV.DSE_ID='SAVE' and CV.DZT_Name='EsitoRiserva'

GO
