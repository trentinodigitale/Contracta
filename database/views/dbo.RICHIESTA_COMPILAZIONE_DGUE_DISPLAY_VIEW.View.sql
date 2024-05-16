USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_COMPILAZIONE_DGUE_DISPLAY_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[RICHIESTA_COMPILAZIONE_DGUE_DISPLAY_VIEW] as

	select 
		CV.id as idheader,
		CV.id as IdRow,
		0 as Row,
		'DISPLAY_DGUE' as DSE_ID,
		'Allegato' as DZT_NAME,
		ISNULL(C.SIGN_ATTACH,'') as Value
	from CTL_DOC C
		left join CTL_DOC CV on CV.id=C.LinkedDoc 
	where C.TipoDoc='MODULO_TEMPLATE_REQUEST' and C.Deleted=0--and C.Jumpcheck='DGUE_RTI'

--NON SERVE IL JUMPCHECK essendo un solo TEMPLATE con quel linkeddoc, 
--questo portava a non vedere alcuni DGUE compilati sul richieste a terzi con jumpcheck = mandataria

--union 

--	select 
--		CV.id as idheader,
--		CV.id as IdRow,
--		0 as Row,
--		'DISPLAY_DGUE' as DSE_ID,
--		'Allegato' as DZT_NAME,
--		ISNULL(C.SIGN_ATTACH,'') as Value
--	from CTL_DOC C
--		left join CTL_DOC CV on CV.id=C.LinkedDoc 
--	where C.TipoDoc='MODULO_TEMPLATE_REQUEST' and C.Jumpcheck='DGUE_ESECUTRICI'

--union 

--	select 
--		CV.id as idheader,
--		CV.id as IdRow,
--		0 as Row,
--		'DISPLAY_DGUE' as DSE_ID,
--		'Allegato' as DZT_NAME,
--		ISNULL(C.SIGN_ATTACH,'') as Value
--	from CTL_DOC C
--		left join CTL_DOC CV on CV.id=C.LinkedDoc 
--	where C.TipoDoc='MODULO_TEMPLATE_REQUEST' and C.Jumpcheck='DGUE_AUSILIARIE'


--union 

--	select 
--		CV.id as idheader,
--		CV.id as IdRow,
--		0 as Row,
--		'DISPLAY_DGUE' as DSE_ID,
--		'Allegato' as DZT_NAME,
--		ISNULL(C.SIGN_ATTACH,'') as Value
--	from CTL_DOC C
--		left join CTL_DOC CV on CV.id=C.LinkedDoc 
--	where C.TipoDoc='MODULO_TEMPLATE_REQUEST' and C.Jumpcheck='DGUE_SUBAPPALTO'

GO
