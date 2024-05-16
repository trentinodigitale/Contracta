USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_VIEW_QUESTIONARIO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OFFERTA_VIEW_QUESTIONARIO] as

 -- recupero informazione PresenzaQuestionario dalla gara
select 
	
	id as idheader,
	id as IdRow,
	0 as Row,
	'DISPLAY_QUESTIONARIO' as DSE_ID,
	'PresenzaQuestionario' as DZT_NAME,
	ISNULL(value,'') as Value
	
	from CTL_DOC with (nolock)
		left join CTL_DOC_Value CV with (nolock) on CV.IdHeader=LinkedDoc and DSE_ID='QUESTIONARIO' and DZT_Name='PresenzaQuestionario'

union 

 -- recuper allegato firmato dal MODULO_QUESTIONARIO_AMMINISTRATIVO
select 
	
	CV.id as idheader,
	CV.id as IdRow,
	0 as Row,
	'DISPLAY_QUESTIONARIO' as DSE_ID,
	'AllegatoQuestionario' as DZT_NAME,
	ISNULL(C.SIGN_ATTACH,'') as Value

	from CTL_DOC C with (nolock)
		left join CTL_DOC CV with (nolock) on CV.id=C.LinkedDoc 
	where C.TipoDoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' 


GO
