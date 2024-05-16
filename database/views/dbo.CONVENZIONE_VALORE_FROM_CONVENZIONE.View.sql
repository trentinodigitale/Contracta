USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_VALORE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[CONVENZIONE_VALORE_FROM_CONVENZIONE] as 
select 
	  '' as TipoEstensione,
	  DC.total as Vaue_Originario,
	  C.id as ID_FROM ,
	  C.id as IdHeader
	  ,C.[ID]
      ,DC.[DOC_Owner]
      ,DC.[DOC_Name]
      ,DC.[DataCreazione]
      ,DC.[Protocol]
      ,DC.[DescrizioneEstesa]
      ,DC.[StatoConvenzione]
      ,DC.[AZI]
      ,DC.[Plant]
      ,DC.[Deleted]
      ,DC.[AZI_Dest]
      ,DC.[NumOrd]
      ,DC.[Imballo]
      ,DC.[Resa]
      ,DC.[Spedizione]
      ,DC.[Pagamento]
      ,DC.[Valuta]
      ,DC.[Total]
      ,DC.[Completo]
      ,DC.[Allegato]
      ,DC.[Telefono]
      ,DC.[Compilatore]
      ,DC.[RuoloCompilatore]
      ,DC.[TipoOrdine]
      ,DC.[SendingDate]
      ,DC.[ProtocolloBando]
      ,DC.[DataInizio]
      ,DC.[DataFine]
      ,DC.[Merceologia]
      ,DC.[TotaleOrdinato]
      ,DC.[IVA]
      ,DC.[NewTotal]
      ,DC.[RicPropBozza]
      ,DC.[ConvNoMail]
      ,DC.[QtMinTot]
      ,DC.[RicPreventivo]
      ,DC.[TipoImporto]
	  ,C.id as linkedDoc
	  ,C.protocollo as ProtocolloRiferimento
	  ,DC.[DescrizioneEstesa] as Body
	  ,'InLavorazione' as StatoFunzionale
from CTL_DOC C
inner join dbo.Document_Convenzione DC on DC.id=C.Id
where C.tipodoc='CONVENZIONE'





GO
