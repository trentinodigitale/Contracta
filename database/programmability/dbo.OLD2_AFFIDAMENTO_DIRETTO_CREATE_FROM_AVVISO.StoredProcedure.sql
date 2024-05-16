USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AFFIDAMENTO_DIRETTO_CREATE_FROM_AVVISO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_AFFIDAMENTO_DIRETTO_CREATE_FROM_AVVISO] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	declare @id int
	declare @idRow int
	DECLARE @tipoDocumento varchar(1000)
	DECLARE @dataScadenza datetime
	declare @Blocco nvarchar(1000)
	--declare @Allegato nvarchar(4000)
	declare @idpfu int
	DECLARE @RichiediDocumentazione VARCHAR(10) 
	declare @proceduraGara varchar(50)
	declare @tipoBandoGara varchar(50)
	declare @idGara varchar(50)
	declare @azienda varchar(50)
	--declare @giroRistetta int	
	--declare @ProtocolBG  varchar(50)
	declare @num INT
	--declare @idPda INT	
	declare @RichiestaCigSimog  varchar(50)
	declare @NumeroGara as varchar(100)
	declare @IdPregara as int
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	declare @idAzi INT
	declare @EvidenzaPubblica_Parametro as varchar(10)

	set @Id = 0	
	set @Blocco = ''

	SET NOCOUNT ON

	select 
	--@tipoDocumento = o.tipodoc,
		   @datascadenza = b.DataScadenzaOfferta
		   --@idpfu = o.idpfu,
		   --@RichiediDocumentazione = RichiediDocumentazione,
		   --@proceduraGara = b.ProceduraGara,
		   --@tipoBandoGara = b.TipoAppaltoGara,
		   --@idGara = o.LinkedDoc,
		   --@azienda = o.Azienda
		from ctl_doc o with(nolock)
				inner join Document_Bando b with(nolock) on o.id = b.idheader
		where id = @idDoc

	--Controllo che l’avviso è scaduto  (superata datascdenzaofferte dell'avviso)
	--altrimenti blocco "Operazione non possibile: non è stata raggiunta la scadenza dell'avviso"
	IF getdate() < @datascadenza
		BEGIN
			set @Blocco = 'Operazione non possibile: non è stata raggiunta la scadenza dell''avviso'
		END
	
	if @Blocco = ''
	begin
		--Controllo che ho valutato tutti i fornitori 
		--che hanno presentato una risposta
		--nessuno nello statoiscrizione diverso da Valutato e Selezionato
		--"Operazione non possibile: valutare prima tutti i fornitori"
		if Exists (
					select top 1 idrow from 
						CTL_DOC_Destinatari D with(nolock) 
							inner join CTL_DOC R with (nolock) on R.LinkedDoc = @idDoc and R.TipoDoc='MANIFESTAZIONE_INTERESSE'
									and R.Azienda = D.idazi and R.StatoFunzionale='Inviato'
						where 
							idHeader = @idDoc and isnull(StatoIscrizione,'') not in ('Selezionato', 'Valutato'))
		begin 
			set @Blocco = 'Operazione non possibile: valutare prima tutti i fornitori'
		end
	end

	if @Blocco = ''
	begin	
		if Exists (select count(*) from CTL_DOC_Destinatari with(nolock) where idHeader = @idDoc and isnull(StatoIscrizione,'') = 'Selezionato' having count(*) > 1 or count(*) =0)
		begin 
			set @Blocco = 'Operazione non possibile: ci deve essere un solo fornitore nello stato "Selezionato"'
		end
	end

	if @Blocco = ''
	begin
		-- cerca una versione precedente del documento
		select @Id = id 
			from CTL_DOC with(nolock)
				where LinkedDoc = @idDoc and TipoDoc = 'BANDO_GARA' and deleted = 0 and StatoFunzionale = 'InLavorazione' 

		-- se non viene trovato allora si crea il nuovo documento
		if isnull(@Id , 0 ) = 0 
		begin 
			
			--metto a Chiuso l'avviso di riferimento
			 update CTL_DOC 
				set statofunzionale = 'Chiuso' 
			where id = @idDoc 

			-- genero la testata del documento
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
									ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale ,Versione )
				select @idUser as IdPfu ,  'BANDO_GARA' , 'Saved' ,  'Invito ' +   dbo.CNV( 'dall'' Avviso' , 'I' ) + ' ' + d.Protocollo , d.Body , Azienda , 
						StrutturaAziendale, d.Protocollo  , '' as Fascicolo ,  Id  ,'InLavorazione' , d.Versione
					from CTL_DOC d with(nolock)
							inner join document_Bando b with(nolock) on d.id = b.idheader
					where Id = @idDoc

			set @Id = SCOPE_IDENTITY()

			--settaggio RichiestaCigSimog
			IF (select dbo.attivoSimog())=1
				 set @RichiestaCigSimog= 'si'
			ELSE 
				 set @RichiestaCigSimog=null


			--se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
			select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
			if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@idazi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
				set @RichiestaCigSimog = 'no'


			-- inserico i dati base del bando
			insert into Document_Bando (
						idHeader, ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						TipoBandoGara       , CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Concessione,EnteProponente,RupProponente,RichiestaCigSimog, 
						Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, 
						ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE , GeneraConvenzione )
				select  @Id    , ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						'3' as TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, 
					
						--setto evidenza pubblica a 0 
						'0' as EvidenzaPubblica ,concessione,EnteProponente,RupProponente,@RichiestaCigSimog,

						Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, 
						ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE,GeneraConvenzione

					from document_bando f 
					where f.idHeader = @idDoc


			--riporto il campo UserRup dal primo giro
			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
				select 
					@Id as idheader , dse_id,row,dzt_name,value
					from
						CTL_DOC_Value with (nolock)
					where IdHeader = @idDoc and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP'

			insert into Document_dati_protocollo ( idHeader) values (  @Id )

			--riporto il destinatario del primo giro recuperando l'OE con statoiscrizione='Selezionato' sulla ctl_doc_destinatari
			insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
					select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, a.IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, 1 as NumRiga, a.ordinamento
					from CTL_DOC_Destinatari a with(nolock)
							inner join aziende b with(nolock) on b.idazi=a.idazi
							left join DM_Attributi c with(nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'							
					where a.idheader = @idDoc and isnull(StatoIscrizione,'') = 'Selezionato'
					

		end

		exec BANDO_GARA_DEFINIZIONE_STRUTTURA @id

		--se numerogara presente su una richiesta CIG non associato ad un'altra gara 
		--recupero le gare che hanno associate una richiesta cig nello stato inviata 
		select 
			G.id
			into #tempCigara
		from
			CTL_DOC G with (nolock)
				inner join Document_Bando with (nolock) on idHeader = G.id
				inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
				left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
				left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id  
				left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
		where 
			G.TipoDoc in ('BANDO_GARA') and G.Deleted = 0 and G.Id <> @id
			and  (
					--presente su una richiesta smart cig
					( divisione_lotti = '0' and DSC.smart_cig = @NumeroGara )
					or
					--presente su numero gara si una richiesta cig a lotti
					( divisione_lotti <> '0' and DSG.id_gara  = @NumeroGara )
					or 
					--presente sui lotti di una richiesta cig non a lotti 
					( divisione_lotti = '0' and DSL.cig  = @NumeroGara )
				)
	
		 --e presente su un pregara non ancora utilizzato su nessuna gara allora faccio 
		 --recupero numero gara della gara	
		if not exists (select * from #tempCigara)
		begin

			set @IdPregara=0

			select 
				--RIC_CIG.id
				--into #tempCigPreGara
				@IdPregara = G.Id 
			from
				CTL_DOC G with (nolock)
					inner join Document_Bando with (nolock) on idHeader = G.id
					inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG')  and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
					left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
					left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id 
					left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
			where 
				G.TipoDoc in ('PREGARA') and G.Deleted = 0 and G.StatoFunzionale  in ( 'Completo' ,'Concluso')
				and  (
						--presente su una richiesta smart cig
						(  DSC.smart_cig = @NumeroGara ) --divisione_lotti = '0' and
						or
						--presente su numero gara di una richiesta cig a lotti
						(  DSG.id_gara  = @NumeroGara ) --divisione_lotti <> '0' and
						or 
						--presente sui lotti di una richiesta cig non a lotti 
						(  DSL.cig  = @NumeroGara ) --divisione_lotti = '0' and
					)

			if @IdPregara <> 0 
				exec ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA  @IdPregara ,  @id,  @idUser

			--associao alla gara il pregara
			insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
				values
					(@id , 'InfoTec_comune', 'IdDocPreGara', cast(@IdPregara as varchar(100) ) )

		end


		--recupero @EvidenzaPubblica_Parametro dai parametri
		select @EvidenzaPubblica_Parametro = dbo.PARAMETRI('NUOVA_PROCEDURA-SAVE:INVITO','EvidenzaPubblica','DefaultValue','NULL',-1)
		if @EvidenzaPubblica_Parametro <> 'NULL'
		begin
			update Document_Bando 
				set EvidenzaPubblica = @EvidenzaPubblica_Parametro
				where idheader= @id
		end
	end
	
	if @Blocco = ''
		select @id as id , 'BANDO_GARA' as TYPE_TO
	else
		select 'Errore' as id , @Blocco as Errore
END
GO
