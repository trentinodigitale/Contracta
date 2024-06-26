USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_CONVENZIONE_PRZ_PRODOTTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_MAIL_CONVENZIONE_PRZ_PRODOTTI] as

select 
	 C.id as iddoc
	,'I' as LNG
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C2.Protocollo as ProtocolloRiferimento
	,NumOrd as numeroconvenzione
	,CV.value as Motivazione
	 ,dbo.GetDateDDMMYYYY(CV1.value) as DataDecorrenza
	,DescrizioneEstesa as OggettoConvenzione
	,dbo.get_prodotti_documento_PRZ( C.id ,'CONVENZIONE_PRZ_PRODOTTI','si') as elenco
	,dbo.get_prodotti_documento_PRZ( C.id ,'CONVENZIONE_PRZ_PRODOTTI','no') as elenco_NOT_CHANGE
from
	ctl_doc C 
	inner join CTL_DOC C2 on C2.id=C.LinkedDoc and C2.tipodoc='CONVENZIONE'
	inner join Document_convenzione DC on DC.id=C2.id
	inner join ctl_doc_value CV on CV.idheader=C.id and CV.DSE_ID='MOTIVAZIONE' and CV.dzt_name='MOtivazione'
	inner join ctl_doc_value CV1 on CV1.idheader=C.id and CV1.DSE_ID='MOTIVAZIONE' and CV1.dzt_name='DataDecorrenza'
where C.tipodoc='CONVENZIONE_PRZ_PRODOTTI'
GO
