USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONTRATTO_CONVENZIONI_TESTATA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[DASHBOARD_VIEW_CONTRATTO_CONVENZIONI_TESTATA] as
select  
	DC.ID, 
	DC.DOC_Owner, 
	DC.DOC_Name, 
	DC.DataCreazione, 
	DC.Protocol, 
	DC.DescrizioneEstesa, 
	DC.StatoConvenzione, 
	DC.AZI, 
	DC.Plant, 
	DC.Deleted, 
	DC.AZI_Dest, 
	DC.NumOrd, 
	DC.Imballo, 
	DC.Resa, 
	DC.Spedizione, 
	DC.Pagamento, 
	DC.Valuta, 
	DC.Total, 
	DC.Completo,
	DC.Allegato, 
	DC.Telefono, 
	DC.Compilatore, 
	DC.RuoloCompilatore, 
	DC.TipoOrdine, 
	DC.SendingDate, 
	DC.ProtocolloBando, 
	DC.DataInizio, 
	DC.DataFine, 
	DC.Merceologia, 
	DC.TotaleOrdinato, 
	DC.IVA, 
	DC.NewTotal, 
	DC.RicPropBozza, 
	DC.ConvNoMail, 
	DC.QtMinTot, 
	DC.RicPreventivo, 
	DC.TipoImporto, 
	DC.TipoEstensione, 
	DC.RichiediFirmaOrdine	,
	DC.ID as LinkedDoc, 
	isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
	, DC.IdRow
	,DC.DataProtocolloBando
	,DC.OggettoBando
	,DC.Mandataria
	,DC.ProtocolloListino
	,DC.ProtocolloContratto
	,DC.ReferenteFornitore
	,DC.CodiceFiscaleReferente
	,DC.ReferenteFornitoreHide
	,DC.Ambito
	,DC.GestioneQuote
	,ISNULL(DC.NotEditable,'') as NotEditable
 from ctl_doc c
	inner join Document_Convenzione DC on C.id=DC.id
where DC.Deleted = 0 and C.Deleted = 0 and C.tipodoc='CONTRATTO_CONVENZIONE'





GO
