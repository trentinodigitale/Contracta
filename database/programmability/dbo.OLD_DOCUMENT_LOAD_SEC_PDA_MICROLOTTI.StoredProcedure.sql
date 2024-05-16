USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_LOAD_SEC_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- in sostituzione della vista PDA_MICROLOTTI_VIEW_TESTATA
CREATE PROCEDURE [dbo].[OLD_DOCUMENT_LOAD_SEC_PDA_MICROLOTTI](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	SET NOCOUNT ON
	
	declare @View_Send_PCP as varchar(10)
	declare @Send_PCP as varchar(10)
	declare @TipoScheda_PCP as varchar(100)
	declare @Stato_Scheda_PCP as varchar(100)
	declare @pcp_CodiceAppalto as nvarchar(1000)
	DECLARE @GESTIONE_PCP_RUP varchar(10) = 'NO'

	DECLARE @Send_NON_AGG AS varchar(10)

	DECLARE @GestionePCP AS VARCHAR(10) --MENU GESTIONE PCP

	set @View_Send_PCP = '0'
	set @Send_PCP = '0'

	SET @GestionePCP = '0'
	SET @Send_NON_AGG = '0'

	--recupero se la gestione PCP attiva solo per il RUP
	select @GESTIONE_PCP_RUP = dbo.PARAMETRI('GESTIONE_PCP_RUP', 'ATTIVA', 'DefaultValue', 'NO', -1)


	--RECUPERO INFO PDA E RIFERIMENTI DELLA GARA
	select
		d.* 
		, dbo.ListRiferimentiBando(d.linkeddoc , 'Bando' ) as UsersRiferimentiBando
		, 1 as APERTURA_BUSTE
		, 1 as APERTURA_BUSTE_TECNICHE
		into #INFO_PDA
		from
			ctl_doc d with (nolock) 
		where id=@IdDoc

	

	--RECUPERO ALTRE INFO DELLA PDA
	select 
		t.*,d.* into #INFO_PDA_2 
		from 
			Document_PDA_TESTATA t with (nolock) 
				CROSS JOIN #INFO_PDA d
		where t.idHeader=@IdDoc
	

	declare @PI_approvazione_diretta varchar(10)
	select @PI_approvazione_diretta =  dbo.PARAMETRI('BANDO_GARA','APPROVE','PI_DIRECT_APPROVE','',-1)
			
	drop table #INFO_PDA

	--TRAVASO LE INFO DELL PADA E DELLA GARA IN UNA TEMP #INFO_PDA_GARA
	select  
		d.*
		,isnull(B.TipoSceltaContraente,'') as TipoSceltaContraente
		, b.TipoAggiudicazione 
		, b.RegoleAggiudicatari
		, ISNULL(b.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		--,case when 	@PI_approvazione_diretta = 'YES' and (b.ProceduraGara = '15583' or b.ProceduraGara = '15479' or b.ProceduraGara = '15585')			 
		--		then 'RFQ' 
		--		else 
		--			ISNULL(b.TipoProceduraCaratteristica,'') end as TipoProceduraCaratteristica
		, case when b.TipoBandoGara = '2' and b.ProceduraGara = '15477' then '1' else '0' end as bandoRistretta
		, b.TipoSedutaGara
		, ISNULL(b.StatoSeduta,'chiusa') as StatoSeduta
		, IsNull(b.StatoChat, 'CLOSE') as StatoChat
		, isnull(b.Concessione,'no') as Concessione
		, b.Visualizzazione_Offerta_Tecnica
		, b.InversioneBuste
		, b.GeneraConvenzione
		, b.Accordo_di_Servizio
		, b.Divisione_lotti
		, b.CalcoloAnomalia
		, b.metodo_di_calcolo_anomalia AS MetodoDiCalcoloAnomalia
		, b.ScontoDiRiferimento
		, case when  @PI_approvazione_diretta = 'YES' and (b.ProceduraGara = '15583' or b.ProceduraGara = '15479' or b.ProceduraGara = '15585')			 
				then 'YES' 
				else 
					'NO' end as PI_approvazione_diretta
		
		into #INFO_PDA_GARA
		from Document_Bando  b  with (nolock)
				cross join #INFO_PDA_2 d 
		where d.LinkedDoc=b.idHeader

	drop table #INFO_PDA_2

	DECLARE @DataInvioGara datetime --da riportare in output
	DECLARE @SCELTA_CRITERIO_CALCOLO_ANOMALIA varchar (1) --da riportare in output
	DECLARE @gara_id int --da riportare in output
	DECLARE @bloccaVerificaAnomalia varchar (1) --da riportare in output
	DECLARE @NumeroOfferte int --da riportare in output

	DECLARE @METODO_DI_CALCOLO_ANOMALIA varchar (150)
	DECLARE @ScontoDiRiferimento float

	select 
		@DataInvioGara = gara.DataInvio 
		, @SCELTA_CRITERIO_CALCOLO_ANOMALIA = case when gara.DataInvio < '2019-04-19' then '1' else '0' end 
		, @gara_id = gara.id 
		, @bloccaVerificaAnomalia= case when isnull(offers.numOff,0) < 5 and RICHIESTA_CALCOLO_ANOMALIA = 'SI' and gara.DataInvio >= '2017-05-20' then '1' else '0' end
		, @NumeroOfferte = isnull(numOff , 0)
		,@METODO_DI_CALCOLO_ANOMALIA = MetodoDiCalcoloAnomalia

		,@ScontoDiRiferimento = ScontoDiRiferimento
		from 
			ctl_doc gara with(nolock) 
				
				left join ( 
							select 
								count(IdHeader) as numOff, IdHeader
								from 
									Document_PDA_OFFERTE with(nolocK)
								where 
									StatoPDA in ( '2' , '22', '222' ,'8' ,'9') 
								group by IdHeader 
							) as offers on offers.IdHeader = @IdDoc
				
				cross join #INFO_PDA_GARA d 

		where gara.id = d.LinkedDoc

	
	--RECUPERA IL RUP DELLA GARA
	DECLARE @UserRUP nvarchar(max)  -- DA ritornare in output

	select 
		@UserRUP=rup.Value
		from 
			ctl_doc_value rup with(nolock) 
		where  
			rup.idHeader = @gara_id and rup.dse_id = 'InfoTec_comune' and rup.dzt_name = 'UserRup' 
	
	DECLARE @AttivaFilePending nvarchar(max)  -- DA ritornare in output

	select 
		@AttivaFilePending=cp.value 
		from 
			ctl_doc_value cp with(nolock) 
		where 
			cp.IdHeader = @gara_id and cp.DSE_ID = 'PARAMETRI' and cp.DZT_Name = 'AttivaFilePending' -- parametro della gara
						
	--TRAVASO I MODELLI LEGATI ALLA PDA NELLA TEMP #INFO_MOD_PDA
	select 
		d.*
		, ModelloPDA
		, ModelloPDA_DrillTestata
		, ModelloPDA_DrillLista
		, ModelloOfferta_Drill
		
		into #INFO_MOD_PDA
		from 
			--Document_Modelli_MicroLotti m with(nolock) 
				--cross join #INFO_PDA_GARA d
				#INFO_PDA_GARA d
					left outer join Document_Modelli_MicroLotti m with(nolock) on m.Codice = d.ListaModelliMicrolotti
		--where 
			
	

	DROP TABLE #INFO_PDA_GARA


	DECLARE @Exequo int  -- DA ritornare in output
	DECLARE @l_id int
	DECLARE @StatoRiga varchar(50)  -- DA ritornare in output
	DECLARE @InValutazione varchar(1)  -- DA ritornare in output
	set @InValutazione=0

	--RECUPERO STATO LOTTO 1 SULLA PDA
	SELECT 
		@Exequo=l.Exequo
		, @l_id=l.id
		, @StatoRiga= l.statoriga
		, @InValutazione = case when StatoRiga in ( 'daValutare', 'InValutazione' ) then '1' else '0' end  
		FROM Document_Microlotti_Dettagli l with(nolock) 
		WHERE l.idheader = @IdDoc and l.tipoDoc = 'PDA_MICROLOTTI' and l.NumeroLotto = '1' and l.Voce = 0 

	------------------------------------------------------------------------------------------------------------------------------------------
	--- VERIFICHIAMO SE E' STATO GENERATO L'XML CN16 ( E_FORMS ) COSI' DA FAR COMPARIRE IL COMANDO DI AVVISO DI AGGIUDICAZIONE ( CAN29 )   ---
	------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @bAttivaCan29 varchar(1) = '0'
	DECLARE @bAttivaCan29_multilotto varchar(1) = '0'

	-- Per rendere la modifica retrocompatibile (quindi permettere il rilascio di questa stored senza le attività degli eforms ) testiamo l'esistenza della tabella
	IF exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_PAYLOADS' and type='U' )
	BEGIN	

		IF EXISTS ( select idrow from Document_E_FORM_PAYLOADS with(nolock) where idHeader = @gara_id and operationType = 'CN16' )
		BEGIN
			
			-- per il riepilogo finale della multi lotto mostriamo il comando senza considere lo stato riga, quello verrà fatto in base alla selezione
			--		non possiamo neanche toglierlo in assenza di almeno una riga utile perchè non sapremmo su che pagina ci troviamo
			set @bAttivaCan29_multilotto = '1'

			IF @StatoRiga in ('AggiudicazioneDef','interrotto','NonGiudicabile','Revocato','Deserta', 'NonAggiudicabile')
				set @bAttivaCan29 = '1'

		END

	END


	
	DECLARE @COM_ID INT

	--RECUPERO UTENTI DELLA COMMISSIONE
	SELECT 
		@COM_ID = COM.ID
		FROM
			ctl_doc COM with(nolock) 
				CROSS JOIN #INFO_MOD_PDA D
		WHERE 
			COM.linkeddoc=d.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
					


	--RECUPERO PRESIDENTE DELLA COMMISSIONE GIUDICATRICE (A)
	DECLARE @presidente_commissione  nvarchar (200)  -- DA ritornare in output
	set @presidente_commissione='0'
	select 
		@presidente_commissione=ISNULL(CU.UtenteCommissione,0)  
		from 
			Document_CommissionePda_Utenti CU with(nolock) 
		where 
			CU.idheader=@COM_ID and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
					

	--RECUPERO PRESIDENTE DELLA COMMISSIONE ECONOMICA (C) se esiste
	DECLARE @PresAgg  int  -- DA ritornare in output
	set @PresAgg=@presidente_commissione
	select
		@PresAgg=coalesce(CEco.UtenteCommissione,@presidente_commissione,0) 
		from 
			Document_CommissionePda_Utenti CEco with(nolock) 
		where 
			CEco.idheader=@COM_ID and CEco.TipoCommissione='C' and CEco.ruolocommissione='15548'
					


	--RECUPERO PRESIDENTE DELLA COMMISSIONE TECNICA (G)
	DECLARE @PresTec  nvarchar (200)  -- DA ritornare in output
	set @PresTec='0'
	select 
		@PresTec= isnull(CTec.UtenteCommissione,0)
		from 
			Document_CommissionePda_Utenti CTec with(nolock) 
		where 
			CTec.idheader=@COM_ID and CTec.TipoCommissione='G' and CTec.ruolocommissione='15548'


	--RECUPERO SE HO ESEGUITO IL COMANDO DI APERTURA BUSTE TECNICHE
	DECLARE @comando_eseguito  varchar (50)  -- DA ritornare in output
	set @comando_eseguito='0'
	select 
		@comando_eseguito= isnull(CTA.APS_State,0) 
		from 
			CTL_ApprovalSteps CTA with(nolock) 
		where
			CTA.APS_ID_DOC=@IdDoc and ctA.APS_Doc_Type='PDA_MICROLOTTI' and CTA.APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE'

		
	--RECUPERO ESISTENZA DOC DI CRITERIO_CALCOLO_ANOMALIA
	DECLARE @ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA   varchar (2)  -- DA ritornare in output
		select  
			@ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA = case when not CSA.id is null then 'SI' else '' end 
			from 
				ctl_doc CSA with(nolock) 
			where 
				CSA.LinkedDoc=@IdDoc and CSA.TipoDoc LIKE 'CRITERIO_CALCOLO_ANOMALIA%' and CSA.Deleted=0

	-- case when CT.DataScadenza < GETDATE()  or ISNULL(num.count_risposte_da_inviare,1) = 0 or num.LinkedDoc is null then '1' else '0' end as CAN_TERMINA
	--left join ctl_doc CT with(nolock) on CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=d.id and CT.VersioneLinkedDoc=l.id and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'
	--RECUPERO INFO CAN TERMINA
	declare @ct_id as int
	declare @ct_datascadenza as datetime
	select 
		@ct_id=ct.id
		, @ct_datascadenza=DataScadenza
		from  
			ctl_doc CT with(nolock) 
				
		where 
			CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=@IdDoc and CT.VersioneLinkedDoc=@l_id 
				and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'

	declare @count_risposte_da_inviare as int

	select @count_risposte_da_inviare=count(*)  
		from ctl_doc with(nolock) 
		where  tipodoc='PDA_COMUNICAZIONE_OFFERTA'  and statofunzionale <> 'Inviata Risposta' and LinkedDoc =@ct_id
		



	DECLARE @CAN_TERMINA   varchar (1)  -- DA ritornare in output
	set @CAN_TERMINA='0'
	select 	@CAN_TERMINA=case when @ct_datascadenza < GETDATE()  or ISNULL(@count_risposte_da_inviare,1) = 0 or @ct_id is null then '1' else '0' end





	--RECUPERO INFO ATTIVA INVITO
	DECLARE @attivaInvito   varchar (1)  -- DA ritornare in output
	set @attivaInvito=1
	select 
		@attivaInvito=case when ISNULL( attivaInvito.numDom, 0) > 0 then '0' else '1' end 
		from ( 
			select 
				count(IdHeader) as numDom, IdHeader 
				from 
					Document_PDA_OFFERTE with(nolocK) 
				where 
					TipoDoc = 'DOMANDA_PARTECIPAZIONE' and StatoPDA not in ( '1' , '2', '99' ) group by IdHeader 
				) as attivaInvito 
		where attivaInvito.IdHeader =@IdDoc


	--RECUPERO INFO OwnerChat
	DECLARE @OwnerChat   nvarchar (MAX)  -- DA ritornare in output

	select
		@OwnerChat = o.Value 
		from 
			CTL_DOC_Value o with(nolock) 
		where
			o.IdHeader = @IdDoc and o.DSE_ID = 'CHAT' and o.DZT_Name = 'OwnerChat'	
		

	--RECUPERA INFO @PUNTEGGI_ORIGINALI E @ATTIVA_COMANDI_PDA_SEDUTA
	DECLARE @ATTIVA_COMANDI_PDA_SEDUTA   varchar (1)  -- DA ritornare in output
	DECLARE @PUNTEGGI_ORIGINALI   nvarchar (max)  -- DA ritornare in output

	select  
		@PUNTEGGI_ORIGINALI=pa.PUNTEGGI_ORIGINALI
		, @ATTIVA_COMANDI_PDA_SEDUTA=
			Case 
				when psv.Apertura='manuale' then '1'
				when psv.Apertura='automatica' and psv.Chiusura = 'ammessa' then '1'
			else 
				'0'
			end
		from 
			#INFO_MOD_PDA d
				cross join ( select  dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI ) as PA
				cross join 	Document_Parametri_Sedute_Virtuali psv with(nolock)  
		where 
			psv.deleted = 0 	

	DECLARE @Lista_Utenti_Commissione VARCHAR(max)  -- DA ritornare in output
	select 	@Lista_Utenti_Commissione =  dbo.Get_Utenti_Commissione(@COM_ID)

	-- IN CASO DI SORTEGGIO AUTOMATICO RECUPERO L'INFO DALLA TABELLA CTL_DOC_VALUE
	IF EXISTS 
		(	
			SELECT bando.Id
				from  ctl_doc bando
					inner join ctl_doc pda on pda.linkedDoc = bando.id
					inner join ctl_doc criterioDoc on criterioDoc.linkedDoc = pda.id
					inner join ctl_doc_value criterio on criterio.idheader = criterioDoc.id 
				where pda.id = @IdDoc
					AND DSE_ID = 'CRITERI'  
					AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'	
		)
	BEGIN
		SELECT @METODO_DI_CALCOLO_ANOMALIA = 'Metodo ' + UPPER(RIGHT( dzt_name , 1 ))
			from  ctl_doc bando
				inner join ctl_doc pda on pda.linkedDoc = bando.id
				inner join ctl_doc criterioDoc on criterioDoc.linkedDoc = pda.id
				inner join ctl_doc_value criterio on criterio.idheader = criterioDoc.id 
			where pda.id = @IdDoc
				AND DSE_ID = 'CRITERI'  
				AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'
	END


    DECLARE @idRichiestaCig INT -- RICHIESTA_CIG
    DECLARE @idBando INT

    SELECT @idBando=LinkedDoc FROM CTL_DOC WHERE Id=@IdDoc
    SELECT @idRichiestaCig=Id FROM CTL_DOC WHERE LinkedDoc=@idBando AND TipoDoc='RICHIESTA_CIG' AND Deleted=0
        
	declare @AttivaArt36 varchar(2) = '0'

	-- Recupero il flag di attivazione relativo all'attivazione del requisito certification_req_33223 (Art.36 comma 2)
	select @AttivaArt36 = (select dbo.Parametri('CERTIFICATION','certification_req_33223','Visible','0','-1'))

	declare @VisibleArt36 int = 0

	-- Salgo sui documenti PDA_ART_36 in left join per ottenere 2 informazioni: Se esite un Documento PDA_ART_36 e se quest'ultimo è in stato confermato.
	-- Se queste condizioni sono verificate allora posso settare il flag di attivazione Comunicazione a 1 altrimenti 0
	-- Se @VisibleArt36 è a 0 allora si può procedere, altrimenti vuol dire che ci sono righe null, ovvero condizioni non soddisfatte e la join va a vuoto
	select 
		@VisibleArt36 = Count(case when D.id is null then 1 end)
		from
			(
				select top 5 
					Id, idPda, Graduatoria
					from 
						PDA_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW PDA with (nolock)
					where idpda = @IdDoc and Graduatoria is not null
					order by Graduatoria asc
			) as PDA
			left join CTL_DOC D with (nolock) on PDA.id = D.linkeddoc 
				and TipoDoc = 'PDA_ART_36' 
				and deleted = 0
				and statofunzionale = 'Confermato'


	-- VERIFICHAIMO LA PRESENZA DELL'AMPIEZZA DI GAMMA
	declare @idmodelloAcquisto int
	declare @idmodelloAmpiezzaGamma int
			
	select @idmodelloAcquisto = Value						
		from CTL_DOC_Value with(nolock)
		where idheader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

	select @idmodelloAmpiezzaGamma = Value 
		from CTL_DOC_Value with(nolock)
		where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma
			
	declare @PresenzaAmpiezzaDiGamma varchar(2)
	set @PresenzaAmpiezzaDiGamma = 'no'

	--controllo se il modello di ampiezza di gamma prevede busta tecnica 
	if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaINPUT' and DSE_ID = 'MODELLI' and Value <> '')  
	begin
		set @PresenzaAmpiezzaDiGamma = 'si'
	end


	--determino se il comando "Richiedi CIG" (per la PCP) attivo
	select @TipoScheda_PCP = pcp_TipoScheda , @Stato_Scheda_PCP=isnull(statoScheda,''),@pcp_CodiceAppalto=isnull(pcp_CodiceAppalto,'')
		from 
			Document_PCP_Appalto A with (nolock)
				left join Document_PCP_Appalto_Schede SC with (nolock) 
						on SC.idHeader = A.idHeader and tipoScheda = pcp_TipoScheda and bDeleted =0
		where
			A.idHeader = @gara_id 
	
	--se si tratta di una SCHEDA di AFFIDAMENTO DIRETTO () rendo visibile il bottone "Richiedi CIG"
	if @TipoScheda_PCP = 'AD3' or @TipoScheda_PCP = 'AD5' or @TipoScheda_PCP = 'AD2_25' or @TipoScheda_PCP = 'A3_6' 
	begin
		
		set @View_Send_PCP = '1'

		--se lo stato della scheda è vuoto oppure in ErroreCreazione abilito l'invio
		--e non ho fatto il crea appalto
		if ( @Stato_Scheda_PCP='' or @Stato_Scheda_PCP='ErroreCreazione')  and  @pcp_CodiceAppalto = ''
			
			--aggiungo la condizione che 
			--o la gestione non è solo per il rup opopure se è solo per il rup l'utente collegato è il rup
			and ( @GESTIONE_PCP_RUP='NO' Or ( @GESTIONE_PCP_RUP='YES' and @UserRUP = @idUser ) )

		begin
			set @Send_PCP = '1'
		end

	end


	--RECUPERO IL TIPO SOGLIA E DETERMINO SE IL CMANDO "Invio non aggiudicazione" ATTIVO
	DECLARE @TipoSoglia VARCHAR(100)

	SELECT @TipoSoglia = TipoSoglia 
		FROM Document_Bando 
			WHERE idHeader = @idBando


	--ATTIVO MENU "Gestione PCP" SE INTEROPERABILITA ATTIVA
	IF dbo.attivo_INTEROP_Gara(@idBando) = 1
	BEGIN
		SET @GestionePCP = '1'
		SET @Send_NON_AGG = '1'
	END

	----SCHEDA NON AGGIUDICAZIONE
	--IF @TipoSoglia = 'sotto' OR @TipoScheda_PCP = 'P7_1_2'
	--BEGIN
	--	SET @Send_NON_AGG = '1'
	--END
	



	--RITORNO LE INFO INTERESSATE
	select 
			*
			,@DataInvioGara as DataInvioGara
			,@SCELTA_CRITERIO_CALCOLO_ANOMALIA as SCELTA_CRITERIO_CALCOLO_ANOMALIA
			,@gara_id as gara_id
			,@bloccaVerificaAnomalia as bloccaVerificaAnomalia
			,@NumeroOfferte as NumeroOfferte
			,@UserRUP as UserRUP
			,@AttivaFilePending as AttivaFilePending
			,@Exequo as Exequo
			,@StatoRiga as StatoRiga
			,@InValutazione as InValutazione
			,@Lista_Utenti_Commissione as Lista_Utenti_Commissione
			,@presidente_commissione as presidente_commissione
			,@PresAgg as PresAgg
			,@PresTec as PresTec
			,@comando_eseguito as comando_eseguito
			,@ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA as ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA
			,@CAN_TERMINA as CAN_TERMINA
			,@attivaInvito as attivaInvito
			,@OwnerChat as OwnerChatAttivaFilePending
			,@OwnerChat as OwnerChat
			,@ATTIVA_COMANDI_PDA_SEDUTA as ATTIVA_COMANDI_PDA_SEDUTA
			,@PUNTEGGI_ORIGINALI as PUNTEGGI_ORIGINALI
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, 'BASE') as CAN_CREATE_COMUNICAZIONI
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, 'OFFERTA') as CAN_CREATE_COM_INTEGRATIVA_TEC
			,@METODO_DI_CALCOLO_ANOMALIA as METODO_DI_CALCOLO_ANOMALIA
			,@ScontoDiRiferimento as ScontoDiRiferimento
			,@bAttivaCan29 as attivaCan29
			,@bAttivaCan29_multilotto as attivaCan29MultiLotto

            -- Per distinguere GGAP
            , CASE 
                WHEN (SELECT CHARINDEX('SIMOG_GGAP', (SELECT DZT_ValueDef FROM LIB_Dictionary WITH (NOLOCK) WHERE dzt_name = 'SYS_MODULI_GRUPPI'))) > 1
                    THEN 1
                ELSE 0
              END AS isSimogGgap
            --, (SELECT [Value] FROM CTL_DOC_Value WHERE IdHeader = @idBando AND DSE_ID = 'GGAP' AND DZT_Name='idDocR') AS idDocR
            , @idRichiestaCig AS idDocR
            -- Per GGAP - fine
			,@AttivaArt36 as AttivaArt36
			,@VisibleArt36 as VisibleArt36
			,@PresenzaAmpiezzaDiGamma as PresenzaAmpiezzaDiGamma
			,@View_Send_PCP as View_Send_PCP
			,@Send_PCP as Send_PCP
			,@GestionePCP AS GestionePCP
			,@Send_NON_AGG AS Send_NON_AGG
		from #INFO_MOD_PDA
end

GO
