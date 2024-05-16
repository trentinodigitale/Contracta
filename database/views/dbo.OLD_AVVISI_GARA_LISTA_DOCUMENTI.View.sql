USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AVVISI_GARA_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_AVVISI_GARA_LISTA_DOCUMENTI] as

	select	c.LinkedDoc
			, c.id
			, c.StatoDoc
			, c.StatoFunzionale
			, c.Note
			, c.SIGN_ATTACH
			, c.DataInvio
			, tipodoc as OPEN_DOC_NAME
			, comp.pfuNome as compilatore
			, case when c.StatoFunzionale <> 'Annullato' then '1' else '0' end AS FNZ_DEL
			, 1 as OPEN_DOC

		from ctl_doc c
				left join profiliutente comp ON c.idpfu = comp.idpfu
		where c.tipodoc = 'AVVISO_GARA' and c.deleted = 0 and statofunzionale in ( 'Annullato', 'Inviato' )
		








GO
