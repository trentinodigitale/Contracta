USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MODULO_QUESTIONARIO_AMMINISTRATIVO_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_MODULO_QUESTIONARIO_AMMINISTRATIVO_DOCUMENT_VIEW] as

select 
	
	C.* ,
	
	
	--case when isnull(C1.StatoFunzionale,'') <> 'InLavorazione'  or  ISNULL(c1.SIGN_HASH,'')<>'' or ISNULL(c1.SIGN_LOCK,'')<>''  then 'no'
	case when isnull(C1.StatoFunzionale,'') <> 'InLavorazione' then 'no'
		 else 'si' 
	end as colonnatecnica

from ctl_doc C with (nolock)
	
	left join  ctl_doc C1 with (nolock) on C1.id= C.LinkedDoc 
	
	where c.TipoDoc='MODULO_QUESTIONARIO_AMMINISTRATIVO'

GO
