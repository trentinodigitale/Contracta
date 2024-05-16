USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ODC]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_ODC] AS
--Versione=2&data=2012-06-27&AttvitRichiediFirmaOrdinea=38848&Nominativo=Sabato
--Versione=3&data=2015-06-29&Attvità=77240&Nominativo=Enrico
--Versione=4&data=2018-05-14&Attvità=193078&Nominativo=Sabato
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
     , dbo.afs_round (RDA_Total, 2) as RDA_Total
	 --, RDA_Total
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
     , dbo.afs_round (TotalIva , 2) as TotalIva
     , dbo.afs_round (TotalIva , 2) - dbo.afs_round ( RDA_Total , 2)                    AS ValoreIva 
     , Id_Convenzione                           AS Convenzione
	 , o.TipoOrdine
	 , NoMail
	 ,isnull( QtMinTot , 0 ) as QtMinTot
	 ,AllegatoConsegna 
	 , c.TipoImporto
     , 'ODC' as OPEN_DOC_NAME
	
	 , case 
			when R.utente = 'COMPILATORE' then  isnull( i.ImportoQuota - i.ImportoSpesa ,0 ) 
			else 0
		end
		as ImportoQuota  ------------------------>
	 , C1.SIGN_HASH
	 , C1.SIGN_ATTACH
	 , C1.SIGN_LOCK
	 , RichiediFirmaOrdine 
	 --, isnull( attvalue,'') 
	 , case 
			when R.utente = 'COMPILATORE' then isnull( attvalue,'') 
			else ''
		end
	    as UserRole            --------------->

	 , StatoFunzionale
	 --, C1.IdPfu
	 
	 , case 
			when R.utente = 'COMPILATORE' then isnull( SUB.Value , C1.IdPfu ) 
			else O.UserRup 
		end
		as IdPfu     --------------->

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
	  , c.NumOrd
	  , O.TotaleValoreAccessorio
	  , PO_ORIGIN.value as PO_ORIGINARIO
	  , O.FuoriPiattaforma
	  , C1.StatoDoc
	  

  FROM 
	 ctl_doc C1 with( nolock ) 
	
		 inner join	Document_ODC O with( nolock ) on O.rda_id=C1.id 
		 --inner join  ProfiliUtente a with( nolock ) on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
		 --inner join  ProfiliUtente a with( nolock ) on cast(RDA_Owner as int) = a.IdPfu
		 left join  ProfiliUtente a with( nolock ) on o.UserRUP  = a.IdPfu
		 left join aziende AZ with( nolock ) on AZ.idazi=a.pfuidazi	
		 inner join profiliutenteattrib PA with( nolock ) on C1.idpfu=PA.idpfu and dztnome='UserRoleDefault'
		 inner join Document_Convenzione c with( nolock ) on C1.LinkedDoc = c.ID
		 --left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
		 left outer join Document_Convenzione_Quote_Importo i with( nolock ) on i.idHeader = c.id and i.Azienda = a.pfuidazi

		 -- subentro
		 left outer join ctl_doc_value  SUB with( nolock ) on SUB.DSE_ID='Subentro' and dzt_name = 'Subentro'  and c1.id = SUB.idheader 
		 --left outer join ( 
			--				select idpfu , id from CTL_DOC with( nolock ) where tipodoc = 'ODC'
			--				union 
			--				select value as idpfu , id 
			--					from CTL_DOC with( nolock ) 
			--						inner join ctl_doc_value  with( nolock ) on dzt_name = 'Subentro'  and id = idheader 
			--					where tipodoc = 'ODC' 
			--			  )	as SUB  on SUB.id = C1.id 
	


		  -- RUP
		  inner join ( select 'COMPILATORE' as utente union all select 'RUP' as utente ) as R on ( R.utente = 'COMPILATORE' ) or (  R.utente = 'RUP' and isnull( SUB.Value , C1.IdPfu ) <> O.UserRup and C1.statofunzionale <> 'InLavorazione' )
		 
		  --PO_ORIGINARIO
		  left outer join ctl_doc_value  PO_ORIGIN with( nolock ) on  PO_ORIGIN.DSE_ID='PO_ORIGINARIO' and PO_ORIGIN.dzt_name = 'PO_ORIGINARIO'  and c1.id = PO_ORIGIN.idheader 
 
 WHERE 
	C1.TipoDoc='ODC'
	AND C1.deleted=0
	--AND RDA_Deleted = ' '
	--AND RDA_Stato = 'Saved'
	--255 permesso OE e 260 permesso Ente
	--and ( substring(OE.pfufunzionalita,255,1)='1' or substring(a.pfufunzionalita,260,1)='1')
	--and  substring(a.pfufunzionalita,260,1)='1'

--union 

----gli utenti PO che ci hanno lavorato (UserRup)
--SELECT RDA_Id
--     ,	RDA_Owner
--     , Capitolo
--     , Id_Convenzione
--     , IdAziDest
--	 , IdAziDest as Azi_Dest
--     , ImpegnoSpesa
--     , IndirizzoRitiro
--     , o.IVA
--     , NumeroConvenzione
--     , ODC_PEG
--     , a.pfuNome
--     , a.pfuRuoloAziendale
--     , o.Plant
--     , RDA_AZI
--     , RDA_BDG_Periodo
--     , RDA_DataCreazione
--     , Titolo
--     , RDA_Object
--     , RDA_Protocol
--     , RDA_ResidualBudget
--     , RDA_Stato
--     , round (RDA_Total, 2) as RDA_Total
--     , RDA_TYPE
--     , RDA_Valuta
--     , RDP_DataPrevCons
--     , ReferenteConsegna
--     , ReferenteEMail
--     , ReferenteIndirizzo
--     , ReferenteRitiro
--     , ReferenteTelefono
--     , RefOrd
--     , RefOrdEMail
--     , RefOrdInd
--     , RefOrdTel
--     , RitiroEMail
--     , TelefonoRitiro
--     , TotalIva 
--     , TotalIva - RDA_Total                     AS ValoreIva 
--     , Id_Convenzione                           AS Convenzione
--	 , o.TipoOrdine
--	 , NoMail
--	 ,isnull( QtMinTot , 0 ) as QtMinTot
--	 ,AllegatoConsegna 
--	 , c.TipoImporto
--     , 'ODC' as OPEN_DOC_NAME
--	 --, isnull( i.ImportoQuota - i.ImportoSpesa ,0 ) as ImportoQuota 
--	 ,  0 as 	ImportoQuota
--	 , C1.SIGN_HASH
--	 , C1.SIGN_ATTACH
--	 , C1.SIGN_LOCK
--	 , RichiediFirmaOrdine 
--	 , '' as UserRole
--	 , StatoFunzionale
--	 , O.UserRup as IdPfu
--	 , RDA_IdRow
--	 , UserRUP
--	 , isnull(O.NotEditable,'') as NotEditable
--	 , C1.azienda
--	 , Az.aziragionesociale	
--	 , ReferenteStato
--	 , ReferenteProvincia
--	 , ReferenteLocalita
--	 , ReferenteCap
--	 , ReferenteStato2
--	 , ReferenteProvincia2
--	 , ReferenteLocalita2
--	 , FatturazioneStato
--	 , FatturazioneProvincia
--	 , FatturazioneLocalita
--	 , FatturazioneCap
--	 , FattuarzioneStato2
--	 , FatturazioneLocalita2
--	 , FatturazioneProvincia2
--     , idPfuInCharge
--	 , TipoDoc
--	 , DataInvio as Data
--	 , C1.Protocollo
--	 , IdDocIntegrato
--	 , O.Allegato
--	 , codiceIPA
--	 --, convert( varchar(10) , DataInvio , 121 ) as DataA
--	 --, convert( varchar(10) , DataInvio , 121 ) as DataI
--	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataA
--	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataI
--	 ,RDA_DataScad
--	 , TotaleEroso
--	 , TotalIvaEroso
--    , TotalIvaEroso - TotaleEroso                     AS ValoreIvaEroso 

--    , case 
--	   when isnull(O.IdDocIntegrato,0) > 0 then 'si'
--	   else 'no'
--    end a	  , c.IdentificativoIniziativa
--    , c.DataStipulaConvenzione
--    , c.NumOrd
--    , O.TotaleValoreAccessorio 

--  FROM 
--	 ctl_doc C1  with( nolock ) 
--	 inner join	Document_ODC O  with( nolock ) on O.rda_id=C1.id 
--     inner join  ProfiliUtente a  with( nolock ) on O.UserRup = CAST(a.IdPfu AS VARCHAR)
--	 inner join aziende AZ  with( nolock ) on AZ.idazi=a.pfuidazi	
--	 --inner join profiliutenteattrib PA on C1.IdPfuIncharge=PA.idpfu and dztnome='UserRoleDefault'
--	 inner join Document_Convenzione c  with( nolock ) on Id_Convenzione = c.ID
--	 --left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
--	 --left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and i.Azienda = a.pfuidazi
	
-- WHERE 
--	C1.TipoDoc='ODC'
--	AND C1.deleted=0
--	--AND RDA_Deleted = ' '
--	--AND RDA_Stato = 'Saved'
--	--255 permesso OE e 260 permesso Ente
--	--and ( substring(OE.pfufunzionalita,255,1)='1' or substring(a.pfufunzionalita,260,1)='1')
--	--and  substring(a.pfufunzionalita,260,1)='1'
--	and O.UserRup <> c1.idpfu

--	--per evitare che i rup vedano il documento quando è ancora in lavorazione presso chi lo ha creato
--	and C1.statofunzionale <> 'InLavorazione'




















GO
