USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_FascicoloGara_Elaborazione_Set_NomeFile]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














--Versione=1&data=2022-05-17&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[OLD_FascicoloGara_Elaborazione_Set_NomeFile] ( @IdRow as int, @ProtocolloGara as varchar(50) )
AS

BEGIN
	
	declare @TipoDoc as varchar(100)
	
	declare @DSE_ID as varchar(200)
	declare @AreaDiAppartenenza as varchar(200)
	
	
	declare @NomeFile as varchar(500)
	declare @JumpCheck as varchar(100)
	declare @IdDocumento as int
	declare @CodiceFiscale as nvarchar(50)
	declare @Protocollo as varchar(100)
	declare @DataInvio as varchar(8)
	declare @ExtAllegato as varchar(500)
	declare @Tipologia as varchar(50)
	declare @Encrypted as varchar(10)
	
	--RECUPERO LE INFO DEGLI ALTRI DOCUMENTI
	select 
			@JumpCheck= isnull(D.JumpCheck,''), 
			@TipoDoc = isnull(D.tipodoc,DF.tipodoc) , 
			@IdDocumento= isnull(D.id,DF.IdDoc), 
			@DSE_ID=FA.DSE_ID, 
			@AreaDiAppartenenza= isnull(FA.AreaDiAppartenenza,''),
			@Protocollo = isnull(D.Protocollo,DF.Protocollo ),
			@DataInvio = convert (varchar(8) , isnull(D.DataInvio,DF.DataInvio ) , 112),
			@ExtAllegato = dbo.getpos(FA.Attach ,'*',1),
			@Encrypted = isnull(Encrypted,0) , 
			@Tipologia = isnull( td.REL_ValueOutput , D.TipoDoc )

			from 
				Document_Fascicolo_Gara_Allegati FA with (nolock)
					
					left join
							ctl_doc D  with (nolock) on D.id = FA.IdDoc and D.TipoDoc not in ('DETAIL_CHIARIMENTI_BANDO_DOMANDA' , 'DETAIL_CHIARIMENTI_BANDO_RISPOSTA')
					
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

					left join CTL_Relations TD with(nolock) on TD.REL_Type = 'FASCICOLO_GARA_TIPO_FILE' and TD.REL_ValueInput = d.TipoDoc
							
			where 
				FA.idRow = @IdRow 
				
				
	--il nome inizia sempre con il protocollo gara 

	-- nome base del file eventualmente sovrascritto se necessario
	set @NomeFile = @ProtocolloGara + '_' + isnull( @Tipologia , 'BASE' ) + '_' + @Protocollo + '_' + @DataInvio

	---------------------------------------------------------------------------------------
	if @TipoDoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' ) 
	begin

		if  @DSE_ID = 'DOCUMENTAZIONE'
			set @NomeFile = @ProtocolloGara + '_' + 'ATTI' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'NEW_RISULTATODIGARA'
	begin

			
		if  @DSE_ID = 'TESTATA'
			set @NomeFile = @ProtocolloGara + '_' + 'ESITO' + '_' + @Protocollo + '_' + @DataInvio
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'NEW_RISULTATODIGARA'
	begin

			
		if  @DSE_ID = 'TESTATA'
			set @NomeFile = @ProtocolloGara + '_' + 'AVVISO' + '_' + @Protocollo + '_' + @DataInvio
					
	end
	---------------------------------------------------------------------------------------
	if @TipoDoc = 'BANDO_MODIFICA'
	begin

			
		if  @DSE_ID = 'ATTI_GARA'
			set @NomeFile = @ProtocolloGara + '_' + 'MODIFICA' + '_' + @Protocollo + '_' + @DataInvio
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'COMMISSIONE_PDA'
	begin

		--set @Path = 'Documenti di Procedura di Aggiudicazione' 
			
		if  @DSE_ID in ( 'ATTI', 'ATTIG', 'ATTIC' )
			set @NomeFile = @ProtocolloGara + '_' + 'COMM' + '_' + @Protocollo + '_' + @DataInvio
					
	end

	---------------------------------------------------------------------------------------
	--if @TipoDoc = 'DOMANDA_PARTECIPAZIONE'
	--begin

	--	--set @Path = 'Documenti di Offerta' 
			
	--	if  @DSE_ID = 'DOCUMENTAZIONE'
	--		set @Path = @Path + '\' + 'Valutazione Amministrativa'
			
			
	--	--recupero ragione sociale del fornitore 

	--end

	---------------------------------------------------------------------------------------
	if @TipoDoc  in ( 'OFFERTA', 'DOMANDA_PARTECIPAZIONE' , 'MANIFESTAZIONE_INTERESSE')
	begin
		
		
		set @NomeFile = @ProtocolloGara + '_'  + @Protocollo

		set @CodiceFiscale=''
		--recupero ragione sociale del fornitore 
		select top 1 @CodiceFiscale = vatValore_FT 
			from ctl_doc  with (nolock)
				inner join aziende with (nolock) on idazi = azienda 
				inner join dm_attributi with (nolock) on lnk = azienda and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 

		
		if  @DSE_ID = 'DOCUMENTAZIONE'
			 set @NomeFile = @NomeFile + '_BA_' 
			
		if @DSE_ID = 'BUSTA_TECNICA'
			set @NomeFile = @NomeFile + '_BT_' 

		if @DSE_ID = 'BUSTA_ECONOMICA'
			set @NomeFile = @NomeFile + '_BE_' 
			
		if @DSE_ID in ( 'DGUE','DGUE_AUSILIARIE' , 'DGUE_ESECUTRICI', 'DGUE_RTI' ) 
			set @NomeFile = @NomeFile + '_' + @DSE_ID + '_' 

		set @NomeFile = @NomeFile +	 @CodiceFiscale + '_' + @DataInvio
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_COMUNICAZIONE_GARA', 'PDA_COMUNICAZIONE_GENERICA')
	begin
		
		--if @JumpCheck in ( ,'1-VERIFICA_INTEGRATIVA','0-ESITO','0-ESCLUSIONE',
		--					'0-ESITO_DEFINITIVO_MICROLOTTI', '0-VERIFICA_AMMINISTRATIVA', '0-AGGIUDICAZIONE_PROV',
		--					'1-CHIARIMENTI','1-VERIFICA_REQUISITI','0-ESITO_MICROLOTTI')
		
		
		if  @JumpCheck in  ('0-ESITO_DEFINITIVO_MICROLOTTI','0-AGGIUDICAZIONE_PROV','0-ESITO_MICROLOTTI','0-ESITO')  
			set @Tipologia = 'AGG'
		
		if  @JumpCheck in  ('1-CHIARIMENTI')
			set @Tipologia = 'CHIA'
			
		if  @JumpCheck in  ('1-VERIFICA_REQUISITI')
			set @Tipologia = 'REQU'
		
		if  @JumpCheck in  ('1-VERIFICA_REQUISITI')
			set @Tipologia = 'INTE'
		
		if @JumpCheck in  ('1-ESCLUSIONE','0-ESCLUSIONE','0-LOTTI_ESCLUSIONE','1-LOTTI_ESCLUSIONE')
			set @Tipologia = 'ESCL'
		
		if @JumpCheck in  ('0-VERIFICA_AMMINISTRATIVA')
			set @Tipologia = 'VERAMM'
		
		if @JumpCheck in  ('0-SOSPENSIONE_GARA')
			set @Tipologia = 'SOSP'
		
		if @JumpCheck   in ( '1-GARA_COMUNICAZIONE_GENERICA','0-GARA_COMUNICAZIONE_GENERICA' )
			set @Tipologia = 'COM'

		if @JumpCheck = '0-PROSSIMA_SEDUTA'
			set @Tipologia = 'SEDUTA'
		
		if @JumpCheck in ( '1-GENERICA' ,  '0-GENERICA' )
			set @Tipologia = 'COM'
		
		if @JumpCheck = '0-REVOCA_BANDO'
			set @Tipologia = 'REV'

		if @JumpCheck = '0-RETTIFICA_BANDO_GARA'
			set @Tipologia = 'RETTIFICA'
		
		if @JumpCheck = '0-PROROGA_BANDO_GARA'
			set @Tipologia = 'PROROGA' 
		
		if @JumpCheck = '0-RIPRISTINO_GARA'
			set @Tipologia = 'RIPRISTINA' 
		
		if @JumpCheck = '1-VERIFICA_INTEGRATIVA'
			set @Tipologia = 'INT_AMM' 
				
		if @JumpCheck in ( '0-RICHIESTA_STIPULA_CONTRATTO', '1-RICHIESTA_STIPULA_CONTRATTO'  )
			set @Tipologia = 'RIC_STIP' 
							
		if @JumpCheck = '0-RETTIFICA_TECNICA_OFFERTA'
			set @Tipologia = 'RETTIFICA_TEC_OFF' 

		if @JumpCheck = '0-RETTIFICA_ECONOMICA_OFFERTA'
			set @Tipologia = 'RETTIFICA_ECO_OFF' 
		

		set @NomeFile = @ProtocolloGara + '_' + isnull( @Tipologia , 'BASE' ) + '_' + @Protocollo + '_' + @DataInvio

	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('CONTRATTO_GARA', 'SCRITTURA_PRIVATA')
	begin
	
			set @NomeFile = @ProtocolloGara + '_' + 'CONTR' + '_' + @Protocollo + '_' + @DataInvio
	
	end
	
	---------------------------------------------------------------------------------------
	if @TipoDoc in ('SEDUTA_PDA')
	begin
	
			set @NomeFile = @ProtocolloGara + '_' + 'VERB' + '_' + @Protocollo + '_' + @DataInvio 
			
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('RICHIESTA_ATTI_GARA' , 'INVIO_ATTI_GARA ')
	begin
			
			set @NomeFile = @ProtocolloGara + '_'  + @Protocollo
			
			if @TipoDoc='RICHIESTA_ATTI_GARA'
			begin
				
				--recupero ragione sociale del fornitore 
				select top 1 @CodiceFiscale = vatValore_FT 
					from ctl_doc c with (nolock)
						inner join ProfiliUtente p  with (nolock) on p.idpfu = c.IdPfu
						--inner join aziende with (nolock) on idazi = pfuidazi 
						inner join dm_attributi with (nolock) on lnk = pfuidazi and dztNome = 'codicefiscale' and idapp=1
					where id = @IdDocumento 

				set @NomeFile = @NomeFile + '_' + 'RIC' + '_' + @CodiceFiscale + '_' + @DataInvio 
			end
			else
			begin
				set @NomeFile = @NomeFile + '_' + 'RIS' + '_' + @Protocollo + '_' + @DataInvio 
			end
			
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'CHIUDI_PROCEDURA_GARA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'ACC' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'RIPRISTINO_GARA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'RIPRISTINA' + '_' + @Protocollo + '_' + @DataInvio 
					
	end
	---------------------------------------------------------------------------------------
	if @TipoDoc = 'RETTIFICA_GARA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'RETTIFICA' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'PROROGA_GARA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'PROROGA' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'BANDO_REVOCA_LOTTO'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'REVOCALOTTO' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'PDA_COMUNICAZIONE_RISP'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'COM_RISP' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'RIC' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
	begin
		--recupero codice fiscale del fornitore 
		select top 1 @CodiceFiscale = vatValore_FT 
			from ctl_doc c with (nolock)
				inner join ProfiliUtente p  with (nolock) on p.idpfu = c.IdPfu
				--inner join aziende with (nolock) on idazi = pfuidazi 
				inner join dm_attributi with (nolock) on lnk = pfuidazi and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 

		set @NomeFile = @ProtocolloGara + '_'  + @Protocollo + '_' + 'RIS' + '_' + @CodiceFiscale + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA' , 'ESITO_ESCLUSA', 'ESITO_LOTTO_ANNULLA', 'ESITO_LOTTO_ESCLUSA', 
			'ESITO_LOTTO_VERIFICA','ESITO_VERIFICA' , 'ESITO_LOTTO_ANOMALIA','ESITO_ANNULLA', 'ESITO_ECO_LOTTO_ANNULLA', 'ESITO_LOTTO_AMMESSA','ESITO_RIAMMISSIONE',
			 'ESCLUDI_LOTTI','ESITO_ECO_LOTTO_ESCLUSA','ESITO_LOTTO_SCIOGLI_RISERVA','ESITO_ECO_LOTTO_AMMESSA','ESITO_ECO_LOTTO_VERIFICA','ESITO_AMMESSA_EXART133' )
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'ESITO' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_GRADUATORIA_AGGIUDICAZIONE','DECADENZA','PDA_BACK_ECO' , 'PDA_BACK_TEC' , 'PDA_SORTEGGIO_OFFERTA', 'RETT_VALORE_ECONOMICO','PDA_MICROLOTTI_MODIFICA')
	begin
		
		if @TipoDoc = 'PDA_BACK_ECO' 
			set @Tipologia = 'RIP_ECO'

		if @TipoDoc = 'PDA_BACK_TEC' 
			set @Tipologia = 'RIP_TEC'

		if @TipoDoc = 'PDA_SORTEGGIO_OFFERTA' 
			set @Tipologia = 'SORT'

		if @TipoDoc = 'RETT_VALORE_ECONOMICO' 
			set @Tipologia = 'RETT_ECO'
		
		if @TipoDoc = 'DECADENZA' 
			set @Tipologia = 'DEC'

		if @TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' 
			set @Tipologia = 'GRA'

		if @TipoDoc = 'PDA_MICROLOTTI_MODIFICA' 
			set @Tipologia = 'ALLEGATI'

		set @NomeFile = @ProtocolloGara + '_' + @Tipologia + '_' + @Protocollo + '_' + @DataInvio 
					
	end


	---------------------------------------------------------------------------------------
	if @TipoDoc in ('PDA_VALUTA_LOTTO_TEC','PDA_VALUTA_LOTTO_ECO')
	begin
		set @NomeFile = @ProtocolloGara + '_'  + @Protocollo

		--set @CodiceFiscale=''
		----recupero ragione sociale del fornitore 
		--select top 1 @CodiceFiscale = vatValore_FT 
		--	from ctl_doc  with (nolock)
		--		inner join aziende with (nolock) on idazi = azienda 
		--		inner join dm_attributi with (nolock) on lnk = azienda and dztNome = 'codicefiscale'
		--	where id = @IdDocumento 

		if @TipoDoc = 'PDA_VALUTA_LOTTO_TEC'
			set @Tipologia = 'VAL_TEC'
		if @TipoDoc = 'PDA_VALUTA_LOTTO_ECO'
			set @Tipologia = 'VAL_ECO'

		--set @NomeFile = @NomeFile +	 @CodiceFiscale + '_' + @DataInvio
		set @NomeFile = @NomeFile + '_' + @Tipologia + '_' + @Protocollo + '_' + @DataInvio 


	end


	---------------------------------------------------------------------------------------
	if @TipoDoc = 'VERBALEGARA'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'VER' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc = 'CONFORMITA_MICROLOTTI'
	begin

		set @NomeFile = @ProtocolloGara + '_' + 'CONF_TEC' + '_' + @Protocollo + '_' + @DataInvio 
					
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('CONVENZIONE','LISTINO_CONVENZIONE','CONTRATTO_CONVENZIONE')
	begin
		set @NomeFile = @ProtocolloGara + '_' + 'CONV' + '_' + @Protocollo + '_' + @DataInvio 
		
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('DETAIL_CHIARIMENTI_BANDO_DOMANDA')
	begin
		
		--PER I QUESITI INVIATI DEVO AGGIUNGERE CF OE NEL NOME
		
		--recupero codice fiscale OE
		set @CodiceFiscale=''
		--recupero ragione sociale del fornitore 
		select top 1 @CodiceFiscale = vatValore_FT 
			from document_chiarimenti  with (nolock)
				inner join profiliutente with (nolock) on idpfu = UtenteDomanda  and pfuVenditore <> 0
				inner join dm_attributi with (nolock) on lnk = pfuidazi and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 
		
		--se codice fiscale vuoto vuol dire che è un quesito di iniziativa 
		if @CodiceFiscale = ''
			set @NomeFile = @ProtocolloGara + '_'  + @Protocollo + '_' + 'QUES_INIZ' + '_' + @DataInvio 
		else
			set @NomeFile = @ProtocolloGara + '_'  + @Protocollo + '_' + 'QUES' + '_' + @CodiceFiscale + '_' + @DataInvio 
		
	end
	
	if @TipoDoc in ('DETAIL_CHIARIMENTI_BANDO_RISPOSTA')
	begin
		--RISPOSTE AI QUESITI
		set @NomeFile = @ProtocolloGara + '_' + 'RIS_QUES' + '_' + @Protocollo + '_' + @DataInvio 
		

	end

	---------------------------------------------------------------------------------------
	--if @TipoDoc in ('RICHIESTA_COMPILAZIONE_DGUE','RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA')
	--begin
		
	--	--recupero ragione sociale del fornitore 
	--	select top 1 @CodiceFiscale = vatValore_FT 
	--		from ctl_doc c with (nolock)
	--			inner join ProfiliUtente p  with (nolock) on p.idpfu = c.IdPfu
	--			--inner join aziende with (nolock) on idazi = pfuidazi 
	--			inner join dm_attributi with (nolock) on lnk = pfuidazi and dztNome = 'codicefiscale'
	--		where id = @IdDocumento 
		
	--	if @TipoDoc = 'RICHIESTA_COMPILAZIONE_DGUE'
	--		set @NomeFile = @NomeFile + '_'  + @Protocollo + '_' + 'RIC_COMP_DGUE' + '_' + @CodiceFiscale + '_' + @DataInvio 
		
	--	if @TipoDoc = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA'
	--		set @NomeFile = @NomeFile + '_'  + @Protocollo + '_' + 'RIS_RIC_COMP_DGUE' + '_' + @CodiceFiscale + '_' + @DataInvio 

		
	--end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('RIAMMISSIONE_OFFERTA')
	begin
		set @NomeFile = @ProtocolloGara + '_' + 'RIAM_OFF' + '_' + @Protocollo + '_' + @DataInvio 
		
	end

	---------------------------------------------------------------------------------------
	if @TipoDoc in ('RITIRA_OFFERTA')
	begin
		
		--recupero codice fiscale del fornitore 
		select top 1 @CodiceFiscale = vatValore_FT 
			from ctl_doc c with (nolock)
				inner join ProfiliUtente p  with (nolock) on p.idpfu = c.IdPfu
				--inner join aziende with (nolock) on idazi = pfuidazi 
				inner join dm_attributi with (nolock) on lnk = pfuidazi and dztNome = 'codicefiscale' and idApp=1
			where id = @IdDocumento 

		set @NomeFile = @ProtocolloGara + '_'  + @Protocollo + '_' + 'RITIRA_OFF' + '_' + @CodiceFiscale + '_' + @DataInvio 


	end

	
	set @NomeFile = @NomeFile + '_' + @ExtAllegato

	--per i documenti esterni lasco come nome quello orignale
	if @TipoDoc = 'FASCICOLO_DOCUMENTI_AGGIUNTIVI'
	begin
		set @NomeFile = @ExtAllegato
	end

	--se cifrato aggiungo il suffisso .crypt
	if @Encrypted = '1'
		set @NomeFile = @NomeFile + '.crypt'
		
	update Document_Fascicolo_Gara_Allegati set  NomeFile = @NomeFile   where idrow = @IdRow
	

		

END -- Fine stored









GO
