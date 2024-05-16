USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONVENZIONE_CHIUDI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_CONVENZIONE_CHIUDI] as

select 
	 id_row as iddoc
	,'I' as LNG
	, convert( varchar , C.DataIns , 103 ) as DataInvio
	,C2.Protocollo as ProtocolloRiferimento
	,NumOrd as numeroconvenzione
	, Motivazione
	,DescrizioneEstesa as OggettoConvenzione

from
	Document_Convenzione_Azioni C 
	inner join CTL_DOC C2 on C2.id=C.idHeader and C2.tipodoc='CONVENZIONE'
	inner join Document_convenzione DC on DC.id=C2.id




GO
