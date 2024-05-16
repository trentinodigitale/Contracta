USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CHAT_INFO_SEDUTA_VIRTUALE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_CHAT_INFO_SEDUTA_VIRTUALE] as 

select 
	o.Value as Utente, 
	StatoSeduta, 
	B.StatoChat as StatoChat,
	o.Value as OwnerChat,
	'CHAT' as DSE_ID,
	d.Id as Idheader,
	C.id,
	C.Title,
	C.Owner,
	C.Chat_Stato,
	C.DateStart,	
	C.DateEnd,
	C.LastUpd,
	C.idHeader as idPdA
from ctl_doc d with(nolock)
	inner join CTL_DOC PDA with(nolock) on PDA.LinkedDoc=D.LinkedDoc and PDA.TipoDoc='PDA_MICROLOTTI' and PDA.Deleted=0
	inner join CTL_CHAT_ROOMS c with(nolock) on C.idHeader=PDA.id
	left outer join CTL_DOC_Value o with(nolock) on o.IdHeader = c.idHeader and o.DSE_ID = 'CHAT' and DZT_Name = 'OwnerChat'
	left join CTL_DOC P on P.id = c.IdHeader and P.TipoDoc='PDA_MICROLOTTI'
	left join Document_Bando B on B.idHeader = P.LinkedDoc
where d.TipoDoc='SEDUTA_VIRTUALE'

GO
