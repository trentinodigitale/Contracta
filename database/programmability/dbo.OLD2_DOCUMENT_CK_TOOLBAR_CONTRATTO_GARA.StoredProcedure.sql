USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_CONTRATTO_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--exec DOCUMENT_CK_TOOLBAR_CONTRATTO_GARA 'CONTRATTO_GARA', '480462', 42727

CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_CONTRATTO_GARA]( @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @SYS_AIC_URL_PAGE nvarchar(1000) = ''
	DECLARE @SYS_CLIENTE_MONO_ENTE nvarchar(1000) = 'NO'
	DECLARE @presenzaAIC varchar(10) = '0'
	DECLARE @IdGara int 
	DECLARE @Pcp_TipoScheda varchar(100)
	DECLARE @sendPCP varchar(10) = '0'		-- abilitazione del comando "Invio dati PCP"
	DECLARE @viewSendPCP varchar(10) = '0'  -- visualizzazione del comando "Invio dati PCP"
	DECLARE @sendBase varchar(10) = '1'		-- abilitazione del comando 'invio'
	DECLARE @idContr INT = 0
	DECLARE @pcp_CodiceAppalto varchar(500) = ''
	DECLARE @statoScheda varchar(100) = ''
	DECLARE @garaPCP varchar(10) = '0'
	DECLARE @readonlyPCP varchar(10) = '0'
	DECLARE @StatoFunzionale VARCHAR(100) = ''
	DECLARE @idPfuInCharge INT = 0
	DECLARE @ProceduraGara VARCHAR(100) = ''
	DECLARE @AD_PCP varchar(10) = '0'

	IF ISNUMERIC(@IdDoc) = 1
		set @idContr = CAST( @IdDoc AS INT )

	SELECT @SYS_AIC_URL_PAGE = sys2.DZT_ValueDef
		from LIB_Dictionary sys2 with (nolock)
		where sys2.DZT_Name='SYS_AIC_URL_PAGE'

	SELECT @SYS_CLIENTE_MONO_ENTE = sys2.DZT_ValueDef
		from LIB_Dictionary sys2 with (nolock)
		where sys2.DZT_Name='SYS_CLIENTE_MONO_ENTE'

	-- VERIFICA SE NEL MODELLO C'È LA COLONNA AIC
	IF EXISTS ( 
			select x.IdRow 
				from ctl_doc_section_model x with (nolock) 
						inner join CTL_ModelAttributes WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)
							on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'
				where x.IdHeader = @idContr  and x.DSE_ID = 'BENI'
			)
	BEGIN
		set @presenzaAIC = '1'
	END

	--RECUPERO ID GARA E TIPO SCHEDA
	SELECT  @IdGara = pda.LinkedDoc
			, @StatoFunzionale = c.StatoFunzionale
			, @idPfuInCharge = c.idPfuInCharge
			, @ProceduraGara = db.ProceduraGara
			, @Pcp_TipoScheda = pcp_TipoScheda
			--,@pcp_CodiceAppalto = pcp_CodiceAppalto
		FROM CTL_DOC C with(nolock) 
				inner join CTL_DOC PDA_COM with(nolock)  on PDA_COM.Id=C.LinkedDoc
				inner join CTL_DOC PDA with(nolock)  on PDA.Id=PDA_COM.LinkedDoc
				inner join Document_PCP_Appalto A with(nolock)  on A.idheader = pda.LinkedDoc
				inner join document_bando db with(nolock) on db.idHeader = a.idHeader
		WHERE C.Id = @idContr

	-- Entro nella nuova gestione di comando invio/inviodatipcp ed editabilità, 
	--	se la gara è nel giro PCP e 
	--		se sulla gara c'è la scheda P1_16 ( così da inviare l'a1_29 ) 
	--		oppure se è un affidamento diretto
	--		oppure se sulla gara c'è la scheda P2_16 ( così da inviare l'a2_29 )
	--		oppure se sulla gara c'è la scheda p7_1_2 ( così da inviare l'a7_1_2 )
	--		oppure se sulla gara c'è la scheda p2_19 ( così da inviare l'a2_32 )
	--		oppure se sulla gara c'è la scheda p1_19 ( così da inviare l'a1_32 )
	--IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1 and ( @Pcp_TipoScheda in ('P1_16', 'P2_16','P7_1_2','P2_19','P1_19','P2_20') or @ProceduraGara = '15583')
	IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1 and ( @Pcp_TipoScheda in ('P1_16', 'P2_16','P7_1_2','P2_19','P1_19','P1_20', 'P2_20') or @ProceduraGara = '15583')
	BEGIN

		set @statoScheda = '' -- stato vuoto : richiesta di invio scheda non ancora effettuata
		set @garaPCP = '1'	  -- evidenziamo che la gara è nel flusso PCP/INTEROP

		-- PER IL GIRO DI AFFIDAMENTO DIRETTO SEGUIAMO DEI CONTROLLI DIFFERENTI
		IF @ProceduraGara = '15583'
		BEGIN
			set @AD_PCP = '1'		-- siamo su di un giro di affidamento diretto
			set @sendBase = '1'		-- il comando di invio deve essere attivo. l'innesco del contratto-ad è all'invio
			set @viewSendPCP = '0'	-- non mostriamo il comando "invio dati pcp"
			set @sendPCP = '0'		-- send pcp non attivo. anche se non mostrando il comando questo ulteriore flag diventa inutile
			SET @readonlyPCP = '0'	-- editabilità come prima
		END
		ELSE
		BEGIN

			set @AD_PCP = '0' --non siamo su un affidamento diretto

			-- recupero lo stato dell'ultima scheda inviata collegata al documento corrente. in questo punto non ha importanza il tipo
			select top 1 @statoScheda = statoScheda 
				from Document_PCP_Appalto_Schede with(nolock) 
				where IdDoc_Scheda = @idContr and bDeleted = 0 and tipoScheda IN ( 'A1_29', 'A2_29', 'A7_1_2', 'A2_32', 'A1_32','A1_33', 'A2_33')
				order by idRow desc

			---- se non ho trovato una scheda collegata provo a cercare un appalto ( per l'affidamento diretto ) collegato con la gara
			--select top 1 @statoScheda = statoScheda 
			--	from Document_PCP_Appalto_Schede with(nolock) 
			--	where idHeader = @IdGara and bDeleted = 0 and tipoScheda like '%AD%' -- preferisco non mettere un enumerato per non doverlo manutenere in continuazione. ma vado in like sugli affidamenti diretti
			--	order by idRow desc

			--Rendiamo readonly il documento se è stata inviata una scheda e non c'è errore
			--IF @statoScheda in ( 'InvioInCorso', 'InLavorazione', 'Confermato', 'EsitoOK' )
			IF @statoScheda in ( 'InvioInCorso', 'Creato', 'Confermato', 'SC_CONF', 'AP_CONF', 'CigRecuperati', 'InPubblicazione', 'AV_PUBB', 'AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO' )
			BEGIN
				SET @readonlyPCP = '1'
				-- quindi sarà editabile se la scheda non è stata ancora inviata o se c'è un errore, stati : '', 'ErroreCreazione', 'ErroreConferma', 'AP_N_CONF', 'SC_N_CONF', 'AV_N_PUBB'
			END

			-- essendo attivo il flusso di interop per questa gara dovrò mostrare il comando di "invio dati pcp"
			set @viewSendPCP = '1'

			-- di base il comando di invio dati pcp non sarà attivo. NON deve esserlo ad esempio mentre si sta inviando la scheda ( negli stati intermedi )
			--	e dopo che la scheda (o l'appalto) si è chiusa
			set @sendPCP = '0'

			--IF @statoScheda	in ( '', 'Invio_con_errori', 'NonConfermato' )
			IF @statoScheda IN ( '', 'ErroreCreazione', 'ErroreConferma', 'AP_N_CONF', 'SC_N_CONF', 'AV_N_PUBB' )
			BEGIN
				-- permettiamo l'invio dei dati pcp se la scheda deve essere ancora inviata o se è in uno stato di errore
				set @sendPCP = '1'
			END

			-- con il flusso di interop attivo di base non consentiamo l'invio del contratto
			set @sendBase = '0'

			--richiesta : <<A valle di esito operazione POSITIVO il pulsante di Invia/Pubblica si abiliterà.>>
			--IF @statoScheda = 'EsitoOK'
			IF @statoScheda IN ( 'SC_CONF', 'AV_PUBB', 'AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO')
				and ( ( @StatoFunzionale = 'InLavorazione' or @StatoFunzionale = 'InApprove') and @idPfuInCharge = @idUser ) 
			BEGIN
				--permettiamo l'invio del contratto se la scheda ( o l'appalto ) collegato è in uno stato terminale di OK
				-- E se il documento è InLavorazione o InApprove e se l'utente collegato è l'utente che ha in carico il documento
				set @sendBase = '1'
				SET @readonlyPCP = '1' --quando si è chiuso il giro della scheda il documento deve essere readonly e l'utente deve inviare il contratto
			END

		END --IF @ProceduraGara = '15583'

	END

	SELECT 
		   c.Id, 
		   C.IdPfu, 
		   C.IdDoc, 
		   C.TipoDoc, 
		   C.StatoDoc, 
		   C.Data, 
		   C.Protocollo, 
		   C.PrevDoc, 
		   C.Deleted, 
		   C.Titolo, 
		   C.Body, 
		   C.Azienda, 
		   C.StrutturaAziendale, 
		   C.DataInvio, 
		   c.DataScadenza, 
		   C.ProtocolloRiferimento, 
		   C.ProtocolloGenerale, 
		   C.Fascicolo, 
		   C.Note, 
		   C.DataProtocolloGenerale, 
		   C.LinkedDoc, 
		   C.SIGN_HASH, 
		   C.SIGN_ATTACH, 
		   C.SIGN_LOCK, 
		   C.JumpCheck, 
		   C.StatoFunzionale, 
		   C.Destinatario_User, 
		   C.Destinatario_Azi, 
		   C.RichiestaFirma, 
		   C.NumeroDocumento, 
		   C.DataDocumento, 
		   C.Versione, 
		   C.VersioneLinkedDoc, 
		   C.GUID, 
		   C.idPfuInCharge, 
		   C.CanaleNotifica, 
		   C.URL_CLIENT, 
		   C.Caption,
		   ISNULL(sd.DataBando, sc.DataRiferimento) as DataRiferimento,
		   sd.DataRiferimentoInizio,
		   sd.DataRisposta,
		   sd.DataScadenzaOfferta,
		   sd.ProtocolloOfferta,

		   ISNULL(cs.F1_SIGN_HASH,'') as F1_SIGN_HASH,
		   ISNULL(cs.F1_SIGN_LOCK,'') as F1_SIGN_LOCK,
		   ISNULL(cs.F1_SIGN_ATTACH,'') as  F1_SIGN_ATTACH,
		   ISNULL(cs.F2_SIGN_ATTACH,'') as  F2_SIGN_ATTACH,
		   ISNULL(cs.F2_SIGN_HASH,'') as F2_SIGN_HASH,

		   sc.CodiceIPA,
		   sc.firmatario,
		   sc.CF_FORNITORE,
		   sc.PresenzaListino,
		   sc.FascicoloSecondario,
		   sc.Firmatario_OE,
		   SC.DirettoreEsecuzioneContratto,
		   ' CodiceIPA , firmatario , CF_FORNITORE , firmatario_OE DataRiferimento Body ' as NotEditable,
		    ISNULL(sd.FROM_INIZIATIVA ,'0') as CONTRATTO_INIZIATIVA,
			ISNULL(@SYS_CLIENTE_MONO_ENTE,'NO') as MONO_ENTE,
			case 
				when  ISNULL(/*C15.value*/ sd.FROM_INIZIATIVA ,'0') = '1' then '' 
				else ' DataRiferimento Body ' 
			end 
			
			+ 

			case 
				when isnull(sc.idpfu_firmatario,'') <> '' then ' firmatario '
				else '' 
			end 
			as NonEditabili
			
			, case when ISNULL(@SYS_AIC_URL_PAGE,'') <> '' then '1' else '0' end as Check_AIC_Enabled
			, @presenzaAIC as PresenzaAIC
			, case when isnull(sc.DataScadenza,'') = '' then 'no' else 'si' end as FlagScadenza
			, STIP.id as idDocStipulaContratto
			, sc.idpfu_firmatario
			, case when dbo.PARAMETRI('SERVICE_REQUEST','TED','ATTIVO','NO',-1) = 'YES' then 1 else 0 end as ted
			, case when P_TED.id is not null and GUEE.Id is not null then 1 else 0 end as CAN_GESTIONE_GUEE
			 
			 , @garaPCP as garaPCP
			 , @sendPCP as sendPCP
			 , @viewSendPCP as viewSendPCP
			 , @sendBase as sendBase
			 , @readonlyPCP as readonlyPCP
			 , @AD_PCP as AD_PCP

	from ctl_doc c with(nolock)

			left join CONTRATTO_GARA_DOCUMENT_VIEW_SUB_DOC sd on sd.idheader = c.id
			left join ctl_doc OFFERTA with (nolock) on OFFERTA.protocollo =  sd.ProtocolloOfferta and OFFERTA.deleted=0 and OFFERTA.tipodoc='OFFERTA'
			left join ctl_doc P_TED with (nolock) on P_TED.linkeddoc = OFFERTA.LinkedDoc and  P_TED.tipodoc='PUBBLICA_GARA_TED' and P_TED.StatoFunzionale ='PubTed' and P_TED.deleted=0
			left join ctl_doc_sign cs with(nolock) on cs.idheader=c.id 

			left join CONTRATTO_GARA_DOCUMENT_VIEW_SUB_CONTRATTO sc on sc.idheader = c.id

			left join ctl_doc STIP with (nolock) on STIP.linkeddoc = c.id and STIP.Tipodoc ='VERBALEGARA' and STIP.deleted=0 and STIP.statofunzionale='InLavorazione'
			left join ctl_doc GUEE with (nolock) on GUEE.linkeddoc = c.id and GUEE.Tipodoc ='GESTIONE_GUUE_F03' and GUEE.deleted=0 

	where c.Id = @idContr --and c.tipodoc like 'CONTRATTO_GARA%' and c.deleted=0

END
GO
