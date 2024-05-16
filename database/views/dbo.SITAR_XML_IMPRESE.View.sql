USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_IMPRESE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[SITAR_XML_IMPRESE] as 

	select 
			[idRow], [idHeader], [idAzi], W9IMPARTEC,  [CFIMP], 
			[NOMIMP], [W3AGIDGRP], GNATGIUI, [W3ID_TIPOA], [W3RUOLO],
			[G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], 
			[FAXIMP], [EMAI2IP], [NCCIAA], CAPIMP

			,c.LinkedDoc -- l'idrow della Document_OCP_LOTTI

		from Document_OCP_IMPRESE_GARA  I with(nolock)
					INNER JOIN CTL_DOC c with(nolock) on c.id = i.idHeader and c.tipodoc = 'OCP_IMPRESE_LOTTO'
GO
