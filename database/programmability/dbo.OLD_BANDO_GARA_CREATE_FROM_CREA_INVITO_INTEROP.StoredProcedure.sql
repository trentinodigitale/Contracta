USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_GARA_CREATE_FROM_CREA_INVITO_INTEROP]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Object:  StoredProcedure [dbo].[BANDO_GARA_CREATE_FROM_CREA_INVITO_INTEROP]    Script Date: 20/03/2024 10:44:35 ******/


CREATE PROCEDURE [dbo].[OLD_BANDO_GARA_CREATE_FROM_CREA_INVITO_INTEROP] 
	( @idDoc int  , @idUser int )
AS
BEGIN 
	declare @id int
	declare @strDesc varchar(200)
	declare @ProtocolBG  varchar(50)
	declare @TipoBandoGara varchar(100)
	declare @ProceduraGara varchar(100)
	declare @giroRistetta int
	declare @idPda INT
	declare @ProtocolloAvviso as varchar(50)
	declare @pcp_CodiceAppaltoAvviso as nvarchar(1000)
	declare @RifiutaProsegui as int
	declare @num INT
	declare @idRow int
	declare @Cn16_CodiceAppaltoAvviso  nvarchar(500)
	declare @Importobaseasta as float
	declare @importoBaseAsta2 as float
	declare @Opzioni as float
	declare @Oneri  as float
	declare @Appalto_PNRR_PNC as char(1)
	declare @Appalto_PNRR varchar(10)
	declare @Appalto_PNC varchar(10)
	declare @Motivazione_Appalto_PNRR varchar(max)
	declare @Motivazione_Appalto_PNC varchar(max)
	declare @FLAG_PREVISIONE_QUOTA  varchar(10)
	declare @QUOTA_FEMMINILE varchar(10)
	declare @QUOTA_GIOVANILE varchar(10)
	declare @ID_MOTIVO_DEROGA varchar(10)
	declare @FLAG_MISURE_PREMIALI varchar(10) 
	declare @ID_MISURA_PREMIALE varchar(10)
	declare @RegimeAllegerito varchar(10)
	declare @pcp_tiposcheda as varchar(50)

	set @Id = 0
	set @giroRistetta = 0

	IF EXISTS ( select id from CTL_DOC with(nolock) where Id = @idDoc and TipoDoc = 'PDA_MICROLOTTI' )
	BEGIN

		set @giroRistetta = 1
		set @idPda = @idDoc
		
		--recupero id della gara
		select @idDoc = LinkedDoc  from CTL_DOC with(nolock) where Id = @idDoc

	END
	
	

	--utile per il copia avviso in input
	set @RifiutaProsegui = 1

	-- cerca una versione precedente del documento LEGATA ALL'AVVISO / BANDO 
	select @Id = id 
		from CTL_DOC with(nolock)
			where LinkedDoc = @idDoc and TipoDoc = 'BANDO_GARA' and deleted = 0 --and StatoDoc = 'Saved' 
	
	--SE NON ESISTE LO CREO
	if isnull(@Id , 0 ) = 0 
	BEGIN

		--RECUPERO INFO DALL'AVVISO/BANDO
		select  
				@strDesc  = case when TipoBandoGara  in ( '1' , '4' ) then dbo.CNV( 'dall'' Avviso' , 'I' ) else dbo.CNV( 'dal Bando' , 'I' ) end
				, @TipoBandoGara = TipoBandoGara
				, @ProceduraGara = ProceduraGara
				, @ProtocolBG = Fascicolo
				, @ProtocolloAvviso = Protocollo
				, @Importobaseasta = ImportoBaseAsta
				, @importoBaseAsta2 = ImportoBaseAsta2
				, @opzioni = opzioni
				, @oneri=isnull(oneri,0)
				, @Appalto_PNRR_PNC=Appalto_PNRR_PNC , @Appalto_PNRR = Appalto_PNRR, @Appalto_PNC = Appalto_PNC
				, @Motivazione_Appalto_PNRR=Motivazione_Appalto_PNRR, @Motivazione_Appalto_PNC = Motivazione_Appalto_PNC, @FLAG_PREVISIONE_QUOTA = FLAG_PREVISIONE_QUOTA
				, @QUOTA_FEMMINILE = QUOTA_FEMMINILE, @QUOTA_GIOVANILE = QUOTA_GIOVANILE, @ID_MOTIVO_DEROGA = ID_MOTIVO_DEROGA, @FLAG_MISURE_PREMIALI = FLAG_MISURE_PREMIALI
				, @ID_MISURA_PREMIALE = ID_MISURA_PREMIALE,@RegimeAllegerito = RegimeAllegerito

			from 
				CTL_DOC	WITH(NOLOCK)
					inner join document_Bando WITH(NOLOCK) on idHeader = id
			where Id = @idDoc


		------------------------------------------------------------------------------------
		-- SE PROVENGO DA AVVISO-NEGOZIATA PASSO LO STATO FUNZIONALE DELLA GARA A CHIUSO ---
		------------------------------------------------------------------------------------
		update 
			CTL_DOC 
				set statofunzionale = 'Chiuso' 
			where id = @idDoc and ( ( @TipoBandoGara = '1' and @ProceduraGara = 15478 )
									or ( @TipoBandoGara = '2' and @ProceduraGara = 15477 ) )
	
		--METTO A CHIUSO ANCHE LA PDA SE SONO SUL GIRO BANDO-RISTRETTA
		IF @giroRistetta = 1
		BEGIN
			update CTL_DOC 
					set statofunzionale = 'Chiuso' 
				WHERE Id = @idPda
		END

		--FACCIO LA COPIA DEL DOCUMENTO AVVISO/BANDO 
		EXEC BANDO_GARA_COPIA @idDoc,@IdUser,@id out,@RifiutaProsegui
		
		--TOLGO I DESTINATARI DA NUOVO DOCUMENTO IN QUANTO LA BANDO_GARA_COPIA li ha ripresi dal precedente
		delete from CTL_DOC_Destinatari where idHeader=@Id
		
		--RECUPERO MODELLO ASSOCIATO ALLA GARA NUOVA
		declare @IdModelloInvito as int
		select @IdModelloInvito = value 
			from ctl_doc_value with (nolock) where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'
		
		--GENERO TUTTI I MODELLI CHE SERVONO ALLA COMPILAZIONE (ENTE/OE)
		exec GENERA_MODELLI_CONTESTO @IdModelloInvito,@idUser

		--SUL MODELLO SETTO CORRETTO
		delete CTL_DOC_Value where idheader=@IdModelloInvito  and DSE_ID='STATO_MODELLO' and DZT_Name='Stato_Modello_Gara'
		insert into  CTL_DOC_Value 
			(idheader,dse_id,dzt_name,row,value)
			values
			(@IdModelloInvito,'STATO_MODELLO','Stato_Modello_Gara',0,'CORRETTO' )

		--AGGIUSTO IL TITOLO DEL DOCUMENTO, ASSOCIO IL NUOVO DOCUMENTO CREATO ALL'AVVISO/BANDO PRECEDENTE
		update 
			CTL_DOC 
				set Titolo='Invito ' + @strDesc + ' ' + @ProtocolloAvviso,
					LinkedDoc = @idDoc
			where Id = @id

		--LO FACCIO DIVENTARE UN INVITO e RIPORTO GLI IMPORTI DALL'AVVISO
		update
			Document_Bando
				
				set 
					TipoBandoGara = '3',
					EvidenzaPubblica = case when @ProceduraGara = '15477' then '0' else '1' end,
					ImportoBaseAsta = @Importobaseasta,	importobaseasta2 = @importoBaseAsta2,oneri=@Oneri,Opzioni=@Opzioni
					,Appalto_PNRR_PNC= @Appalto_PNRR_PNC, Appalto_PNRR=@Appalto_PNRR,Appalto_PNC=@Appalto_PNC
					,Motivazione_Appalto_PNRR=@Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC=@Motivazione_Appalto_PNC
					,ID_MOTIVO_DEROGA=@ID_MOTIVO_DEROGA,FLAG_MISURE_PREMIALI=@FLAG_MISURE_PREMIALI, FLAG_PREVISIONE_QUOTA=@FLAG_PREVISIONE_QUOTA
					,QUOTA_FEMMINILE=@QUOTA_FEMMINILE,QUOTA_GIOVANILE=@QUOTA_GIOVANILE,ID_MISURA_PREMIALE=@ID_MISURA_PREMIALE
					,RegimeAllegerito= @RegimeAllegerito  ,
					DataRiferimentoInizio=null,DataTermineQuesiti=null,DataTermineRispostaQuesiti=null,
					DataScadenzaOfferta=null,DataAperturaOfferte=null

					
			where idHeader = @id
	    
		
		

		--SULLA TAB INTEROP RIPORTO IL PCP CODICE APPALTO DELL'AVVISO
		--perche la gara e unica per anac
		select @pcp_CodiceAppaltoAvviso = pcp_CodiceAppalto,
			@pcp_tiposcheda=pcp_TipoScheda 
			from Document_PCP_Appalto WITH(NOLOCK) where idHeader=@idDoc

		update
			Document_PCP_Appalto
				set pcp_CodiceAppalto = @pcp_CodiceAppaltoAvviso,
					 pcp_TipoScheda = @pcp_tiposcheda 
			where idHeader =@id
  
		select 
			@Cn16_CodiceAppaltoAvviso=CN16_CODICE_APPALTO
			from 
				Document_E_FORM_CONTRACT_NOTICE
			WITH(NOLOCK) where idHeader=@idDoc
		
		update
			Document_E_FORM_CONTRACT_NOTICE
				set CN16_CODICE_APPALTO = @Cn16_CodiceAppaltoAvviso
			where idHeader =@id

		
		-- SE L'UTENTE HA EFFETTUATO UN SORTEGGIO PUBBLICO CONGELO I DESTINATARI TRA QUELLI SORTEGGIATI
		IF EXISTS 
				( select id from CTL_DOC sortPub with(nolock) 
					where sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' 
						and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato' )
					OR
				@giroRistetta = 1
		BEGIN
			IF @giroRistetta = 0
			BEGIN

				insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
					select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, a.IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, NumRiga, a.ordinamento
					from CTL_DOC_Destinatari a with(nolock)
							inner join aziende b with(nolock) on b.idazi=a.idazi
							left join DM_Attributi c with(nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
							inner join CTL_DOC sortPub with(nolock) on sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato'	
							inner join 	Document_AziSortPub sb with(nolock) on sb.idAzi = a.IdAzi and sb.idHeader = sortPub.id
					where a.idheader = @idDoc and isnull(StatoIscrizione,'') = ''

			END
			ELSE
			BEGIN

				insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
					select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, a.NumRiga, ordinamento
					from CTL_DOC_Destinatari a with(nolock)
							inner join aziende b with(nolock) on b.idazi=a.idazi
							inner join Document_PDA_OFFERTE pdaOff with(nolock) on pdaOff.IdHeader = @idPda and pdaOff.StatoPDA = '2' and pdaOff.idAziPartecipante = b.IdAzi
							left join DM_Attributi c with(nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
					where a.idheader = @idDoc --and isnull(StatoIscrizione,'') = ''

			END

			set @num=1

			declare CurProg Cursor Static for 
											select idRow 
											from CTL_DOC_Destinatari with(nolock)
											where idHeader = @Id	
											order by ordinamento

			open CurProg
			FETCH NEXT FROM CurProg INTO @idrow

			WHILE @@FETCH_STATUS = 0
			BEGIN

				update CTL_DOC_Destinatari 
						set NumRiga=@num 
					where idrow=@idrow
				 
				set @num = @num + 1
				 			 
				FETCH NEXT FROM CurProg INTO @idrow

			END 

			CLOSE CurProg
			DEALLOCATE CurProg
		END

		--lo richiamo perchè era stato copiato come AVVISO e adeso E' un invito
		exec BANDO_GARA_DEFINIZIONE_STRUTTURA @id


		--INNESCO LA CREAZIONE DELLA SCHEDA S1 PER ANAC
		--per innescare il crea scheda (id dell'avviso)
		exec PCP_SCHEDE_INSERT_REQUEST @idDoc,@idUser ,'S1','CreaScheda'



	END

	-- rirorna l'id del nuovo documento creato
	select @id as id
END
GO
