USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_Modelli_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_View_Modelli_PROGRAMMAZIONE] as

	select 
		c.titolo as codice , 
		isnull(  C3.Value , '5' ) as Ambito,
		C.JumpCheck
		from 
			ctl_doc C
			left outer join ctl_doc_value C3 on C3.idheader=C.id and C3.dzt_name='MacroAreaMerc' 
			
		where 
			C.tipodoc='CONFIG_MODELLI_FABBISOGNI'
			and C.deleted=0 and C.JumpCheck='PROGRAMMAZIONE'
GO
