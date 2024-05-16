USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ODC_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











--select NotEditable, * from document_odc where rda_id = 63325
--select NotEditable,docRichiestaCig, * from Document_ODC_view where rda_id = 63326
--exec REFRESH_VISTE


CREATE view [dbo].[Document_ODC_view] as
	--Versione=2&data=2012-07-04&Attivita=38848&Nominativo=Sabato
	--Versione=3&data=2014-10-22&Attivita=64672&Nominativo=Enrico
	select 
		o.RDA_ID, o.RDA_Owner, o.RDA_Name, o.RDA_DataCreazione, o.RDA_Protocol, o.RDA_Object,  o.RDA_Stato, o.RDA_AZI, o.RDA_Plant_CDC, o.RDA_Valuta, o.RDA_InBudget, o.RDA_BDG_Periodo, o.RDA_Deleted, o.RDA_BuyerRole, o.RDA_ResidualBudget, o.RDA_CEO, o._RDA_SOCRic, o._RDA_PlantRic, o.RDA_MCE, o.RDA_DataScad, o.RDA_Utilizzo, o.RDA_Type, o.RDA_IT, o.RDA_Origin_InBudget, o.RDAC_Type, o.TipoInvestimento, o.PayBack, o.ROI, o.IRR, o.TotalEURO, o.RDA_FirstApprover, o.Emergenza, o.Ratifica, o.DataRatifica, o.idPfuRatifica, o.Allegato, o.RDA_Fornitore, o.NumeroFattura, o.J_DataConsegna, o.RDA_TypeApp, o.RDA_OLD_DOC_RDA_ID, o.RDA_OLD_DOC_TYPE, o.Utente, o.Plant, o.IVA, o.IdAziDest, o.ImpegnoSpesa, o.TotalIva, o.ODC_PEG, o.Capitolo, o.NumeroConvenzione, o.ReferenteConsegna, o.ReferenteIndirizzo, o.ReferenteTelefono, o.ReferenteEMail, o.ReferenteRitiro, o.IndirizzoRitiro, o.TelefonoRitiro, o.Id_Convenzione, o.RitiroEMail, o.RefOrd, o.RefOrdInd, o.RefOrdTel, o.RefOrdEMail, o.RDP_DataPrevCons, o.TipoOrdine, o.NoMail, o.Id_Preventivo, o.AllegatoConsegna, o.TipoImporto, o.FuoriPiattaforma, 
		CT.SIGN_HASH, CT.SIGN_ATTACH, CT.SIGN_LOCK
		 , isnull( RichiediFirmaOrdine , '' ) as RichiediFirmaOrdine

		 , pfuNome
		 , pfuRuoloAziendale

		 , round (o.RDA_Total, 2)	AS RDA_Total
		 , o.TotalIva - o.RDA_Total	AS ValoreIva 
		 , o.Id_Convenzione			AS Convenzione
		 , isnull( QtMinTot , 0 ) as QtMinTot
		 , 'ODC' as OPEN_DOC_NAME
		 , isnull( i.ImportoQuota - i.ImportoSpesa ,0 ) as ImportoQuota 
		 , CT.id
		 , CT.StatoFunzionale
		 , CT.idPfuInCharge
		 , CT.IdPfu
		 , cast (CT.Deleted as int) as deleted
		 , CT.JumpCheck
		 , CT.Protocollo
		 , CT.DataInvio

		 -- solo gli odc nuovi possono fare cichiesta cig. 
		 -- se è stata fatta una richiesta cig non si può cambiar e il rup ed il CIG_MADRE ( bisogna prima annullare la richiesta cig )
		 ,  case when isnull(O.IdDocIntegrato,0) <> 0 or isnull(o.IdDocRidotto,0) <> 0 then ' RichiestaCigSimog idpfuRup Obbligo_Cig_Derivato Motivazione_ObbligoCigDerivato ' 
				 when rCig.Id is not null then ' idpfuRup CIG_MADRE' 
				 else ''
			end 

			+ isnull(o.NotEditable,'') 

			+ case when o.RichiestaCigSimog = 'si' or dbo.attivo_INTEROP_Gara(CT.id)=1 then ' CIG ' else '' end

			+ case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + CT.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
				else ''
			   end

			--se attivo PCP blocco RichiestaCigSimog
			+ case when dbo.attivo_INTEROP_Gara(CT.id)=1 then ' RichiestaCigSimog ' else '' end

			as NotEditable

		 , CT.Titolo
		 , CT.Note
		 , CT.TipoDoc	
		 , O.CIG
		 , C.GestioneQuote
		 , case when isnull(  o.CIG_MADRE , '' ) = '' then  C.CIG_MADRE else o.CIG_MADRE end as CIG_MADRE
		 , isnull(O.EsistonoIntegrazioni,'0') as EsistonoIntegrazioni
		 , isnull(O.IdDocIntegrato,0) as IdDocIntegrato
		 , case isnull(O.IdDocIntegrato,0)
			when 0 then 'Ordinativo di Fornitura'
			else 'Ordinativo di fornitura Integrativo'
		   end as Caption
		, isnull(OrdinativiIntegrativi,0) as OrdinativiIntegrativi
		, TipoScadenzaOrdinativo
		, case isnull(c.NumeroMesi,0)
			when 0 then o.NumeroMesi
			else  c.NumeroMesi
		  end as NumeroMesi	
		, case 
			when getdate() >= o.RDA_DataScad then 'si'
			else 'no'
		  end as OrdinativoScaduto
		, case 
			when getdate() >= DataFine then 'si'
			else 'no'
		  end as ConvenzioneScaduta
		, o.UserRup as UserRulePO
		, prot.protocolloGeneraleSecondario 
		, prot.dataProtocolloGeneraleSecondario 
		, ct.ProtocolloGenerale
		, ct.DataProtocolloGenerale
		, isnull(o.IdDocRidotto,0) as IdDocRidotto
		, case when O.EsistonoIntegrazioni = '1' then 1 else 0 end as bIntegrato	--flag per indicare se mi trovo su un ODC che è stato integrato da un ordinativo integrativo

		--abilito simog solo se PCP non attivo
		, case when dbo.attivoSimog() = 1 and dbo.attivo_INTEROP_Gara(CT.id)=0  then 1 else 0 end as simog 
		
		--se attivo PCP setto RichiestaCigSimog=no
		, case when dbo.attivo_INTEROP_Gara(CT.id)=1 then 'no' else o.RichiestaCigSimog end as  RichiestaCigSimog
		
		, case when rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' ) then '1' else '0' end as cigInviato
		, case when rCig.StatoFunzionale in ( 'Inviato' , 'InvioInCorso' ) then 1 else 0 end as docRichiestaCig
		, o.idpfuRup
		
		--, o.obbligo_cig_derivato a si se attivo interop 
		, case when dbo.attivo_INTEROP_Gara(CT.id)=1 then 'si' else o.obbligo_cig_derivato end as  obbligo_cig_derivato
		, o.motivazione_obbligocigderivato
		
		,  dbo.attivo_INTEROP_Gara(CT.id)  as attivo_INTEROP_Gara

		, isnull(PCP.pcp_TipoScheda,'') as pcp_TipoScheda

		, isnull(StatoScheda,'') as StatoSchedaPCP 

	from ctl_doc CT with(nolock)
			inner join	Document_ODC o with(nolock) on CT.ID=O.RDA_ID
			inner join Document_convenzione c with(nolock) on c.id = o.id_convenzione
			left outer join  ProfiliUtente a with(nolock) on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
			--left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
			left outer join Document_Convenzione_Quote_Importo i with(nolock) on i.idHeader = c.id and i.Azienda = a.pfuidazi		

			left join Document_dati_protocollo prot with(nolock) ON prot.idheader = ct.id 

			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = CT.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori', 'InvioInCorso' )
			
			cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 

			left join Document_PCP_Appalto PCP with (nolock) on PCP.idHeader = CT.id 
			left join Document_PCP_Appalto_Schede PCP_SCHEDE with (nolock) on PCP_SCHEDE.idHeader = CT.id and tipoScheda = isnull(PCP.pcp_TipoScheda,'') and bDeleted = 0
			

	where CT.TipoDoc='ODC'



GO
