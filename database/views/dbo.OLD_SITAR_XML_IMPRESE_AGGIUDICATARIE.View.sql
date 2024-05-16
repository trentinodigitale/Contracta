USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SITAR_XML_IMPRESE_AGGIUDICATARIE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_SITAR_XML_IMPRESE_AGGIUDICATARIE] as 

	select 
			[idRow], [idHeader], [idAzi], [CFIMP], [NOMIMP], [W3AGIDGRP], [W3ID_TIPOA], [W3RUOLO], [W3FLAG_AVV],
			[G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], [FAXIMP], [EMAI2IP], [NCCIAA], [AGGAUS], [CAPIMP]


			,c.LinkedDoc -- l'idrow della Document_OCP_LOTTI_AGGIUDICATI
		from Document_OCP_IMPRESE_AGGIUDICATARIE I with(nolock)
					INNER JOIN CTL_DOC c with(nolock) on c.id = i.idHeader and c.tipodoc = 'OCP_IMPRESE_AGGIUDICATARIE'
GO
