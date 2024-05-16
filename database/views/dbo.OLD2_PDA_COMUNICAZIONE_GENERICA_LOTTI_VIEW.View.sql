USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_LOTTI_VIEW] as 



	select S.*,C.StatoFunzionale
		from ctl_doc C with(nolock) 
			INNER JOIN Document_comunicazione_StatoLotti S with(nolock) ON IDHEADER = C.ID
		where tipodoc = 'pda_comunicazione_generica' AND jumpcheck LIKE '%ESITO%'

			

GO
