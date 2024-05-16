USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_ATTI_GARA_IA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[RICHIESTA_ATTI_GARA_IA_VIEW] as
select 
	C.*,
	ISNULL(CHIUSURA_RICHIESTA,'') as CHIUSURA_RICHIESTA
	from CTL_DOC C with(nolock)
		left join ( select INVIO_ATTI.LinkedDoc ,CHIUSURA_RICHIESTA
						from CTL_DOC INVIO_ATTI 
							inner join Document_Richiesta_Atti R  with(nolock) on R.idHeader=INVIO_ATTI.id and ISNULL(CHIUSURA_RICHIESTA,'')='si'
						where INVIO_ATTI.StatoDoc='Sended' ) W on W.LinkedDoc=C.id
	where C.TipoDoc='RICHIESTA_ATTI_GARA'
GO
