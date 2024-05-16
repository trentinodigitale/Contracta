USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ORDINE_DA_ODC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[MAIL_ORDINE_DA_ODC] as
select document_ordine.id as iddoc , IdMsg, iType, iSubType, DataIns, document_ordine.NumOrd, document_ordine.Protocol, StatoOrdine, StateOrder,
document_ordine.Plant,Name, IdDestinatario,IdAziDest,IdMittente,Nota,FlagSituazione,STOrderCode,document_ordine.Deleted,document_ordine.Total,document_ordine.Valuta,document_ordine.IVA,ImpegnoSpesa,
TotalIva,ODC_PEG,Capitolo,NumeroConvenzione,ReferenteConsegna,ReferenteIndirizzo,ReferenteTelefono,ReferenteEMail,
ReferenteRitiro,IndirizzoRitiro,TelefonoRitiro,Id_Convenzione,RitiroEMail,RefOrd,RefOrdInd,RefOrdTel,RefOrdEMail,
document_ordine.RicPropBozza, convert(varchar(10),dbo.Document_ordine.RDP_DataPrevCons,105) as RDP_DataPrevCons, lngSuffisso as LNG ,
document_convenzione.DOC_Name as Oggetto
from document_ordine , lingue, document_convenzione
where Id_Convenzione = document_convenzione.Id




GO
