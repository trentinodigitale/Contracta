USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_ODA_view]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_Document_ODA_view]
AS
	SELECT  
		 o.idHeader
		 , o.TotalEURO
		 , o.RDA_FirstApprover
		 , o.Emergenza
		 , o.Allegato
		 , o.NumeroFattura
		 , o.J_DataConsegna
		 , o.IVA
		 , o.ImpegnoSpesa
		 , o.TotalIva
		 , o.ReferenteConsegna
		 , o.ReferenteIndirizzo
		 , o.ReferenteTelefono
		 , o.ReferenteEMail
		 , o.ReferenteRitiro
		 , o.IndirizzoRitiro
		 , o.TelefonoRitiro
		 , o.Id_Convenzione
		 , o.RitiroEMail
		 , o.RefOrd
		 , o.RefOrdInd
		 , o.RefOrdTel
		 , o.RefOrdEMail
		 , o.RDP_DataPrevCons
		 , o.TipoOrdine
		 , o.NoMail
		 , o.AllegatoConsegna
		 , o.TipoImporto 
		 , CT.SIGN_HASH
		 , CT.SIGN_ATTACH 
		 , CT.SIGN_LOCK		 
		 , pfuNome
		 , pfuRuoloAziendale
		 , o.TotalIva - o.TotaleEroso	AS ValoreIva 
		 , o.Id_Convenzione			AS Convenzione	
		 , 'ODA' as OPEN_DOC_NAME		 
		 , CT.id
		 , CT.StatoFunzionale
		 , CT.idPfuInCharge
		 , CT.IdPfu
		 , cast (CT.Deleted as int) as deleted
		 , CT.JumpCheck
		 , CT.Protocollo
		 , CT.DataInvio
		
		 ,  case when isnull(O.IdDocIntegrato,0) <> 0 or isnull(o.IdDocRidotto,0) <> 0 then ' RichiestaCigSimog idpfuRup Obbligo_Cig_Derivato Motivazione_ObbligoCigDerivato ' 
				 when rCig.Id is not null then ' idpfuRup CIG_MADRE' 
				 else ''
			end 

			+ isnull(o.NotEditable,'') 

			+ case when o.RichiestaCigSimog = 'si' then ' CIG ' else '' end

			+ case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + CT.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
				else ''
			   end

			as NotEditable

		, CT.Titolo
		, CT.Note
		, CT.TipoDoc	
		, O.CIG	
		, o.UserRup as UserRulePO
		, prot.protocolloGeneraleSecondario 
		, prot.dataProtocolloGeneraleSecondario 
		, ct.ProtocolloGenerale
		, ct.DataProtocolloGenerale
		, isnull(o.IdDocRidotto,0) as IdDocRidotto
		, case when O.EsistonoIntegrazioni = '1' then 1 else 0 end as bIntegrato	
		, case when dbo.attivoSimog() = 1 then 1 else 0 end as simog

		, o.RichiestaCigSimog
		, case when rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' ) then '1' else '0' end as cigInviato
		, case when rCig.StatoFunzionale in ( 'Inviato' , 'InvioInCorso' ) then 1 else 0 end as docRichiestaCig
		, o.idpfuRup
		, o.obbligo_cig_derivato
		, o.motivazione_obbligocigderivato
		,ct.Caption
		,ct.NumeroDocumento
		,ct.DataDocumento
		,o.CUP
	FROM CTL_DOC CT with(nolock)
			inner join	Document_ODA o with(nolock) on CT.ID=O.idHeader
			left outer join  ProfiliUtente a with(nolock) on a.IdPfu = ct.IdPfu 				
			left join Document_dati_protocollo prot with(nolock) ON prot.idheader = ct.id 
			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = CT.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori', 'InvioInCorso' )			
			cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 

	where CT.TipoDoc='ODA'
GO
