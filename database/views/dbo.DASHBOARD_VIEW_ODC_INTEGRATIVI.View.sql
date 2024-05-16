USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ODC_INTEGRATIVI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[DASHBOARD_VIEW_ODC_INTEGRATIVI] AS
--Versione=1&data=2017-05-10&Attivita=151220&Nominativo=Enrico
SELECT RDA_Id
     ,	RDA_Owner
     , Capitolo
     , Id_Convenzione
     , IdAziDest
	 , IdAziDest as Azi_Dest
     , ImpegnoSpesa
     , IndirizzoRitiro
     , o.IVA
     , NumeroConvenzione
     , ODC_PEG
     , a.pfuNome
     , a.pfuRuoloAziendale
     , o.Plant
     , RDA_AZI
     , RDA_BDG_Periodo
     , RDA_DataCreazione
     , Titolo
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
	 , c.TipoImporto
     , 'ODC' as OPEN_DOC_NAME
	 , isnull( i.ImportoQuota - i.ImportoSpesa ,0 ) as ImportoQuota 
	 , C1.SIGN_HASH
	 , C1.SIGN_ATTACH
	 , C1.SIGN_LOCK
	 , RichiediFirmaOrdine 
	 , isnull( attvalue,'') as UserRole
	 , StatoFunzionale
	 , C1.IdPfu
	 , RDA_IdRow
	 , o.UserRUP
	 , isnull(O.NotEditable,'') as NotEditable
	 , C1.azienda
	 , Az.aziragionesociale	
	 , ReferenteStato
	 , ReferenteProvincia
	 , ReferenteLocalita
	 , ReferenteCap
	 , ReferenteStato2
	 , ReferenteProvincia2
	 , ReferenteLocalita2
	 , FatturazioneStato
	 , FatturazioneProvincia
	 , FatturazioneLocalita
	 , FatturazioneCap
	 , FattuarzioneStato2
	 , FatturazioneLocalita2
	 , FatturazioneProvincia2
     , idPfuInCharge
	 , TipoDoc
	 , DataInvio as Data
	 , C1.Protocollo
	 , IdDocIntegrato
	 , O.Allegato
	 , codiceIPA
	 --, convert( varchar(10) , DataInvio , 121 ) as DataA
	 --, convert( varchar(10) , DataInvio , 121 ) as DataI
	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataA
	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataI
	 ,RDA_DataScad
	 , TotaleEroso
	 , TotalIvaEroso
     , TotalIvaEroso - TotaleEroso                     AS ValoreIvaEroso 

	, case 
		when isnull(O.IdDocIntegrato,0) > 0 then 'si'
		else 'no'
	  end as Multiplo
	  , c.IdentificativoIniziativa
	  , c.DataStipulaConvenzione
	  ,c.NumOrd
  
  FROM 

	 ctl_doc C1
	 inner join	Document_ODC O on O.rda_id=C1.id 
	 inner join  ProfiliUtente a on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
	 inner join aziende AZ on AZ.idazi=a.pfuidazi	
	 inner join profiliutenteattrib PA on C1.idpfu=PA.idpfu and dztnome='UserRoleDefault'
	 inner join Document_Convenzione c on Id_Convenzione = c.ID
	 left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and i.Azienda = a.pfuidazi
	
 WHERE 
	C1.TipoDoc='ODC'
	AND C1.deleted=0
	
	












GO
