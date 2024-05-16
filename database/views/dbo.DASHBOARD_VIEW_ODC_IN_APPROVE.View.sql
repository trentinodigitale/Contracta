USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ODC_IN_APPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_ODC_IN_APPROVE] AS

SELECT RDA_Id
     , APS_IDPFU as RDA_Owner
     , Capitolo
     , Id_Convenzione
     , IdAziDest
     , ImpegnoSpesa
     , IndirizzoRitiro
     , o.IVA
     , NumeroConvenzione
     , ODC_PEG
     , pfuNome
     , pfuRuoloAziendale
     , o.Plant
     , RDA_AZI
     , RDA_BDG_Periodo
     , RDA_DataCreazione
     , RDA_Name
     , RDA_Object
     , RDA_Protocol
     , RDA_ResidualBudget
     , RDA_Stato
     , round (RDA_Total, 2) as RDA_Total
     , RDA_TYPE
     , RDA_Valuta
     , RDP_DataPrevCons
     , ReferenteConsegna
     , ReferenteEMail
     , ReferenteIndirizzo
     , ReferenteRitiro
     , ReferenteTelefono
     , RefOrd
     , RefOrdEMail
     , RefOrdInd
     , RefOrdTel
     , RitiroEMail
     , TelefonoRitiro
     , TotalIva 
     , TotalIva - RDA_Total                     AS ValoreIva 
     , Id_Convenzione                           AS Convenzione
	 , o.TipoOrdine
	 , NoMail
	 ,isnull( QtMinTot , 0 ) as QtMinTot
	 ,AllegatoConsegna 
	 , o.TipoImporto
     , 'ODC_IN_APPROVA' as OPEN_DOC_NAME
	 , isnull( i.ImportoQuota - i.ImportoSpesa ,0 ) as ImportoQuota 
	 , SIGN_HASH
	 , SIGN_ATTACH
	 , SIGN_LOCK
	 , RichiediFirmaOrdine 

  FROM Document_ODC o
     inner join  ProfiliUtente a on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
	 inner join Document_Convenzione c on Id_Convenzione = c.ID
	 left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
	 inner join CTL_APPROVALSTEPS on APS_ID_DOC=RDA_Id
 WHERE 
   RDA_Deleted = ' '
   AND RDA_Stato = 'Saved' and APS_State='InCharge'
GO
