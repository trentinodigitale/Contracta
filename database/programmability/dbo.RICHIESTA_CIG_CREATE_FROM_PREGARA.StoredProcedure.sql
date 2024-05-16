USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_PREGARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_PREGARA] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Bando as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int
	declare @TipoAppaltoGara as varchar(50)

	declare @versioneSimog varchar(100)
	declare @docVersione varchar(100)
	declare @statoFunzDoc varchar(100)
	declare @Tipo_Rup as varchar(100)

	set @Errore=''	
	set @versioneSimog = '3.4.2' 

	select top 1 @versioneSimog = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'

	---CERCO UNA RICHIESTA CIG NON ANNULLATA
	select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale <> 'Annullato' --and isnull( JumpCheck , '' ) = ''

	if @newId is null
	begin

		set @Bando = @idDoc

		-- prima di creare il documento verifico i requisiti necessari:
			--1) Trovare prodotti senza errori
			--2) Sia stato selezionato luogo istat e cpv
			--3) Sia stato inserito l'oggetto
			--4) Sia presente il RUP in base a parametro Tupo_rup
			
		--è superfluo ma non impatta
		IF EXISTS ( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato' )
		BEGIN
			set @Errore = 'Impossibile effettuare una richiesta CIG con una RICHIESTA SMART CIG in corso'
		END

		-- verifica luogo istat non selezionato
		if @Errore = ''
		begin
			select @COD_LUOGO_ISTAT = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 
			if isnull( @COD_LUOGO_ISTAT , '' ) = '' 
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il Luogo ISTAT nella scheda "Dati Per Simog"'
		end

		-- verifica CPV non selezionata
		if @Errore = ''
		begin
			select @CODICE_CPV = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 
			if isnull( @CODICE_CPV , '' ) = '' 
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il Codice identificativo corrispondente al sistema di codifica CPV nella scheda "Dati Per Simog"'
		end

		-- verifica Oggetto
		if @Errore = ''
		begin

			select @Body = body from CTL_DOC with(nolock) where id = @Bando

			if isnull( @Body , '' ) = '' 
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver inserito l''oggetto della gara'

		end

		-- verifica rup non selezionato
		if @Errore = ''
		begin
			
			select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

			if @Tipo_Rup='UserRUP'
				select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'CRITERI_ECO' and dzt_name = @Tipo_Rup 
			else
				select @Rup = RupProponente from document_bando  with(nolock) where idheader = @Bando 

			if isnull( @Rup , '' ) = '' 
			begin
				if @Tipo_Rup='UserRUP'	
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'
				else
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente'
			end
		end

		if @Errore = ''
		begin

			if exists ( select idrow from Document_Bando with(nolock) where idHeader = @Bando and isnull(importoBaseAsta,0) = 0 )
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato l''Importo Appalto'
		end
		

		-- se non sono presenti errori
		if @Errore = ''
		begin


			-- CREO IL DOCUMENTO
			INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, Versione )
				select  @IdUser,'RICHIESTA_CIG' , @IdUser ,Azienda,body,@idDoc, @versioneSimog 
					from ctl_doc with(nolock)
					where id=@idDoc		

			set @newId = SCOPE_IDENTITY()

			if @versioneSimog < '3.4.6'
			begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
					
			end

			--se la versione è 3.4.6 oppure 3.4.7 metto altri modelli
			if @versioneSimog in ( '3.4.6' , '3.4.7')
			begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_6_7' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_6_7' )
					
			end


			-- recupero il codice fiscale dell'ente
			select @CF_AMMINISTRAZIONE = vatValore_FT 
				from ctl_doc with(nolock) 
					inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
				where id = @Bando
			
			select 
				@TipoAppaltoGara= 
					case 
						when TipoAppaltoGara = '1' then 'F'
						when TipoAppaltoGara = '2' then 'L'
						when TipoAppaltoGara = '3' then 'S'
						else ''
					end				
				from Document_Bando DB with(nolock) where idHeader=@Bando

			-- recupero il CF del RUP
			-- o quello del campo dirigente?
			select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 

			select @NumLotti = count(*) from ctl_doc b with(nolock) inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and isnull(d.voce,0) = 0 where b.id = @Bando

			if isnull( @NumLotti, 0 ) = 0 
				set @NumLotti = 1

			-- inserisco i dati base della gara
			insert into Document_SIMOG_GARA
				(	[idHeader], [indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], [DENOM_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [TIPO_SCHEDA], [MODO_REALIZZAZIONE], [NUMERO_LOTTI], [ESCLUSO_AVCPASS], [URGENZA_DL133], [CATEGORIE_MERC], [ID_SCELTA_CONTRAENTE], [StatoRichiestaGARA], [EsitoControlli], [id_gara], [idpfuRup], STRUMENTO_SVOLGIMENTO )
				select 
						@newId				as [idHeader], 
						null				as [indexCollaborazione], 
						''					as [ID_STAZIONE_APPALTANTE], 
						''					as [DENOM_STAZIONE_APPALTANTE], 
						@CF_AMMINISTRAZIONE as [CF_AMMINISTRAZIONE], 
						''					as [DENOM_AMMINISTRAZIONE], 
						@CF_UTENTE			as [CF_UTENTE], 
						--importoBaseAsta2	as [IMPORTO_GARA], 
						importoBaseAsta		as [IMPORTO_GARA], -- comprensivo di oneri e opzioni
						''					as [TIPO_SCHEDA], 
						''					as [MODO_REALIZZAZIONE], 
						@NumLotti			as [NUMERO_LOTTI], 
						''					as [ESCLUSO_AVCPASS], 
						''					as [URGENZA_DL133], 
						''					as [CATEGORIE_MERC], 
						--case when a.TipoDoc = 'BANDO_SEMPLIFICATO' then '6' else '' end as [ID_SCELTA_CONTRAENTE], 
						'' as [ID_SCELTA_CONTRAENTE], -- mod. per versione simog 3.04.5
						''					as [StatoRichiestaGARA], 
						''					as [EsitoControlli], 
						''					as [id_gara], 
						@Rup				as [idpfuRup],
						case when a.TipoDoc = 'BANDO_SEMPLIFICATO' then '7' else '' end as STRUMENTO_SVOLGIMENTO --Sistema dinamico di acquisizione

					from ctl_doc a with(nolock)
							inner join document_bando b with(nolock)  on b.idHeader = a.id
					where a.id = @Bando

			select * into #tmp_dati_simog from ctl_doc_value with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_SIMOG'

			-- inserisco i dati dei lotti
			insert into Document_SIMOG_LOTTI
				( [idHeader], [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], [CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], [EsitoControlli], [StatoRichiestaLOTTO], [CIG], IMPORTO_OPZIONI,
					FLAG_PNRR_PNC, ID_MOTIVO_DEROGA,FLAG_MISURE_PREMIALI,ID_MISURA_PREMIALE,FLAG_PREVISIONE_QUOTA,QUOTA_FEMMINILE,QUOTA_GIOVANILE,MODALITA_ACQUISIZIONE)
				select 
						@newId							as [idHeader], 
						NumeroLotto, 
						Descrizione						as [OGGETTO], 
						'N'								as [SOMMA_URGENZA], 
						--d.ValoreImportoLotto			as [IMPORTO_LOTTO],
						d.importoBaseAsta  + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) as [IMPORTO_LOTTO],
						0								as [IMPORTO_SA], 
						0								as [IMPORTO_IMPRESA], 
						@CODICE_CPV						as [CPV], 
						--case when b.TipoDoc = 'BANDO_SEMPLIFICATO' then '6' else '' end as [ID_SCELTA_CONTRAENTE],
						'' as [ID_SCELTA_CONTRAENTE],
						''								as [ID_CATEGORIA_PREVALENTE], 
						@TipoAppaltoGara				as [TIPO_CONTRATTO], 
						'N'								as [FLAG_ESCLUSO], 
						@COD_LUOGO_ISTAT				as [LUOGO_ISTAT], 
						--0								as [IMPORTO_ATTUAZIONE_SICUREZZA], 
						d.IMPORTO_ATTUAZIONE_SICUREZZA,
						'N'								as [FLAG_PREVEDE_RIP], 
						'N'								as [FLAG_RIPETIZIONE], 
						'N'								as [FLAG_CUP], 
						''								as [CATEGORIA_SIMOG], 
						''								as [EsitoControlli], 
						''								as [StatoRichiestaLOTTO], 
						''								as [CIG],
						d.IMPORTO_OPZIONI
						
						,case when s1.Value = '1' then 'S' else 'N' end as FLAG_PNRR_PNC
						, s5.Value as ID_MOTIVO_DEROGA
						, s2.Value as FLAG_MISURE_PREMIALI
						, s4.value as ID_MISURA_PREMIALE
						, s3.value as FLAG_PREVISIONE_QUOTA
						, s6.value as QUOTA_FEMMINILE
						, s7.value as QUOTA_GIOVANILE
						,'1' as MODALITA_ACQUISIZIONE

					from ctl_doc b with(nolock) 
						inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and isnull(d.voce,0) = 0 
						left join #tmp_dati_simog s1 on s1.DZT_Name = 'Appalto_PNRR_PNC'
						left join #tmp_dati_simog s2 on s2.DZT_Name = 'FLAG_MISURE_PREMIALI'
						left join #tmp_dati_simog s3 on s3.DZT_Name = 'FLAG_PREVISIONE_QUOTA'
						left join #tmp_dati_simog s4 on s4.DZT_Name = 'ID_MISURA_PREMIALE'
						left join #tmp_dati_simog s5 on s5.DZT_Name = 'ID_MOTIVO_DEROGA'
						left join #tmp_dati_simog s6 on s6.DZT_Name = 'QUOTA_FEMMINILE'
						left join #tmp_dati_simog s7 on s7.DZT_Name = 'QUOTA_GIOVANILE'
					where b.id = @Bando
					order by d.id


		
		
		end

	end
	else
	begin
		

		select @docVersione = versione, @statoFunzDoc = statoFunzionale from ctl_doc with(nolock) where id = @newid

		-- se il documento è ancora in lavorazione e rispetto alla sua creazione, la versione simog è avanzata, la rettifichiamo
		if @statoFunzDoc = 'InLavorazione' and @docVersione <> @versioneSimog
		begin
			
			update ctl_doc
					set versione = @versioneSimog
				where id = @newid

			set @docVersione = @versioneSimog

			-- cancelliamo il modello per la versione "vecchia" così da lasciare il default
			delete from CTL_DOC_SECTION_MODEL where idheader = @newid and DSE_ID IN ( 'GARA', 'LOTTI' )

		end
			
		if @statoFunzDoc = 'InLavorazione' and @docVersione < '3.4.6' and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @newid and DSE_ID in ( 'GARA', 'LOTTI' ) )
		begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
				
		end

	end

	if dbo.PARAMETRI('RICHIESTA_CIG_GARA_DELEGA','GestioneCiGconDelega','HIDE','0',-1) = '0'
	begin
		if ISNULL(@newId,0) <> 0
		begin
			--forse con un controllo di attivazione
			declare @EnteProponente int 
			declare @enteAppaltante int
			declare @cfEnteProponente varchar(500)
			declare @denominazioneEnteProponente varchar(500)

			select	
				@EnteProponente = Replace(g.EnteProponente, '#\0000\0000', ''), 
				@enteAppaltante = g.Azienda, 
				@denominazioneEnteProponente = a.aziRagioneSociale,
				@cfEnteProponente = dma.vatValore_FT
			FROM PREGARA_TESTATA_VIEW g with(nolock)
				inner join Aziende as a with(nolock) on a.IdAzi = Replace(EnteProponente, '#\0000\0000', '')
				inner join DM_Attributi dma with(nolock) on dma.lnk = Replace(EnteProponente, '#\0000\0000', '') and dztNome = 'codicefiscale' and idApp = 1
			where g.Id = @idDoc 
	
			if (@EnteProponente <> @enteAppaltante)
				begin 

					if (@cfEnteProponente <> '' and @cfEnteProponente is not null)
						begin 
							if exists (select idrow from CTL_DOC_Value where DSE_ID = 'GARADELEGA' and DZT_Name = 'CodiceFiscaleSoggettoSA' and IdHeader = @newid)
								begin
									update CTL_DOC_Value set Value = @cfEnteProponente where DSE_ID = 'GARADELEGA' and DZT_Name = 'CodiceFiscaleSoggettoSA' and IdHeader = @newid
								end 
							else
								begin
									INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
										VALUES ( @newid, 'GARADELEGA', 'CodiceFiscaleSoggettoSA',  @cfEnteProponente)
								end
						end 

					if (@denominazioneEnteProponente <> '' and @denominazioneEnteProponente is not null)
						begin 
							if exists (select idrow from CTL_DOC_Value where DSE_ID = 'GARADELEGA' and DZT_Name = 'DenominazioneAmministrazioneSA' and IdHeader = @newid)
								begin
									update CTL_DOC_Value set Value = @denominazioneEnteProponente where DSE_ID = 'GARADELEGA' and DZT_Name = 'DenominazioneAmministrazioneSA' and IdHeader = @newid
								end 
							else
								begin
									INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
										VALUES ( @newid, 'GARADELEGA', 'DenominazioneAmministrazioneSA',  @denominazioneEnteProponente)
								end
						end 

					if exists (select idrow from CTL_DOC_Value where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = 'si' where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'StazioneAppaltanteSoggettoSingolo',  'si')
						end
					end 

			else
				begin 
					if exists (select idrow from CTL_DOC_Value where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid)
						begin
							update CTL_DOC_Value set Value = 'no' where DSE_ID = 'GARADELEGA' and DZT_Name = 'StazioneAppaltanteSoggettoSingolo' and IdHeader = @newid
						end 
					else
						begin
							INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, Value)
								VALUES ( @newid, 'GARADELEGA', 'StazioneAppaltanteSoggettoSingolo',  'no')
						end
				end	
		end
	end

	if  ISNULL(@newId,0) <> 0
	begin

		-- rirorna l'id del doc da aprire
		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
