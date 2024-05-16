USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_ODA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_ODA] 
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
	DECLARE @send_ODA_PCP varchar(10) = '1'

	--RECUPERO SE ATTIVO LA PCP SU ODC
	set @attivo_INTEROP_Gara = dbo.attivo_INTEROP_Gara(@IdDoc)

	--METTO I DATI DELLA CTL_DOC IN UNA TEMP PER USARLI IN SEGUITO SENZA RIFARE LA QUERY IN LINEA
	select * into #ODA
		from CTL_DOC with (nolock)
		where Id = @IdDoc
	
	--	METTO I DATI DELLA DOCUMENT_ODC IN UNA TEMP PER USARLI IN SEGUITO SENZA RIFARE LA QUERY INLINEA
	select * into #ODA_DETT
		from Document_ODA with (nolock)
		where idHeader = @IdDoc

	--recupero dati dalla CTL_DOC inserendole in variabili di appoggio
	SELECT @StatoFunzionale = StatoFunzionale,
		   @deleted = deleted
		FROM #ODA

	select @UserRup = UserRUP
		from #ODA_DETT

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

		set @confermaAppalto = case when @StatoFunzionale IN ( 'InLavorazione','InApprove' )  and @UserRup = @idUser
											and 
										( 
											@pcp_StatoScheda in ( '', 'ErroreCreazione', 'AppaltoCancellato' ) --gestione pulita per stato scheda
												--OR 
											--( @pcp_StatoScheda = '' and isnull(@pcp_codiceAppalto,'') = '' ) --gestione per la retrocompatibilità
										) 
									then '1' 
									else '0' 
								end

		set @viewConfermaAppalto = case when @deleted = '0' then '1' else '0' end --se gara interop, non AD, non seconda fase interop

		set @cancellaAppalto = CASE WHEN @StatoFunzionale IN ( 'InLavorazione','InApprove' )  and @UserRup = @idUser
											AND
										  ( @pcp_StatoScheda in ( 'Creato', 'Confermato', 'AP_CONF', 'AP_IN_CONF','AP_N_CONF', 'AP_CONF_MAX_RETRY', 'AP_CONF_NO_ESITO', 'ErroreCigRecuperati' ) ) 
										then '1' 
										else '0' 
									 END

		set @viewCancellaAppalto = case when ( @pcp_TipoScheda =  '' or  isnull(@pcp_codiceAppalto,'') = ''  ) and @UserRup = @idUser then '0' else '1'  end --faccio sparire il comando di cancella se non c'è il tipo scheda o SENZA codice appalto 
		set @recuperaCIG = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) and @UserRup = @idUser and @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end
		set @viewRecuperaCIG = case when  @deleted = '0' or @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end

		--Invio al fornitore. Permettere il click quando : 
		IF @pcp_TipoScheda <> ''  and @pcp_StatoScheda = 'CigRecuperati'  --  prevede l'invio di una scheda/appalto, con stato 'CigRecuperati' se sono su una scheda che non prevede la pubblicazione avviso
		BEGIN
			SET @send_ODA_PCP = '1'
		END
		ELSE
		BEGIN
			SET @send_ODA_PCP = '0'
		END

	END

	declare @EntiAbilitati nvarchar(2000) = dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)

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
				 when rCig.Id is not null then ' idpfuRup CIG_MADRE ' 
				 else ''
			 end 

				+ isnull(o.NotEditable,'') 

				+ case when o.RichiestaCigSimog = 'si' or dbo.attivo_INTEROP_Gara(CT.id)=1 then ' CIG ' else '' end

				+ case when @EntiAbilitati <> '' AND CHARINDEX (',' + CT.Azienda + ',', ',' + @EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
					   else ''
				   end

				--se attivo PCP blocco RichiestaCigSimog,Obbligo_Cig_Derivato e Motivazione_ObbligoCigDerivato
				+ case when @attivo_INTEROP_Gara = 1 then ' RichiestaCigSimog Obbligo_Cig_Derivato Motivazione_ObbligoCigDerivato ' else '' end

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

		, case when rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' ) then '1' else '0' end as cigInviato
		, case when rCig.StatoFunzionale in ( 'Inviato' , 'InvioInCorso' ) then 1 else 0 end as docRichiestaCig
		, o.idpfuRup

		, ct.Caption
		, ct.NumeroDocumento
		, ct.DataDocumento
		, o.CUP
		, isnull(O.IdDocIntegrato,0) as IdDocIntegrato

		--se attivo PCP setto RichiestaCigSimog=no
		, case when dbo.attivo_INTEROP_Gara(CT.id)=1 then 'no' else o.RichiestaCigSimog end as RichiestaCigSimog

		--, o.obbligo_cig_derivato a si se attivo interop 
		, case when dbo.attivo_INTEROP_Gara(CT.id)=1 then 'si' else o.obbligo_cig_derivato end as obbligo_cig_derivato
		, o.motivazione_obbligocigderivato

		-- DATI INTEROP/PCP
		, @attivo_INTEROP_Gara  as attivo_INTEROP_Gara

		, @pcp_TipoScheda AS pcp_TipoScheda
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

		, @send_ODA_PCP as send_ODA_PCP
		, @pcp_codiceAppalto as pcp_codiceAppalto

	FROM #ODA CT with(nolock)
			inner join #ODA_DETT o with(nolock) on CT.ID = O.idHeader
			left join ProfiliUtente a with(nolock) on a.IdPfu = ct.IdPfu 				
			left join Document_dati_protocollo prot with(nolock) ON prot.idheader = ct.id 
			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = CT.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori', 'InvioInCorso' )			

			--left join Document_PCP_Appalto PCP with (nolock) on PCP.idHeader = CT.id 
			--left join Document_PCP_Appalto_Schede PCP_SCHEDE with (nolock) on PCP_SCHEDE.idHeader = CT.id and tipoScheda = PCP.pcp_TipoScheda and bDeleted = 0

	where ct.id = @IdDoc and CT.TipoDoc='ODA'
		
END





GO
