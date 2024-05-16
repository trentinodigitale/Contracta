USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONVENZIONI_MONITOR_FORN]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_CONVENZIONI_MONITOR_FORN]
AS
SELECT D.Id
     , P.IdPfu                         AS DOC_Owner
     , DOC_Name
     , DataCreazione
     , Protocol
     , DescrizioneEstesa
     , StatoConvenzione
     , Plant
     , AZI_Dest
     , NumOrd
     , Imballo
     , Resa
     , Spedizione
     , Pagamento
     , Valuta
     , Total
     , Completo
     , Allegato
     , Telefono
     , Compilatore
     , RuoloCompilatore
     , TipoOrdine
     , SendingDate
     , ProtocolloBando
     , DataInizio
     , DataFine
     , Merceologia
     , TotaleOrdinato
     , IVA
     , NewTotal
     , ISNULL(Total, 0) - ISNULL(TotaleOrdinato, 0) AS BDG_TOT_Residuo 
	 , 'CONVENZIONE_OE' as OPEN_DOC_NAME
	 , StatoFunzionale
  FROM CTL_DOC C
		inner join Document_Convenzione D on C.id=D.id
		inner join ProfiliUtente P on D.Azi_Dest = P.pfuIdAzi
  where C.deleted=0 and C.tipodoc='Convenzione' and ISNULL(C.JumpCheck,'') <> 'INTEGRAZIONE'




GO
