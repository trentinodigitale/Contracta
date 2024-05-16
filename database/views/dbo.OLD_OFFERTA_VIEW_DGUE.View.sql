USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_VIEW_DGUE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_OFFERTA_VIEW_DGUE] as
select 
	id as idheader,
	id as IdRow,
	0 as Row,
	'DISPLAY_DGUE' as DSE_ID,
	'PresenzaDGUE' as DZT_NAME,
	ISNULL(value,'') as Value
from CTL_DOC
left join CTL_DOC_Value CV on CV.IdHeader=LinkedDoc and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE'

union 

select 
	CV.id as idheader,
	CV.id as IdRow,
	0 as Row,
	'DISPLAY_DGUE' as DSE_ID,
	'Allegato' as DZT_NAME,
	ISNULL(C.SIGN_ATTACH,'') as Value
from CTL_DOC C
left join CTL_DOC CV on CV.id=C.LinkedDoc 
where C.TipoDoc='MODULO_TEMPLATE_REQUEST' and C.Jumpcheck='DGUE_MANDATARIA'



GO
