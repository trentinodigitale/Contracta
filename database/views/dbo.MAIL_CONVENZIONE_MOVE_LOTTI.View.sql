USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONVENZIONE_MOVE_LOTTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_CONVENZIONE_MOVE_LOTTI] as

select 
	 C.id as iddoc
	,'I' as LNG
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C.Protocollo
	,dbo.get_lotti_documento( IdHeader  ,'CONVENZIONE_MOVE_LOTTI') as elenco_LOTTI
	
from
	ctl_doc C 
	inner join ctl_doc_value  on dse_id='INFO_AGGIUNTIVE' and DZT_Name='Id_doc_Trasferimento_Lotto' and Value=C.id
where C.tipodoc='CONVENZIONE_MOVE_LOTTI'
GO
