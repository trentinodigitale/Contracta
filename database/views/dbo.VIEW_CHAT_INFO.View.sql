USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CHAT_INFO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[VIEW_CHAT_INFO] as 

select 
	o.Value as Utente, 
	StatoSeduta, 
	B.StatoChat as StatoChat,
	c.* , 
	o.Value as OwnerChat,
	'CHAT' as DSE_ID
from CTL_CHAT_ROOMS c with(nolock) 
	left outer join CTL_DOC_Value o with(nolock) on o.IdHeader = c.idHeader and o.DSE_ID = 'CHAT' and DZT_Name = 'OwnerChat'
	left join CTL_DOC P on P.id = c.IdHeader and P.TipoDoc='PDA_MICROLOTTI'
	left join Document_Bando B on B.idHeader = P.LinkedDoc
	--left join ProfiliUtente PU on PU.IdPfu = P.idpfu


GO
