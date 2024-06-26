USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[FascicoloGara_Elaborazione_Set_Path_PerFase]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Versione=1&data=2022-05-17&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[FascicoloGara_Elaborazione_Set_Path_PerFase] ( @IdRow as int )
AS

BEGIN
	
	declare @TipoDoc as varchar(100)
	declare @Protocollo as varchar(100)
	declare @DSE_ID as varchar(200)
	declare @AreaDiAppartenenza as varchar(200)
	
	declare @Path as varchar(500)
	declare @NomeFile as varchar(500)
	declare @JumpCheck as varchar(100)
	declare @IdDocumento as int
	declare @OperatoreEconomico as nvarchar(1000)
	declare @IdAzi_OE as int
	declare @FascicoloGara as varchar(50)
	declare @GeneraConvenzione as varchar(10)
	declare @Jumpcheck_CapoGruppo as varchar(100)
	declare @NumeroLotto as varchar(10)
	declare @Titolo as nvarchar(500)
	declare @Titolo_Protocollo_Padre as nvarchar(200)
	declare @CodiceFiscale as nvarchar(50)
	set @CodiceFiscale=''
	
	--recupero le info per determinare il path
	select 
			@JumpCheck= isnull(D.JumpCheck,''), 
			@TipoDoc = isnull(D.tipodoc,DF.tipodoc) , 
			@IdDocumento= isnull(D.id,DF.IdDoc), 
			@DSE_ID=FA.DSE_ID, 
			@AreaDiAppartenenza= isnull(FA.AreaDiAppartenenza,''),
			@FascicoloGara = D.Fascicolo,
			@Titolo = isnull(D.Titolo,'')
			from 
				Document_Fascicolo_Gara_Allegati FA with (nolock)
						
					left join ctl_doc D  with (nolock) on D.id = FA.IdDoc   and D.TipoDoc not in ('DETAIL_CHIARIMENTI_BANDO_DOMANDA' , 'DETAIL_CHIARIMENTI_BANDO_RISPOSTA')
						
					--per i chiarimemti vado sulla tabella con dse_id dove ho il tipodoc se domanda o risposta
					left join Document_Fascicolo_Gara_Documenti DF with (nolock) on DF.idheader = FA.idheader and DF.IdDoc = FA.IdDoc 
																		--and FA.DSE_ID = DF.TipoDoc 
																		and ( 
																				--per i chiarimenti inviati dagli OE e per le risposte senza allegati coincide il TIPODOC con DSE_ID
																				FA.DSE_ID = DF.TipoDoc 
																				or 
																				--per i documenti risposta ai quesiti se ci sono allegati sono nella sezione testata
																				 FA.DSE_ID='TESTATA' and DF.tipodoc='DETAIL_CHIARIMENTI_BANDO_RISPOSTA'
																				) 

																		and DF.tipodoc in ('DETAIL_CHIARIMENTI_BANDO_DOMANDA' , 'DETAIL_CHIARIMENTI_BANDO_RISPOSTA')
			where 
				FA.idRow = @IdRow 

					
	
				
	set @Path=''
	set @NomeFile=''

	---------------------------------------------------------------------------------------			
	if @TipoDoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' ) 
	begin

		set @Path = '01 Gara' 
			
		if  @DSE_ID  in ( 'DOCUMENTAZIONE' , 'TESTATA' )
			set @Path = @Path + '\' + 'Atti di Gara'
		
		
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'NEW_RISULTATODIGARA'
	begin

		set @Path = '01 Gara' 
			
		--if  @DSE_ID = 'TESTATA'
			set @Path = @Path + '\' + 'Esiti e Pubblicazioni'
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'AVVISO_GARA'
	begin

		set @Path = '01 Gara' 
			
		--if  @DSE_ID = 'TESTATA'
			set @Path = @Path + '\' + 'Avvisi'
					
	end
	

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'BANDO_MODIFICA'
	begin

		set @Path = '01 Gara' 
			
		--if  @DSE_ID = 'ATTI_GARA'
			set @Path = @Path + '\' + 'Modifica'
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'COMMISSIONE_PDA'
	begin

		set @Path = '03 PDA' 
			
		set @Path = @Path + '\' + 'Commissioni'
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'DOMANDA_PARTECIPAZIONE'
	begin

		set @Path = '02 Offerta' 
			
		if  @DSE_ID = 'DOCUMENTAZIONE'
			set @Path = @Path + '\' + '01 Amm'
			
			
		--recupero ragione sociale del fornitore 

	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'OFFERTA'
	begin

		set @Path = '02 Offerta' 
		set @OperatoreEconomico=''
		--recupero ragione sociale del fornitore 
		select @OperatoreEconomico = aziRagioneSociale  , @CodiceFiscale=vatValore_FT
			from ctl_doc  with (nolock)
				inner join aziende with (nolock) on idazi = azienda 
				inner join dm_attributi with (nolock) on lnk = idazi and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 
		
		if  @DSE_ID in ( 'DOCUMENTAZIONE','DGUE','DGUE_AUSILIARIE' , 'DGUE_ESECUTRICI', 'DGUE_RTI')
			set @Path = @Path + '\' + '01 Amm'
			
		if @DSE_ID = 'BUSTA_TECNICA'
			set @Path = @Path + '\' + '02 Tecnica'

		if @DSE_ID = 'BUSTA_ECONOMICA'
			set @Path = @Path + '\' + '03 Economica'
			
		if @AreaDiAppartenenza <> '' 
			set @Path = @Path + '\' + @AreaDiAppartenenza 

		
		--tolgo dalla ragione sociale i caratteri non ammessi per i nomi dei folder  \ / : * ? " < > |
		--e lo tronco a 100 caratteri
		set @OperatoreEconomico = @CodiceFiscale + '_' + dbo.NormStringPURGEExt (@OperatoreEconomico,'\/:*?"<>|',' ',30)

		set @Path = @Path + '\' + @OperatoreEconomico
	

	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_COMUNICAZIONE_GARA', 'PDA_COMUNICAZIONE_GENERICA')
	begin
		
		if @JumpCheck = '0-SOSPENSIONE_GARA'
			set @Path = '01 Gara\Sospensione' 
		
		if @JumpCheck in ( '1-GARA_COMUNICAZIONE_GENERICA','0-GARA_COMUNICAZIONE_GENERICA' ) 
			set @Path = '01 Gara\Comunicazioni\Inviate' 

		--if @JumpCheck = '0-PROSSIMA_SEDUTA'
		--	set @Path = '03 PDA\Comunicazione Inviate' 
			
		--if @JumpCheck = '1-GENERICA'
		--	set @Path = '03 PDA\Comunicazioni\Comunicazione Inviate' 

		if @JumpCheck in ( '0-GENERICA','1-GENERICA','1-VERIFICA_INTEGRATIVA','0-ESITO','1-ESCLUSIONE','0-ESCLUSIONE','0-LOTTI_ESCLUSIONE','1-LOTTI_ESCLUSIONE',
							'0-ESITO_DEFINITIVO_MICROLOTTI', '0-VERIFICA_AMMINISTRATIVA', '0-AGGIUDICAZIONE_PROV',
							'1-CHIARIMENTI','1-VERIFICA_REQUISITI','0-ESITO_MICROLOTTI','0-PROSSIMA_SEDUTA' , '0-RICHIESTA_STIPULA_CONTRATTO', '1-RICHIESTA_STIPULA_CONTRATTO','0-COM_ART_36' ) 
		
		begin
			
			if @JumpCheck='0-COM_ART_36'
				set @Path = '03 PDA\Comunicazioni\Inviate\Art36co2' 
			else
				set @Path = '03 PDA\Comunicazioni\Inviate' 
			
			--recuperare il titolo ed il protocollo della comunicazione padre
			--path + '\' +  p.titolo + ' ' + p.protocollo
			
			set @Titolo_Protocollo_Padre = ''

			select 
				@Titolo_Protocollo_Padre = left(p.Titolo,50) + ' ' + p.Protocollo
				 from 
					document_fascicolo_gara_allegati a with (nolock)
						--salgo sul documento corrente
						inner join ctl_doc d with(nolock) on a.iddoc = d.id
						--salgo sulla capogruppo
						inner join ctl_doc p with(nolock) on d.linkeddoc = p.id

			   where a.idrow = 	@IdRow 
			
			----tolgo caratteri non ammessi nel nome di una cartella
			if @Titolo_Protocollo_Padre <> ''
				set @Path = @Path + '\' +  dbo.NormStringPURGEExt (@Titolo_Protocollo_Padre,'\/:*?"<>|',' ',100) 


		end

		if @JumpCheck = '0-REVOCA_BANDO'
			set @Path = '01 Gara\Revoca'

		if @JumpCheck = '0-RETTIFICA_BANDO_GARA'
			set @Path = '01 Gara\Rettifica' 
		
		if @JumpCheck = '0-PROROGA_BANDO_GARA'
			set @Path = '01 Gara\Proroga' 
		
		if @JumpCheck = '0-RIPRISTINO_GARA'
			set @Path = '01 Gara\Ripristina'

		if @JumpCheck in ('0-RETTIFICA_TECNICA_OFFERTA','0-RETTIFICA_ECONOMICA_OFFERTA')
			set @Path = '03 PDA\Comunicazioni\Ricevute' 

			
		
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('CONTRATTO_GARA')
	begin
			--recupero caratteristica generaconvenzione dalla gara
			select 
				@GeneraConvenzione =GeneraConvenzione
				from 
					ctl_doc with (nolock)
						inner join document_bando with (nolock) on idHeader = id
				where fascicolo=@FascicoloGara and tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')

			if @GeneraConvenzione <> '1'
				--se la gara non sfocia in convenzione 
				set @Path = '04 Contratto' 
			else

				--altrimenti
				set @Path = '04 Convenzione' 
	
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('VERIFICA_ANOMALIA')
	begin
	
			set @Path = '03 PDA\Calcolo anomalia' 
			if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('SEDUTA_PDA')
	begin
	
			set @Path = '03 PDA\Verbali Seduta' 
			if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 
	end
	
	---------------------------------------------------------------------------------------
	if @TipoDoc in ('RICHIESTA_ATTI_GARA' , 'INVIO_ATTI_GARA ')
	begin

		set @Path = '05 Richieste accesso atti'
		
		--agggiungo il fornitore che ha fatto la richiesta
		if @TipoDoc='RICHIESTA_ATTI_GARA'
		begin
			select 
				@OperatoreEconomico = a.aziRagioneSociale  , @CodiceFiscale=vatValore_FT
				from ctl_doc c with (nolock)
					inner join profiliutente p with (nolock) on p.IdPfu = c.IdPfu
					inner join aziende a with (nolock) on idazi = pfuIdAzi 
					inner join dm_attributi with (nolock) on lnk = a.idazi and dztNome = 'codicefiscale' and idApp=1
				where id = @IdDocumento 
		end
		else
		begin
			select 
				@OperatoreEconomico = a.aziRagioneSociale  , @CodiceFiscale=vatValore_FT
				from ctl_doc c with (nolock)
					inner join ctl_doc R  with (nolock) on  R.id  = C.LinkedDoc 
					inner join profiliutente p with (nolock) on p.IdPfu = R.IdPfu
					inner join aziende a with (nolock) on idazi = pfuIdAzi 
					inner join dm_attributi with (nolock) on lnk = a.idazi and dztNome = 'codicefiscale' and idApp=1
				where c.id = @IdDocumento 
		end

		--tolgo dalla ragione sociale i caratteri non ammessi per i nomi dei folder  \ / : * ? " < > |
		--e lo tronco a 100 caratteri
		set @OperatoreEconomico = @CodiceFiscale + '_' +dbo.NormStringPURGEExt (@OperatoreEconomico,'\/:*?"<>|',' ',30)

		set @Path = @Path + '\' + @OperatoreEconomico

	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('CHIUDI_PROCEDURA_GARA')
	begin
		set @Path = '04 Accordo di Servizio'
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'RETTIFICA_GARA'
	begin

		set @Path = '01 Gara\Rettifica' 
			
		if  @DSE_ID = 'ATTI_GARA'
			set @Path = @Path + '\' + 'Atti'
		
		if  @DSE_ID = 'ALLEGATI'
			set @Path = @Path + '\' + 'Allegati'
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PROROGA_GARA')
	begin
		set @Path = '01 Gara\Proroga' 
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('RIPRISTINO_GARA')
	begin
		set @Path = '01 Gara\Ripristina' 
	end


	---------------------------------------------------------------------------------------
	if @TipoDoc in ('BANDO_REVOCA_LOTTO')
	begin
		set @Path = '01 Gara\Revoca Lotto' 
	end
    
    ---------------------------------------------------------------------------------------
	if @TipoDoc in ('SOSTITUZIONE_RUP')
	begin
		set @Path = '01 Gara\Sostituzione Rup' 
	end
    
    
	 ---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_COMUNICAZIONE_RISP')
	begin
		
		select 
				@Jumpcheck_CapoGruppo = CG.JumpCheck 
			from 
				ctl_doc C with (nolock)
					inner join ctl_Doc CG with (nolock) on CG.id = C.LinkedDoc 
			where C.Id = @IdDocumento 
		
		--se jumpcheck della capogruppo è 1-GARA_COMUNICAZIONE_GENERICA   Gara\Comunicazioni\ Risposte\ 
		if @Jumpcheck_CapoGruppo = '1-GARA_COMUNICAZIONE_GENERICA'
			set @Path = '01 Gara\Comunicazioni\Risposte'
		
		--se jumpcheck della capogruppo è 1-GENERICA     PDA\Comunicazioni\ Risposte\  
		if @Jumpcheck_CapoGruppo in ( '1-GENERICA','1-VERIFICA_INTEGRATIVA')
			set @Path = '03 PDA\Comunicazioni\Risposte' 
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA')
	begin
		set @Path = '03 PDA\Offerte Migliorative\Richieste'
	end

	 ---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP')
	begin
		set @Path = '03 PDA\Offerte Migliorative\Risposte'
	end

	
	----------------------------------------------------------------------------------------
	if @TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA' , 'ESITO_ESCLUSA', 'ESITO_LOTTO_ANNULLA', 'ESITO_LOTTO_ESCLUSA', 
			'ESITO_LOTTO_VERIFICA','ESITO_VERIFICA', 'ESITO_ANNULLA', 'ESITO_ECO_LOTTO_ANNULLA', 'ESITO_LOTTO_AMMESSA','ESITO_RIAMMISSIONE'
			,'ESCLUDI_LOTTI','ESITO_ECO_LOTTO_ESCLUSA','ESITO_LOTTO_SCIOGLI_RISERVA','ESITO_ECO_LOTTO_AMMESSA','ESITO_ECO_LOTTO_VERIFICA','ESITO_AMMESSA_EXART133' )
	begin
		set @Path = '03 PDA\Esiti'
		if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 	
	end
	
	 ---------------------------------------------------------------------------------------
	if @TipoDoc in ('ESITO_LOTTO_ANOMALIA')
	begin
		set @Path = '03 PDA\Calcolo anomalia'

		--recupero il lotto
		select @NumeroLotto = isnull(NumeroLotto , '')  from 
			ctl_Doc E with (nolock)
				inner join Document_MicroLotti_Dettagli PDA_OFF  with (nolock) on PDA_OFF.id = E.LinkedDoc
			where 
				E.id = @IdDocumento 

		if @NumeroLotto <> ''
			set @Path = @Path + '\Lotto ' + @NumeroLotto 
	end

	
	----------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_GRADUATORIA_AGGIUDICAZIONE','DECADENZA','PDA_BACK_ECO' , 'PDA_BACK_TEC' , 'PDA_SORTEGGIO_OFFERTA', 
					'RETT_VALORE_ECONOMICO','PDA_MICROLOTTI_MODIFICA','PDA_MICROLOTTI')
	begin
		set @Path = '03 PDA\Altro'
		if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 

	end


	----------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_VALUTA_LOTTO_TEC')
	begin
		set @Path = '03 PDA\Scheda Tecnica' 
		if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_VALUTA_LOTTO_ECO')
	begin
		set @Path = '03 PDA\Scheda Economica' 
		if @AreaDiAppartenenza <> '' 
				set @Path = @Path + '\' + @AreaDiAppartenenza 
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('VERBALEGARA')
	begin
		set @Path = '03 PDA\Verbali' 
		
	end
	
	----------------------------------------------------------------------------------------
	if @TipoDoc in ('CONFORMITA_MICROLOTTI')
	begin
		set @Path = '03 PDA\Tecnica' 
		
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('CONVENZIONE')
	begin
		set @Path = '04 Convenzione\Allegati' 
		
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('LISTINO_CONVENZIONE')
	begin
		set @Path = '04 Convenzione\Listini' 
		
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('CONTRATTO_CONVENZIONE')
	begin
		set @Path = '04 Convenzione\Contratti' 
		
	end

	if @TipoDoc in ( 'SCRITTURA_PRIVATA' )
	begin
		set @Path = '04 Contratti' 
		
	end
	
	----------------------------------------------------------------------------------------
	if @TipoDoc in ('DETAIL_CHIARIMENTI_BANDO_DOMANDA')
	begin
		set @Path = '01 Gara\Quesiti' 
		
	end

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('DETAIL_CHIARIMENTI_BANDO_RISPOSTA')
	begin
		set @Path = '01 Gara\Risposte ai quesiti' 
	
	end

	

	----------------------------------------------------------------------------------------
	if @TipoDoc in ('RIAMMISSIONE_OFFERTA')
	begin
		set @Path = '01 Gara\Riammissione Offerta' 
		
	end
	
	----------------------------------------------------------------------------------------
	if @TipoDoc in ('RITIRA_OFFERTA')
	begin
		set @Path = '02 Offerta\04 Ritiro Offerta' 
		
		set @OperatoreEconomico=''
		--recupero ragione sociale del fornitore 
		select @OperatoreEconomico = aziRagioneSociale  , @CodiceFiscale=vatValore_FT
			from ctl_doc  with (nolock)
				inner join aziende with (nolock) on idazi = azienda 
				inner join dm_attributi with (nolock) on lnk = idazi and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 
		
		--tolgo dalla ragione sociale i caratteri non ammessi per i nomi dei folder  \ / : * ? " < > |
		--e lo tronco a 100 caratteri
		set @OperatoreEconomico = @CodiceFiscale + '_' + dbo.NormStringPURGEExt (@OperatoreEconomico,'\/:*?"<>|',' ',30)

		set @Path = @Path + '\' + @OperatoreEconomico
	
	end
	
	-- Per inserire nuovi allegati dal documento FASCICOLO_GARA aggiungiamo un path dedicato
	if @TipoDoc = 'FASCICOLO_DOCUMENTI_AGGIUNTIVI'
	begin
		set @Path = 'Documenti esterni' 		
	end
	
	update Document_Fascicolo_Gara_Allegati set [path]=@Path  where idrow = @IdRow

END -- Fine stored

GO
