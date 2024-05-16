USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONVENZIONE_DEL_PRODOTTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_CONVENZIONE_DEL_PRODOTTI] as

select 
	 C.id as iddoc
	,'I' as LNG
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C2.Protocollo as ProtocolloRiferimento
	,NumOrd as numeroconvenzione
	,value as Motivazione
	,DescrizioneEstesa as OggettoConvenzione
	,dbo.get_prodotti_documento( C.id ,'CONVENZIONE_DEL_PRODOTTI') as elenco
from
	ctl_doc C 
	inner join CTL_DOC C2 on C2.id=C.LinkedDoc and C2.tipodoc='CONVENZIONE'
	inner join Document_convenzione DC on DC.id=C2.id
	inner join ctl_doc_value on idheader=C.id and DSE_ID='MOTIVAZIONE' and dzt_name='MOtivazione'
where C.tipodoc='CONVENZIONE_DEL_PRODOTTI'


GO
