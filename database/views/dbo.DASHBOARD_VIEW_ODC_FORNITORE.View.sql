USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ODC_FORNITORE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_ODC_FORNITORE] AS
--Versione=2&data=2012-06-27&AttvitRichiediFirmaOrdinea=38848&Nominativo=Sabato
SELECT RDA_Id
     , RDA_Owner
     , Capitolo
     , Id_Convenzione
     , IdAziDest
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
	 , o.TipoImporto
     , 'ODC_FORNITORE' as OPEN_DOC_NAME
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
	 , cast(  Az.idazi as varchar(20)) as AZI_Ente
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
     , OE.idpfu as idPfuInCharge
	 , TipoDoc
 	 , DataInvio as Data
 	 , convert( varchar(10) , DataInvio ,121 ) as DataA
	 , convert( varchar(10) , DataInvio ,121 ) as DataF
	 , C1.Protocollo
	 , o.RDA_DataScad
	 , RDA_DataCreazione as DataI
	 , c1.Destinatario_Azi as AZI_Dest
	 ,c.NumOrd
	 , case 
		when isnull(O.IdDocIntegrato,0) > 0 then 'si'
		else 'no'
	  end as Multiplo,
	  C1.note
  FROM 
	 ctl_doc C1
	 inner join	Document_ODC O on O.rda_id=C1.id 
     inner join Document_Convenzione c on Id_Convenzione = c.ID
	 inner join  ProfiliUtente a on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
	 inner join aziende AZ on AZ.idazi=a.pfuidazi	
	 inner join profiliutenteattrib PA on C1.idpfu=PA.idpfu and dztnome='UserRoleDefault'
	 --left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
	 left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and i.Azienda = a.pfuidazi
	 inner join profiliutente OE on OE.pfuidazi=Destinatario_azi
	
 WHERE 
	C1.TipoDoc='ODC'
	--AND C1.deleted=0
	--AND RDA_Deleted = ' '
	--AND RDA_Stato = 'Saved'
	--255 permesso OE e 260 permesso Ente
	--and ( substring(OE.pfufunzionalita,255,1)='1' or substring(a.pfufunzionalita,260,1)='1')
	and C1.statofunzionale in ('Inviato','Accettato','Rifiutato','Annullato')
	and  substring(OE.pfufunzionalita,255,1)='1'





GO
