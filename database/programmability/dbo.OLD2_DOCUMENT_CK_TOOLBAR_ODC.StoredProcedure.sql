USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_ODC]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_ODC] 
(
	@DocName NVARCHAR(500),
	@IdDoc NVARCHAR(500),
	@idUser INT
)
AS

BEGIN

	SET NOCOUNT ON

	DECLARE @deleted INT = 0
	DECLARE @StatoFunzionale varchar(200) = ''
	
	DECLARE @attivo_INTEROP_Gara as int
	DECLARE @pcp_TipoScheda as varchar(100) = ''
	DECLARE @pcp_StatoScheda as varchar(100) = ''
	DECLARE @pcp_CodiceAppalto varchar(500)
	DECLARE @confermaAppalto varchar(10) = '0'
	DECLARE @viewConfermaAppalto varchar(10) = '0'
	DECLARE @cancellaAppalto varchar(10) = '0'
	DECLARE @viewCancellaAppalto varchar(10) = '0'
	DECLARE @recuperaCIG varchar(10) = '0'
	DECLARE @viewRecuperaCIG varchar(10) = '0'
	DECLARE @menuPCP varchar(10) = '0'
	DECLARE @viewMenuPCP varchar(10) = '0'
	DECLARE @UserRup int
	DECLARE @send_ODC_PCP varchar(10) = '1'

	
	

	--RECUPERO SE ATTIVO LA PCP SU ODC
	set @attivo_INTEROP_Gara = dbo.attivo_INTEROP_Gara(@IdDoc)

	--METTO I DATI DELLA CTL_DOC IN UNA TEMP PER USARLI IN SEGUITO SENZA RIFARE LA QUERY IN LINEA
	select 
		*
		into 
			#ODC
		from 
			CTL_DOC with (nolock) where Id = @IdDoc
	
	--	METTO I DATI DELLA DOCUMENT_ODC IN UNA TEMP PER USARLI IN SEGUITO SENZA RIFARE LA QUERY INLINEA
	select 
		*
		into 
			#ODC_DETT
		from 
			Document_ODC with (nolock) where RDA_ID = @IdDoc


	--recupero dati dalla CTL_DOC inserendole in variabili di appoggio
	SELECT 	
		@StatoFunzionale = StatoFunzionale,
		@deleted = deleted
	FROM #ODC 

	select 
		@UserRup = UserRUP 
		from 
			#ODC_DETT

	
	-------------------------------------
	------ GESTIONE DEI COMANDI PCP -----
	-------------------------------------
	IF @attivo_INTEROP_Gara = 1
	BEGIN
		
		--RECUPERO TIPO SCHEDA PCP
		SELECT  @pcp_TipoScheda = pcp_TipoScheda,
				@pcp_CodiceAppalto = pcp_CodiceAppalto
			FROM Document_PCP_Appalto with(nolock)
			WHERE idHeader=@IdDoc

		SELECT top 1 @pcp_StatoScheda = statoScheda
			FROM Document_PCP_Appalto_Schede with(nolock)
			WHERE idHeader = @IdDoc and bDeleted = 0 and tipoScheda = @pcp_TipoScheda
			ORDER BY idRow desc
		
		set @menuPCP = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) and @UserRup = @idUser then '1' else '0' end
		set @viewMenuPCP = case when @deleted = '0' and @pcp_TipoScheda <> '' then '1' else '0' end


		--CONFERMA APPALTO : '', 'ErroreCreazione', 'AppaltoCancellato' -- farlo sparire per gli affidamenti diretti
		--		per gestire il pregresso ( gare che non avevano la gestione dello stato scheda ) - Conferma Appalto : se pcp_codiceAppalto è valorizzato si disattiva
		set @confermaAppalto = case when @StatoFunzionale IN ( 'InLavorazione','InApprove' )  and @UserRup = @idUser
											and 
										( 
											@pcp_StatoScheda in ( '', 'ErroreCreazione', 'AppaltoCancellato' ) --gestione pulita per stato scheda
												OR 
											( @pcp_StatoScheda = '' and isnull(@pcp_codiceAppalto,'') = '' ) --gestione per la retrocompatibilità
										) 
									then '1' 
									else '0' 
								end

		set @viewConfermaAppalto = case when @deleted = '0' then '1' else '0' end --se gara interop, non AD, non seconda fase interop

		--CANCELLA APPALTO : 'Creato', 'Confermato', 'AP_IN_CONF','AP_N_CONF', 'AP_CONF_MAX_RETRY' -- farlo sparire per la scheda P7_2 -- per gli AD farlo comparire solo dopo aver creato l'appalto ?
		--		per la retrocompatibilità : Cancella Appalto : se pcp_codiceAppalto è valorizzato si attiva e la select per la sentinella di pubblicaAvviso NON deve avere esito positivo
		--	evo: il cancella appalto non si può fare solo se l'appalto è pubblicato lato anac, altrimenti si. quindi aggiungo gli stati coerenti con questa cosa
		set @cancellaAppalto = case when @StatoFunzionale IN ( 'InLavorazione','InApprove' )  and @UserRup = @idUser
											AND
										  ( @pcp_StatoScheda in ( 'Creato', 'Confermato', 'AP_CONF', 'AP_IN_CONF','AP_N_CONF', 'AP_CONF_MAX_RETRY', 'AP_CONF_NO_ESITO', 'CigRecuperati', 'ErroreCigRecuperati' ) --gestione pulita per stato scheda
													OR 
											    ( @pcp_StatoScheda = '' and isnull(@pcp_codiceAppalto,'') <> ''  ) 
											)	then '1' 
												else '0' 
									 end 

		set @viewCancellaAppalto = case when ( @pcp_TipoScheda =  '' or  isnull(@pcp_codiceAppalto,'') = ''  ) and @UserRup = @idUser
										 then '0' else '1' 
									end --faccio sparire il comando di cancella se non c'è il tipo scheda o SENZA codice appalto 

		--Recupera Cig 	 : 'ErroreCigRecuperati'
		set @recuperaCIG = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) and @UserRup = @idUser
									and @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end 
		set @viewRecuperaCIG = case when  @deleted = '0' or @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end

		--Invio al fornitore. Permettere il click quando : 
		IF @pcp_TipoScheda <> ''  and @pcp_StatoScheda = 'CigRecuperati'  --  prevede l'invio di una scheda/appalto, con stato 'CigRecuperati' se sono su una scheda che non prevede la pubblicazione avviso
		BEGIN
			SET @send_ODC_PCP = '1'
		END
		ELSE
		BEGIN
			SET @send_ODC_PCP = '0'
		END

	END

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

			+ case when --o.RichiestaCigSimog = 'si' or 
					--dbo.attivo_INTEROP_Gara(CT.id)=1 
					
					-- ho il parametro per renderla non editabile -- il default è non editabile
					dbo.PARAMETRI('ODC_DOCUMENT','CIG','Editable','0',-1) = '0'
					then ' CIG ' else '' end

			+ case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + CT.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
				else ''
			   end

			--se attivo PCP blocco RichiestaCigSimog,Obbligo_Cig_Derivato e Motivazione_ObbligoCigDerivato
			+ case when dbo.attivo_INTEROP_Gara(CT.id)=1 then ' RichiestaCigSimog Obbligo_Cig_Derivato Motivazione_ObbligoCigDerivato ' else '' end

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
		
		--, o.UserRup as UserRulePO
		, @UserRup as  UserRulePO
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
		
		,  @attivo_INTEROP_Gara  as attivo_INTEROP_Gara

		--, isnull(PCP.pcp_TipoScheda,'') as pcp_TipoScheda
		, @pcp_TipoScheda AS pcp_TipoScheda

		--, isnull(StatoScheda,'') as StatoSchedaPCP 
		, @pcp_StatoScheda as StatoSchedaPCP

		-- COLONNE UTILI AL MENU PCP E A FAR EVOLVERE LE LOGICHE DI ATTIVAZIONE DEL COMANDO DI 'INVIA AL FORNITORE'
		, @menuPCP as menuPCP
		, @viewMenuPCP as viewMenuPCP

		, @confermaAppalto as pcp_confermaAppalto
		, @viewConfermaAppalto as pcp_viewConfermaAppalto

		, @cancellaAppalto as pcp_cancellaAppalto
		, @viewCancellaAppalto as pcp_viewCancellaAppalto

		, @recuperaCIG as pcp_recuperaCIG
		, @viewRecuperaCIG as pcp_viewRecuperaCIG
		
		, @send_ODC_PCP as send_ODC_PCP
		, @pcp_codiceAppalto as pcp_codiceAppalto
	from 
		--ctl_doc CT with(nolock)
		#ODC  CT
			--inner join	Document_ODC o with(nolock) on CT.ID=O.RDA_ID
			inner join #ODC_DETT O on CT.ID=O.RDA_ID
			
			inner join Document_convenzione c with(nolock) on c.id = O.id_convenzione
			
			left outer join  ProfiliUtente a with(nolock) on RDA_Owner = CAST(a.IdPfu AS VARCHAR)
			--left outer join Document_Convenzione_Quote_Importo i on i.idHeader = c.id and cast( i.Azienda as varchar(15)) = left( o.Plant , len( i.Azienda  )) --a.pfuidazi
			
			left outer join Document_Convenzione_Quote_Importo i with(nolock) on i.idHeader = c.id and i.Azienda = a.pfuidazi		

			left join Document_dati_protocollo prot with(nolock) ON prot.idheader = ct.id 

			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = CT.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori', 'InvioInCorso' )
			
			cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 

			--left join Document_PCP_Appalto PCP with (nolock) on PCP.idHeader = CT.id 
			--left join Document_PCP_Appalto_Schede PCP_SCHEDE with (nolock) on PCP_SCHEDE.idHeader = CT.id and tipoScheda = isnull(PCP.pcp_TipoScheda,'') and bDeleted = 0
			

	where  CT.Id=@IdDoc
		
END





GO
