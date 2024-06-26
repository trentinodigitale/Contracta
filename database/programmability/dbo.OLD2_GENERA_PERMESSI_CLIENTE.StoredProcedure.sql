USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GENERA_PERMESSI_CLIENTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dbo].[OLD2_GENERA_PERMESSI_CLIENTE] ( @SYS_GRUPPI nvarchar(max) ,@SYS_PERMESSI_ATTIVI nvarchar(max) , @permessi_totali nvarchar(max) output )
AS
BEGIN

	SET NOCOUNT ON 

	DECLARE @contatore INT
	DECLARE @totPermessi INT
	DECLARE @permBase nvarchar(1)
	DECLARE @GRUPPO nvarchar(max)

	SET @GRUPPO = ''
	SET @permessi_totali = ''
	SET @totPermessi = 1000
	SET @permBase = '0'


	IF EXISTS ( select * from LIB_Dictionary with(nolock) where DZT_Name='SYS_ANAGRAFICA_MASTER' and DZT_ValueDef='YES' )
	BEGIN
		set @SYS_GRUPPI= @SYS_GRUPPI + ',GROUP_SYS_ANAGRAFICA_MASTER'
	END

	--SE ESISTE AGGIORNO LA SYS_MODULI_GRUPPI altrimenti la creo con i moduli attivi sul cliente
	IF EXISTS ( select dzt_name from LIB_Dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' )
	BEGIN
		update LIB_Dictionary set DZT_ValueDef=',' + @SYS_GRUPPI + ',' where DZT_Name='SYS_MODULI_GRUPPI'
	END
	ELSE
	BEGIN
		insert into LIB_Dictionary 
			( [DZT_Name],[DZT_Type],[DZT_DM_ID],[DZT_DM_ID_Um],[DZT_MultiValue],[DZT_Len],[DZT_Dec],[DZT_DescML],[DZT_Format],[DZT_Sys],[DZT_ValueDef],[DZT_Module],[DZT_Help],[DZT_RegExp]) 
			VALUES 
			(N'SYS_MODULI_GRUPPI',1,N'',0,null,1000,0,N'',N'',0,',' + @SYS_GRUPPI + ',',N'Systema',N'SYS il cui valore viene generato dinamicamente con i moduli attivi sul cliente, valorizzata quando si avvia applicazione',N'')
	END


	-----------------------------------------
	-- CICLO DI INIZIALIZZAZIONE PERMESSI ---
	-----------------------------------------

	declare @attiva_test int
	set @attiva_test = 0

	-- Per velocizzare le query inserisco il risultato della vista in una tabella temporanea
	--SELECT * into #tempPermessi from DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI
	SELECT * into #tempPermessi from DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI_ASP
	
	
	IF @attiva_test = 1
	BEGIN

		-------------------------------------------------------------------------------------------------
		-- SE LA VARIABILE TEST E' A 1 GENERO DINAMICAMENTE LE SYS @SYS_GRUPPI e @SYS_PERMESSI_ATTIVI ---
		-------------------------------------------------------------------------------------------------

		select @SYS_GRUPPI = @SYS_GRUPPI + lfn_target + ',' from #tempPermessi 
		SET @SYS_GRUPPI = SUBSTRING( @SYS_GRUPPI, 1, len(@SYS_GRUPPI)-1)

		-- creo una stringa di mille 1
		SET @contatore = 1
		WHILE ( @contatore <= @totPermessi )
		BEGIN
			SET @SYS_PERMESSI_ATTIVI = @SYS_PERMESSI_ATTIVI + '1'
			SET @contatore = @contatore + 1
		END

		print @SYS_GRUPPI

	END

	-- Se la sys gruppi non è presente rendo la stringa permessi_totali, nulla da un punto di vista di 'disabilitazioni' delle funzionalità
	IF @SYS_GRUPPI = ''
	BEGIN
		SET @permBase = '1'
	END
	ELSE
	BEGIN
		SET @permBase = '0'
	END

	SET @contatore = 1
	WHILE ( @contatore <= @totPermessi )
	BEGIN

		SET @permessi_totali = @permessi_totali + @permBase
		SET @contatore = @contatore + 1

	END

	----------------------------------------------------------------------------------------------------------
	-- ITERO SUI GRUPPI ATTIVI DEL CLIENTE PER POI GENERARMI LA STRINGA DI FUNZIONE PER OGNI GRUPPO ATTIVO ---
	----------------------------------------------------------------------------------------------------------

	DECLARE gruppi CURSOR STATIC FOR SELECT items as gruppo from dbo.split(@SYS_GRUPPI, ',') where isnull(items ,'') <> ''

	OPEN gruppi 
	FETCH NEXT FROM gruppi INTO @GRUPPO

	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		-- ITERO SUI GRUPPI ATTIVI SUL CLIENTE

		DECLARE permessi CURSOR STATIC FOR SELECT LFN_PosPermission from #tempPermessi where lfn_target = @GRUPPO and isnumeric(LFN_PosPermission) = 1
		DECLARE @PERMESSO INT

		OPEN permessi 
		FETCH NEXT FROM permessi INTO @PERMESSO

		WHILE @@FETCH_STATUS = 0   
		BEGIN  

			-- se il permesso è in un range valido
			IF @PERMESSO > 0 and @PERMESSO <= @totPermessi  
			BEGIN

				-- ITERO SULLE FUNZIONI DEL GRUPPO SU CUI MI TROVO DAL CICLO SUPERIORE E SETTO SULLA STRINGA COMPLESSIVA DEI PERMESSI UN 1 PER LA POSIZIONE SU CUI STO ITERANDO
				set @permessi_totali = stuff(@permessi_totali, @PERMESSO, 1, '1')

			END

			FETCH NEXT FROM permessi INTO @PERMESSO

		END  

		CLOSE permessi   
		DEALLOCATE permessi

		FETCH NEXT FROM gruppi INTO @GRUPPO

	END  

	CLOSE gruppi   
	DEALLOCATE gruppi


	--Gestione dei permessi Cross ( Configurazione di Sistema ) attraverso una relazione. (Antonio Casolaro 04/06/2018)

	DECLARE @REL_ValueInput as varchar(250)
	DECLARE @REL_ValueOutput as varchar(250)
	DECLARE @Valore as char(1)
	
	DECLARE relazioni CURSOR STATIC FOR 
	
		SELECT [REL_ValueInput], [REL_ValueOutput] FROM [CTL_Relations] with(nolock) where [REL_Type]='PERMESSI_CROSS'
	
	--Ciclo per cancellare tutti i permessi cross
	OPEN relazioni 
	FETCH NEXT FROM relazioni INTO @REL_ValueInput, @REL_ValueOutput


	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		set @PERMESSO = cast(@REL_ValueOutput as int)
		print @PERMESSO
		set @Valore = '0'

		set @permessi_totali = stuff(@permessi_totali, @PERMESSO, 1, @Valore)

		FETCH NEXT FROM relazioni INTO @REL_ValueInput, @REL_ValueOutput
	END  

	CLOSE relazioni   

	--Ciclo per aggiornare le posizioni dei permessi cross
	OPEN relazioni 
	FETCH NEXT FROM relazioni INTO @REL_ValueInput, @REL_ValueOutput


	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		set @PERMESSO = cast(@REL_ValueOutput as int)

		if(exists(SELECT items as gruppo from dbo.split(@SYS_GRUPPI, ',') where isnull(items ,'') <> '' and items=@REL_ValueInput))
		begin
			--UN PERMESSO CROSS SE E' PRESENTE IN  PERMESSI_CROSS_MODULI devono essere abilitati i moduli indicati in REL_ValueOutput
			--IF not exists (
			--			select REL_ValueOutput 
			--				from CTL_Relations with(nolock) 
			--					left join ( SELECT items as gruppo from dbo.split(@SYS_GRUPPI, ',') ) as G  on G.gruppo=REL_ValueOutput 
			--					where REL_Type='PERMESSI_CROSS_MODULI' and REL_ValueInput=@PERMESSO
			--						and G.gruppo is null
			--			 ) 
				
			--BEGIN
				set @Valore = '1'
				set @permessi_totali = stuff(@permessi_totali, @PERMESSO, 1, @Valore)
			--END
		end


		FETCH NEXT FROM relazioni INTO @REL_ValueInput, @REL_ValueOutput
	END  

	CLOSE relazioni   
	DEALLOCATE relazioni

	set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali, @SYS_PERMESSI_ATTIVI )




	
	------------------------------------------------------------------------------------------------
	-- DOPO AVER CALCOLATO I PERMESSI TOTALI AGGIUNGO LE LOGICHE RELATIVE AI DOCUMENTI PARAMETRI ---
	------------------------------------------------------------------------------------------------
	IF EXISTS ( select a.id
					from ctl_doc a with(nolock)
						inner join ctl_doc_value b with(nolock) on b.IdHeader = a.id and b.DSE_ID = 'SISTEMA' and b.DZT_Name = 'AttivaRichiestaQuote' and isnull(b.Value,'') = 'si'
					where a.tipodoc = 'PARAMETRI_CONVENZIONE' and a.deleted = 0 and a.StatoFunzionale = 'Confermato'
				)
	BEGIN

		--- AGGIUNTA DEL PERMESSO GESTORE QUOTE LATO ENTE NON MASTER
		set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali,  stuff(@permessi_totali ,132, 1, '1') )

		--- AGGIUNTA DEL PERMESSO GESTORE QUOTE MASTER
		set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali,  stuff(@permessi_totali ,133, 1, '1') )

	END
	ELSE
	BEGIN

		set @permessi_totali = @permessi_totali

		--- TOLGO IL PERMESSO GESTORE QUOTE LATO ENTE NON MASTER
		set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali,  stuff(@permessi_totali ,132, 1, '0') )

		--- TOLGO IL PERMESSO GESTORE QUOTE MASTER
		set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali,  stuff(@permessi_totali ,133, 1, '0') )

	END

	--AGGIUNGO LA LOGICA PER SETTARE IL BIT 160, a zero se non è presente il db prev version
	IF EXISTS ( select dzt_name from lib_dictionary  with(nolock) where dzt_name = 'SYS_DBNAME_PREV_VER' and ISNULL(dzt_valuedef,'')='' )
	BEGIN
		set @permessi_totali = dbo.AND_FUNZIONALITA(@permessi_totali,  stuff(@permessi_totali ,160, 1, '0') )
	END

	
	

		
		
		

	

	--metto in una tabella temporanea i permessi legati ai moduli cross
	select * into #temp_Cross_Moduli from CTL_Relations with (nolock) where REL_Type='PERMESSI_CROSS_MODULI' 

	--RETTIFICHIAMO LA STRINGA DEI PERMESSI PER VERIFICARE SE UN PERMESSO 
	--PER ESSERE ATTIVO DEVE STARE SU PIU' MODULI INDICATI DA UNA RELAZIONE "PERMESSI_CROSS_MODULI"
	--METTO IL CURSORE IN QUANTO CON SEMPLICE UPDATE AGGIORNAVA SOLO UNA VOLTA DZT_VALUEDEF
	--update
	--	L
	--	set DZT_ValueDef= STUFF ( DZT_ValueDef , cast(REL_ValueInput as int), 1 , '0')
	--	from 
	--		LIB_DICTIONARY L
	--			inner join #temp_Cross_Moduli with (nolock) on 
	--									REL_Type='PERMESSI_CROSS_MODULI' 
	--									--se il permesso è attivo
	--									and SUBSTRING(@permessi_totali,cast(REL_ValueInput as int),1)='1' 
	--									--se il modulo non è presente tra quelli attivi abbassiamo il permesso
	--									and CHARINDEX(',' + rel_valueoutput + ',', ',' + @SYS_GRUPPI + ',') =0 
	--	where  
	--		DZT_Name = 'SYS_MODULI_RESULT'
	declare @permesso_c int
	declare CurProg Cursor Static for 
		select  cast(REL_ValueInput as int) from #temp_Cross_Moduli
	
	open CurProg 
	FETCH NEXT FROM CurProg INTO @permesso_c
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--update	L set DZT_ValueDef= STUFF ( DZT_ValueDef , cast(REL_ValueInput as int), 1 , '0')
		--	from LIB_DICTIONARY L
		--		inner join #temp_Cross_Moduli with (nolock) on 
		--							REL_Type='PERMESSI_CROSS_MODULI' 
		--							--se il permesso è attivo
		--							and SUBSTRING(@permessi_totali,cast(REL_ValueInput as int),1)='1' 
		--							--se il modulo non è presente tra quelli attivi abbassiamo il permesso
		--							and CHARINDEX(',' + rel_valueoutput + ',', ',' + @SYS_GRUPPI + ',') =0 
		--							and cast(REL_ValueInput as int)=@permesso_c
		--	where  
		--		DZT_Name = 'SYS_MODULI_RESULT'

			select 
				@permessi_totali = STUFF ( @permessi_totali , cast(REL_ValueInput as int), 1 , '0')
				from 
					#temp_Cross_Moduli with (nolock) 
				where
					--se il permesso è attivo
					SUBSTRING(@permessi_totali,cast(REL_ValueInput as int),1)='1' 
					--se il modulo non è presente tra quelli attivi abbassiamo il permesso
					and CHARINDEX(',' + rel_valueoutput + ',', ',' + @SYS_GRUPPI + ',') =0 
					--per ogni permesso ritornato dal cursore
					and cast(REL_ValueInput as int) = @permesso_c
			

		FETCH NEXT FROM CurProg INTO @permesso_c
	END
	CLOSE CurProg
	DEALLOCATE CurProg


	--aggiorno sul dizionario perchè ho finito
	UPDATE 
		LIB_DICTIONARY
			set DZT_ValueDef  = @permessi_totali
		WHERE 
			DZT_Name = 'SYS_MODULI_RESULT'


	------------------------------------------------------------------------------------------------------------------------
	-- TRAVASO LA TABELLA TEMPORANEA NELLA TABELLA DI APPOGGIO SULLA QUALE SI CONFIGURA IL DOCUMENTO DI CREAZIONE PROFILI --
	------------------------------------------------------------------------------------------------------------------------
	truncate table Document_Elenco_Funzioni_Permessi

	insert into Document_Elenco_Funzioni_Permessi ( LFN_GroupFunction, Title, LFN_PosPermission, Path, LFN_Target, Attivo )
			select LFN_GroupFunction, Title, LFN_PosPermission, Path, LFN_Target, Attivo 
			from #tempPermessi



	


	---------------------------------------------------------------------------------------
	--- GESTIONE ATTIVAZIONE/DISATTIVAZIONE DINAMICA DEI PROFILI --------------------------
	---------------------------------------------------------------------------------------

	DECLARE @idProfilo INT
	DECLARE @permessiProfilo varchar(4000)
	DECLARE @sysDeleted int

	DECLARE profili CURSOR STATIC FOR select id, Funzionalita, sysDeleted from profili_funzionalita with(nolock) where deleted = sysdeleted and mp in (select mplog  from marketplace)

	OPEN profili 
	FETCH NEXT FROM profili INTO @idProfilo, @permessiProfilo, @sysDeleted

	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		-- SE IL PROFILO HA ALMENO UN BIT AD 1 FACCIO I CONTROLLI. ALTRIMENTI E' UN PROFILO 'FITTIZIO' COME IL PROFILO BASE PER GLI ENTI, E NON LO CONSIDERO
		IF CHARINDEX('1' , @permessiProfilo) > 0
		BEGIN

			-- FACCIO L'AND LOGICO TRA LA STRINFA DI PERMESSI TOTALI E LA STRINGA DI PERMESSI DEL PROFILO
			-- SE DAL RISULTATO MI RITROVO ALMENO UN '1' NON DISATTIVO IL PROFILO
			set @permessiProfilo = dbo.AND_FUNZIONALITA(@permessi_totali, @permessiProfilo )

			IF CHARINDEX('1' , @permessiProfilo) > 0
			BEGIN
			
				-- Riattivo solo quelli cancellati logicamente tramite sistema, e non quelli cancellati logicamente dagli utenti tramite la funzionalità
				IF @sysDeleted = 1
				BEGIN

					UPDATE profili_funzionalita
						SET sysDeleted = 0, deleted = 0
					WHERE ID = @idProfilo

				END

			END
			ELSE
			BEGIN

				UPDATE profili_funzionalita
					SET sysDeleted = 1, deleted = 1
				WHERE ID = @idProfilo
			
			END

		END

		FETCH NEXT FROM profili INTO @idProfilo, @permessiProfilo, @sysDeleted

	END  

	CLOSE profili   
	DEALLOCATE profili

	--Gestione dei profili collegati ad un modulo attraverso una relazione. kpf 412230		
	DECLARE profilo_modulo 	CURSOR STATIC FOR 
		SELECT [REL_ValueInput], [REL_ValueOutput] 
			FROM [CTL_Relations] with(nolock) where [REL_Type]='profilo_modulo'
	
	--Ciclo per mettere a deleted i profili della relazione collegati a moduli non attivi
	OPEN profilo_modulo 
	FETCH NEXT FROM profilo_modulo INTO @REL_ValueInput, @REL_ValueOutput
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
	if NOT EXISTS (SELECT items as gruppo from dbo.split(@SYS_GRUPPI, ',') where isnull(items ,'') <> '' and items=@REL_ValueInput)
	BEGIN		
		UPDATE profili_funzionalita
			SET sysDeleted = 1, deleted = 1
		WHERE CODICE = @REL_ValueOutput
	END	
		
	FETCH NEXT FROM profilo_modulo INTO @REL_ValueInput, @REL_ValueOutput
	END  

	CLOSE profilo_modulo  
	DEALLOCATE profilo_modulo 
	---------------------------------------------------------------------------------------
	---FINE GESTIONE ATTIVAZIONE/DISATTIVAZIONE DINAMICA DEI PROFILI ----------------------
	---------------------------------------------------------------------------------------
END





GO
