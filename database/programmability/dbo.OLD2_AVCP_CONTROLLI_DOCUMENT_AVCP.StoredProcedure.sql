USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_CONTROLLI_DOCUMENT_AVCP]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD2_AVCP_CONTROLLI_DOCUMENT_AVCP] ( @idDoc int )
AS
BEGIN
	
	declare @descrizione as nvarchar(4000)
	declare @idlotto as INT
	declare @tipodoc as varchar(50)
	declare @cig as varchar(50)
	declare @versionelotto as varchar (50)

	-- set @idlotto = -1

	--recupero il tipodoc associato all'ID passato
	select @tipodoc=tipodoc from ctl_doc with(nolock) where id=@idDoc

	--se non sono stata chiamata da una gara recupero ID della gara
	IF @tipodoc <> 'AVCP_LOTTO' and @tipodoc <> 'AVCP_GARA'
	BEGIN
		
		--Select @idlotto=LinkedDoc from CTL_DOC with(nolock) where id=@idDoc

		-- risalgo al documento dalla versione
		select @IdLotto = L.id 
			from CTL_DOC L with(nolock) 
				inner join CTL_DOC O with(nolock) on L.versione = o.Linkeddoc and L.tipoDoc = 'AVCP_LOTTO' and L.deleted = 0 and L.Statofunzionale = 'Pubblicato'
			where O.id = @idDoc

	END

	IF @tipodoc = 'AVCP_LOTTO'
	BEGIN
		set @idlotto=@idDoc
	END

	--se è una gara a lotti copio tutti i warning dei lotti sulla gara
	IF @tipodoc = 'AVCP_GARA'
	BEGIN

			update document_AVCP_lotti 
					set Warning='' 
				where idHeader=@idDoc
	
			declare @IDHeader INT

			declare CurProg Cursor FAST_FORWARD for 
				select idHeader 
					from CTL_DOC b with(nolock)
							inner join CTL_DOC a with(nolock) ON a.LinkedDoc = b.versione and b.Deleted = 0 and a.Deleted = 0 and a.StatoFunzionale = 'Pubblicato'
							inner join document_AVCP_lotti with(nolock) on idheader=a.id 
					where b.id = @idDoc --gara
					order by a.id

			open CurProg

			declare @warning varchar(8000)
			set @warning = ''

			FETCH NEXT FROM CurProg 
			INTO @idHeader
			WHILE @@FETCH_STATUS = 0
			BEGIN

				select @warning = @warning + ISNULL(cast( Warning as nvarchar(4000)),'') + '</br>' 
			    			from document_AVCP_lotti with(nolock)
							where idheader=@idHeader

				FETCH NEXT FROM CurProg 
				INTO @idHeader

			END 

			-- Se il warning contiene solo </br>, lo setto a vuoto
			IF RTRIM(LTRIM(REPLACE(isnull(@warning,''),'</br>',''))) = '' 
			BEGIN
				SET @warning = ''
			END

			update document_AVCP_lotti 
				set Warning=@warning
			where idHeader=@idDoc
			

			CLOSE CurProg
			DEALLOCATE CurProg		

		END

	ELSE
	BEGIN

			select @versionelotto=versione 
				from ctl_doc with(nolock)
				where id=@idlotto

			--RIPULISCO IL CAMPO WARNING PRIMA DI FARE I CONTROLLI
			update document_AVCP_lotti 
					set Warning='' 
				where idHeader=@idlotto

	
			-- CONTROLLO IL CAMPO OGGETTO SULLA GARA MENO 250 CARATTERI
			select @descrizione=Oggetto 
				from document_AVCP_lotti with(nolock)
				where idheader=@idlotto

			If len(@descrizione) > 250
			begin
				update document_AVCP_lotti 
					set Warning=ISNULL(cast( Warning as nvarchar(4000)),'') + 'Il Campo Oggetto non deve superare i 250 caratteri.' + '</br>'
				where idHeader=@idlotto
			end

			-- VERIFICO SE FARE IL CONTROLLO SUGLI AGGIUDICATARI MULTIPLI
			-- ( aggiunto per evitare la customizzazione per empulia che non voleva il controllo sugli aggiudicatari per colpa degli accordi quadro gestiti 'male' )
			IF NOT EXISTS ( select * from CTL_Relations with(nolock) where REL_Type = 'AVCP_CONTROLLI_DOCUMENT_AVCP' and REL_ValueInput = 'aggiudicatari_multipli' and REL_ValueOutput = 'si' )
			BEGIN

				---Controllo che sia un solo aggiudicatario per la gara in oggetto
				IF EXISTS ( select count(distinct(idheader)) as nr from DASHBOARD_VIEW_AVCP_ELENCO_PARTECIPANTI 
							where LinkedDoc=@versionelotto and aggiudicatario=1
							having count( distinct(idheader) ) >1 )
				BEGIN
					update document_AVCP_lotti
							set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'Sono presenti più operatori economici come aggiudicatari.' + '</br>' 
					where idHeader=@idlotto
				END

			END

			----------------------------------------
			--- CONTROLLO VALIDITÀ CODICE FISCALE --
			----------------------------------------
			declare @RagSoc varchar(4000)
			declare @CodFisc varchar(4000)

			set @RagSoc = ''
			set @CodFisc = ''

			--select		@RagSoc = @RagSoc + ' , ' + aziragionesociale  ,
			--			@CodFisc = @CodFisc + ' , ' +  a.Codicefiscale 
			--		from DASHBOARD_VIEW_AVCP_ELENCO_PARTECIPANTI a 
			--	where LinkedDoc=@versionelotto 
			--			and OPEN_DOC_NAME <> 'AVCP_GRUPPO' 
			--			and dbo.fn_checkCF_ANAC(a.Codicefiscale, a.Estero) = 0
			--			and statofunzionale = 'Pubblicato'

			select		@RagSoc = @RagSoc + ' , ' + ragionesociale  ,
						@CodFisc = @CodFisc + ' , ' +  Codicefiscale 
				from ctl_doc O with(nolock) 
					inner join document_AVCP_partecipanti p with(nolock) on p.idheader = o.id
				where o.linkeddoc = @versionelotto
					and o.StatoFunzionale = 'pubblicato' 
					and o.TipoDoc in ( 'AVCP_OE' , 'AVCP_GRUPPO' ) 
					and o.deleted = 0 
					and dbo.fn_checkCF_ANAC(p.Codicefiscale, p.Estero) = 0

			if @RagSoc <> ''
			BEGIN

				set @RagSoc =	substring(@RagSoc,4,4000)
				set @CodFisc =	substring(@CodFisc,4,4000)

				update document_AVCP_lotti
						set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'Sono presenti operatori economici con codice fiscale errato.' + ' Codice Fiscale: ' + @CodFisc + ' Ragione Sociale: ' +  @RagSoc +  '</br>' 
				where idHeader=@idlotto


			END


			-------------------------------------
			--CONTROLLO SU NUMERO GARA AUTORITA -
			-------------------------------------
			select @cig=Cig 
				from document_AVCP_lotti with(nolock)
				where idheader=@idlotto

			if  dbo.controllo_cig_valido(@cig) <> 1 and left(@cig,4) <> 'INT-' and left(@cig,4) <> 'EXT-'
			BEGIN
				update document_AVCP_lotti 
					set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'CIG non valido.' + '</br>' 
					where idHeader=@idlotto
			END

			declare @numero as INT
			set @numero = 0

			---------------------------------------------------------------------------------------------
			--CONTROLLO CHE CI SIA UN AGGIUDICATARIO SE IMPORTOAGGIUDICAZIONE SUL LOTTO DIVERSO DA ZERO -
			---------------------------------------------------------------------------------------------
			IF EXISTS (Select * from document_AVCP_lotti with(nolock) where idheader=@idlotto and ImportoAggiudicazione > 0 )
			BEGIN


				Select @numero=count(*) 
					 from ctl_doc with(nolock)
							inner join document_AVCP_partecipanti  with(nolock) on idheader = id and aggiudicatario=1
					 where linkeddoc=@versionelotto and tipodoc in ('AVCP_GRUPPO','AVCP_OE') and StatoFunzionale = 'Pubblicato' and Deleted = 0

				--if @numero < 1
				--BEGIN
				--	update document_AVCP_lotti 
				--			set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'Nel lotto con un importo di aggiudicazione deve essere presente l''aggiudicatario.' + '</br>' 
				--		where idHeader=@idlotto
				--END

			END

			set @numero = 0

			-----------------------------------------------------------------
			-- CONTROLLO SE SONO PRESENTI RAGGRUPAMENTI CON UN SOLO MEMBRO --
			-----------------------------------------------------------------
			IF EXISTS ( SELECT TOP 1 ID FROM CTL_DOC gruppo WITH(NOLOCK) where gruppo.TipoDoc = 'AVCP_GRUPPO' and gruppo.LinkedDoc = @versionelotto and gruppo.Deleted = 0 and gruppo.StatoFunzionale = 'Pubblicato' and gruppo.Deleted = 0 )
			BEGIN

				-- IL RAGGRUPPAMENTO PER ESSERE VALIDO DEVE AVERE PIU' DI UN MEMBRO
				IF exists ( 
					Select gp.idheader, count(gp.idheader)
						from ctl_doc gruppo with(nolock)
								inner join document_AVCP_partecipanti gp with(nolock) on gp.Idheader = gruppo.id
						where gruppo.TipoDoc = 'AVCP_GRUPPO' and gruppo.LinkedDoc = @versionelotto and gruppo.Deleted = 0 and gruppo.StatoFunzionale = 'Pubblicato' and gruppo.Deleted = 0
						group by gp.idheader
						having count(gruppo.Id) < 2
				)			
				BEGIN

					update document_AVCP_lotti 
							set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'Tutti i raggruppamenti devono avere almeno 2 membri' + '</br>' 
						where idHeader=@idlotto

				END

			END

			-------------------------------------------- 
			-- WARNING PER LA SCELTA CONTRAENTE VUOTA --
			--------------------------------------------
			update document_AVCP_lotti 
					set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + 'Scelta contraente vuota.' + '</br>' 
				where idHeader=@idlotto and isnull(Scelta_contraente,'')  = ''



			if EXISTS (select * from document_AVCP_lotti  with(nolock) where  ISNULL(cast( Warning as nvarchar(4000)),'') <> '' and idheader=@idlotto)
			BEGIN
				update document_AVCP_lotti set Warning = 'CIG Lotto:' + @cig + '</br>' +  ISNULL(cast( Warning as nvarchar(4000)),'') where idHeader=@idlotto
			END

			


			declare @idgara int
			set @idgara = NULL

			
			select @idgara=max(gara.id) 
				from ctl_doc gara with(nolock) 
						inner join ctl_doc lotto with(nolock) ON lotto.LinkedDoc = gara.versione 
				where gara.Tipodoc='AVCP_GARA' and gara.StatoFunzionale <> 'Variato' 

			IF ( not @idgara is null )
			BEGIN

				--print 'RICORSIONE SU : ID-GARA: ' + cast(@idgara as varchar)
				--print 'RICORSIONE SU : ID-LOTTO: ' + cast(@idlotto as varchar)
				--print ' '
				exec AVCP_CONTROLLI_DOCUMENT_AVCP @idgara

			END
					


		END

END


















GO
