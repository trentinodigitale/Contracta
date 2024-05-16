USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QUESTIONARIO_FABBISOGNI_SUB_QUESTIONARI_QUALITATIVI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  VIEW [dbo].[QUESTIONARIO_FABBISOGNI_SUB_QUESTIONARI_QUALITATIVI_VIEW] AS
SELECT
	IdHeader,
	idrow,
	CD.IdPfu,
	StatoIscrizione as StatoSub_Questionario,
	C.tipodoc as SUB_QUESTIONARIGrid_OPEN_DOC_NAME,
	C.id as SUB_QUESTIONARIGrid_ID_DOC
	--,Sezioni_Questionario
from CTL_DOC_Destinatari CD
	left join ctl_Doc C on C.LinkedDoc=Cd.idHeader and C.tipodoc like 'SUB_QUESTIONARIO_%' /*'SUB_QUESTIONARIO_FABBISOGNI'*/ and C.IdPfu=Cd.IdPfu



GO
