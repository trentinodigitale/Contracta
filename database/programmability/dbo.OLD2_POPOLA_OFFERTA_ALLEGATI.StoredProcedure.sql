USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_POPOLA_OFFERTA_ALLEGATI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






	--select *
	--	from CTL_DOC with(nolock) 
	--	where TipoDoc='OFFERTA_ALLEGATI' and Deleted=0 order by 1 desc

	--update ctl_doc
	--	set deleted = 1
	--where id in ( 330460,330459 )

	--select top 100 * from ctl_doc_value where dzt_name = 'LettaBusta' order by 1 desc

	--update ctl_doc_value 
	--	set idheader = -IdHeader
	--where idrow IN ( 10045261,10045258 )

--	select * from ctl_doc where id IN ( 330437,330416)

CREATE  proc [dbo].[OLD2_POPOLA_OFFERTA_ALLEGATI] ( @idpda as INT, @idofferta as INT,@NUMERO_LOTTO as INT ,  @busta as VARCHAR(255) , @iduser as int,@ModelName varchar(200))
as
begin	
	SET NOCOUNT ON

	DECLARE @id_off_all int
	DECLARE @SQL_UPD as nvarchar(max)
	DECLARE @SectionName as nvarchar(200)
--	DECLARE @stato_firma as nvarchar(200)
	DECLARE @HASH_FILE as nvarchar(250)
	
	declare @Idheader as int
	declare @AllegatoMulti as nvarchar(max)

--	set @stato_firma=''
	set @SQL_UPD=''
	set @id_off_all=0
	
	--VERIFICA SE PER IL DOC OFFERTA PASSATO ESISTE IL DOC OFFERTA_ALLEGATI
	select @id_off_all=id
		from CTL_DOC with(nolock) 
		where LinkedDoc=@idofferta and TipoDoc='OFFERTA_ALLEGATI' and Deleted=0

	--SE NON ESISTE IL DOCUMENTO LO CREA
	if @id_off_all=0
	begin

		insert into ctl_doc (IdPfu,Titolo,TipoDoc,Data,LinkedDoc,Fascicolo)
			select @iduser,'Allegati Offerta','OFFERTA_ALLEGATI',GETDATE(),@idofferta,fascicolo
				from CTL_DOC with(nolock)
				where Id=@idofferta
		
		set @id_off_all=SCOPE_IDENTITY()

	end
	
	DECLARE @ListAttach TABLE
	(
		idrow int,
		Allegato  nvarchar(max)
	)
	
	--ALLEGATI BUSTA AMMINISTRATIVA
	--se @NUMERO_LOTTO = NULL intendiamo la busta amministrativa
	if @NUMERO_LOTTO IS NULL
	BEGIN
			
			--metto in una temp gli allegati, che possono essere multipli, della busta documentazione
			--applicando la split sul valore con il separatore *** degli n valori 
			DECLARE crsAttach CURSOR STATIC FOR 
			
				select 
						OA.idrow, OA.Allegato
					from 
						CTL_DOC_ALLEGATI OA with(nolock)	
					where idHeader=@idofferta and ISNULL(Allegato,'')<> ''

			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
			insert into @ListAttach
					(idrow,Allegato)
				select @Idheader , *
						from split(@AllegatoMulti,'***')

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
			END

			CLOSE crsAttach 
			DEALLOCATE crsAttach 

			--INSERISCE GLI ALLEGATI PRESENTI NELLA BUSTA_DOCUMENTAZIONE - lista allegati
			--MI METTO IN UNA TEMP GLI ALLEGATI ED HASH DEL FILE pER EVITARE PROBLEMI NELLA JOIN CON CTL_SIGN_ATTACH_INFO
			select 
					
					A.[idrow], A.[idHeader], A.[Descrizione], M.[Allegato], A.[Obbligatorio], 
					A.[AnagDoc], A.[DataEmissione], A.[Interno], A.[Modified], A.[NotEditable], 
					A.[TipoFile], A.[DataScadenza], A.[DSE_ID], A.[EvidenzaPubblica], A.[RichiediFirma], A.[FirmeRichieste], A.[AllegatoRisposta], 
					A.[EsitoRiga],
					dbo.GetPos(M.Allegato,'*',4) as HASH_FILE INTO #tmp_work 
				from 
					CTL_DOC_ALLEGATI  A with(nolock)	
						inner join @ListAttach M on M.idrow=A.idrow
				--where idHeader=@idofferta --and ISNULL(Allegato,'')<> ''
			

			--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
			declare CurUpdateCF Cursor FAST_FORWARD for 
			
				select HASH_FILE from #tmp_work t with(nolock)
	
			open CurUpdateCF

			FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
				FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 
			END 

			CLOSE CurUpdateCF
			DEALLOCATE CurUpdateCF

			insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma)
				select @id_off_all,'DOCUMENTAZIONE',Descrizione,Allegato,isnull(firmatario,''),isnull(codFiscFirmatario,''),t.Obbligatorio,t.RichiediFirma,'', info.statoFirma
					from #tmp_work t with(nolock)
						left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and Allegato=DA.Attach_Hash
					where DA.IdRow IS NULL
		
			drop table #tmp_work;

			--SE PRESENTE IL DGUE STRUTTURATO LO AGGIUNGE
			IF EXISTS ( select idheader from OFFERTA_VIEW_DGUE where idheader=@idofferta and dse_id='DISPLAY_DGUE' and DZT_NAME='Allegato' and value <> '')
			BEGIN
				select * INTO #tmp_work_dgue  from (
				--PRENDO IL DGUE DELLA MANDATARIA
				select 
					'1' as obbligatorio,'1' as RichiediFirma ,value as allegato,dbo.GetPos(value,'*',4) as HASH_FILE,A.aziragionesociale 						
				from 
					OFFERTA_VIEW_DGUE 
						inner join ctl_doc C with(nolock) on C.id=@idofferta 
						inner join aziende A with(nolock) on A.idazi=C.azienda
					where idheader=@idofferta and dse_id='DISPLAY_DGUE' and DZT_NAME='Allegato' and value <> ''
				--AGGIUNGO ALLA TEMP I DGUE DELLE PARTECIPANTI DOVE LE TROVO
				union all
				select 
					'1' as obbligatorio,'1' as RichiediFirma ,AllegatoDGUE as allegato,dbo.GetPos(AllegatoDGUE,'*',4) as HASH_FILE ,A.aziragionesociale 						
					from 
						Document_Offerta_Partecipanti with(nolock) 
							inner join aziende A with(nolock) on A.idazi=Document_Offerta_Partecipanti.idazi
					where idheader=@idofferta and ISNULL(allegatodgue,'') <> '' 
				) as a 
				


				--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
				declare CurUpdateCF Cursor FAST_FORWARD for
				
					select HASH_FILE from #tmp_work_dgue t with(nolock)
					
				open CurUpdateCF
				FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
					FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 
				END 
				CLOSE CurUpdateCF
				DEALLOCATE CurUpdateCF

				insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma)
				select @id_off_all,'DOCUMENTAZIONE','DGUE - ' + t.aziRagioneSociale,Allegato,isnull(firmatario,''),isnull(codFiscFirmatario,''),t.Obbligatorio,t.RichiediFirma,'', info.statoFirma
					from #tmp_work_dgue t with(nolock)
						left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and Allegato=DA.Attach_Hash
					where DA.IdRow IS NULL
		
				drop table #tmp_work_dgue;
				
			END

		
			--SE ESISTE AGGIUNGE ANCHE LA CLAUSOLA FIDEIUSSORIA
			IF EXISTS ( select idRow  from CTL_DOC_SIGN with(nolock) where idHeader=@idofferta and ISNULL(F2_SIGN_ATTACH,'')<> '' )
			BEGIN

				select 
					*, dbo.GetPos(F2_SIGN_ATTACH,'*',4) as HASH_FILE into #tmp_work2 
					from CTL_DOC_SIGN 
					where idHeader=@idofferta and ISNULL(F2_SIGN_ATTACH,'')<> ''

				--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
				declare CurUpdateCF Cursor FAST_FORWARD for
				
					select HASH_FILE from #tmp_work2 t with(nolock)
					
				open CurUpdateCF
				FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
					FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 
				END 
				CLOSE CurUpdateCF
				DEALLOCATE CurUpdateCF

				insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma)
					select @id_off_all,'DOCUMENTAZIONE','Attestato di Partecipazione',F2_SIGN_ATTACH,isnull(firmatario,''),isnull(codFiscFirmatario,''),1,1,'', info.statoFirma
						from #tmp_work2 t with(nolock)
							left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
							left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and t.F2_SIGN_ATTACH=DA.Attach_Hash
						where DA.IdRow IS NULL
		
				drop table #tmp_work2;
			END

	END --FINE ALLEGATI BUSTA AMMINISTRATIVA
	

	--ALLEGATI BUSTA TECNICA/ECONOMICA PER GARE A LOTTI 
	IF  @NUMERO_LOTTO IS NOT NULL and @NUMERO_LOTTO <> -1
	BEGIN

		IF @busta in ( 'OFFERTA_BUSTA_TEC','BUSTA_TECNICA')
		BEGIN
			--RECUPERA LA BUSTA FIRMATA PER IL LOTTO 
			select DF.F2_SIGN_ATTACH, dbo.GetPos(F2_SIGN_ATTACH,'*',4) as HASH_FILE into #tmp_work_busta_tec 
				from Document_MicroLotti_Dettagli DM with(nolock) 				
						inner join Document_Microlotto_Firme DF  with(nolock) on DF.idHeader=DM.id and ISNULL(DF.F2_SIGN_ATTACH,'')<> ''	
				where DM.idHeader=@idofferta and DM.tipodoc='OFFERTA' and DM.NumeroLotto = @NUMERO_LOTTO 	
		
			--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
			declare CurUpdateCF Cursor FAST_FORWARD for 
			
				select HASH_FILE from #tmp_work_busta_tec t with(nolock)					
			
			open CurUpdateCF
			FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
				FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 
			END 
			CLOSE CurUpdateCF
			DEALLOCATE CurUpdateCF	
			
			
			insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma, numeroLotto)
				select @id_off_all,'TECNICA','File Firmato - Lotto ' + CAST(@NUMERO_LOTTO as varchar(500)),F2_SIGN_ATTACH,isnull(firmatario,''),isnull(codFiscFirmatario,''),NULL,NULL,'', info.statoFirma, @NUMERO_LOTTO
					from #tmp_work_busta_tec with(nolock)
						left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and F2_SIGN_ATTACH=DA.Attach_Hash
					where DA.IdRow IS NULL
		
			drop table #tmp_work_busta_tec;
		END

		IF  @busta in ( 'OFFERTA_BUSTA_ECO' , 'BUSTA_ECONOMICA')
		BEGIN
			--RECUPERA LA BUSTA FIRMATA PER IL LOTTO 
			select DF.F1_SIGN_ATTACH, dbo.GetPos(F1_SIGN_ATTACH,'*',4) as HASH_FILE into #tmp_work_busta_eco
				from Document_MicroLotti_Dettagli DM with(nolock) 				
						inner join Document_Microlotto_Firme DF  with(nolock) on DF.idHeader=DM.id and ISNULL(DF.F1_SIGN_ATTACH,'')<> ''	
				where DM.idHeader=@idofferta and DM.tipodoc='OFFERTA' and DM.NumeroLotto = @NUMERO_LOTTO 	
			

			--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
			declare CurUpdateCF Cursor FAST_FORWARD for 
			
				select HASH_FILE from #tmp_work_busta_eco t with(nolock)
					
			
			open CurUpdateCF
			FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
				FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 

			END 

			CLOSE CurUpdateCF
			DEALLOCATE CurUpdateCF


			insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma)
				select @id_off_all,'ECONOMICA','File Firmato - Lotto ' + CAST(@NUMERO_LOTTO as varchar(500)),F1_SIGN_ATTACH,isnull(firmatario,''),isnull(codFiscFirmatario,''),NULL,NULL,'', info.statoFirma
					from #tmp_work_busta_eco with(nolock)
						left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and F1_SIGN_ATTACH=DA.Attach_Hash
				where DA.IdRow IS NULL
		
			drop table #tmp_work_busta_eco;

		END	
	END --FINE ALLEGATI BUSTA TECNICA/ECONOMICA A LOTTI

	--ALLEGATI BUSTA TECNICA/ECONOMICA PER GARE SENZA LOTTI
	IF  @NUMERO_LOTTO IS NOT NULL and @NUMERO_LOTTO = -1
	BEGIN

		IF @busta in ( 'OFFERTA_BUSTA_TEC','BUSTA_TECNICA')
		BEGIN

			--RECUPERA LA BUSTA FIRMATA 
			select F3_SIGN_ATTACH, dbo.GetPos(F3_SIGN_ATTACH,'*',4) as HASH_FILE into #tmp_work_busta_tec_N 
				from CTL_DOC_SIGN DM with(nolock) 
				where DM.idHeader=@idofferta				
				
			--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
			declare CurUpdateCF Cursor FAST_FORWARD for 
			
				select HASH_FILE from #tmp_work_busta_tec_N t with(nolock)
		
			open CurUpdateCF
			FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
				FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE
				 
			END 
			CLOSE CurUpdateCF
			DEALLOCATE CurUpdateCF


			insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma, numeroLotto)
				select @id_off_all,'TECNICA','File Firmato',F3_SIGN_ATTACH,isnull(firmatario,''),isnull(codFiscFirmatario,''),NULL,NULL,'', info.statoFirma, @NUMERO_LOTTO
					from #tmp_work_busta_tec_N with(nolock)
						left join CTL_SIGN_ATTACH_INFO info  with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and F3_SIGN_ATTACH=DA.Attach_Hash
					where DA.IdRow IS NULL
		
			drop table #tmp_work_busta_tec_N;

		END

		IF  @busta in ( 'OFFERTA_BUSTA_ECO' , 'BUSTA_ECONOMICA')
		BEGIN

			--RECUPERA LA BUSTA FIRMATA PER IL LOTTO 
			select F1_SIGN_ATTACH, dbo.GetPos(F1_SIGN_ATTACH,'*',4) as HASH_FILE into #tmp_work_busta_eco_N
				from CTL_DOC_SIGN DM with(nolock) 
					where DM.idHeader=@idofferta		
			
			--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
			declare CurUpdateCF Cursor FAST_FORWARD for 	
			
				select HASH_FILE from #tmp_work_busta_eco_N t with(nolock)					
			
			open CurUpdateCF
			FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				exec [GET_INFO_FIRMA] '','','','',@HASH_FILE
				
				FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE 
			END 
			CLOSE CurUpdateCF
			DEALLOCATE CurUpdateCF


			insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma, numeroLotto)
				select @id_off_all,'ECONOMICA','File Firmato' + CAST(@NUMERO_LOTTO as varchar(500)),F1_SIGN_ATTACH,isnull(firmatario,''),isnull(codFiscFirmatario,''),NULL,NULL,'', info.statoFirma, @NUMERO_LOTTO
					from #tmp_work_busta_eco_N with(nolock)
						left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
						left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader=@id_off_all and F1_SIGN_ATTACH=DA.Attach_Hash
					where DA.IdRow IS NULL
		
			drop table #tmp_work_busta_eco_N;
		END
	END --FINE ALLEGATI BUSTA TECNICA/ECONOMICA SENZA LOTTI
	
	IF  @NUMERO_LOTTO IS NOT NULL
	BEGIN		
		--RECUPERO EVENTUALI ALLEGATI PRESENTI SULLE RIGHE DI PRODOTTI
		IF EXISTS ( select MA_MOD_ID 
						from  CTL_ModelAttributes WITH(NOLOCK)
							inner join LIB_Dictionary d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name and d.DZT_Type=18
						where MA_MOD_ID= @ModelName
				   )
		BEGIN
			
			if @NUMERO_LOTTO = -1
				set @NUMERO_LOTTO=ABS(@NUMERO_LOTTO)
			
			declare @MA_DescML as nvarchar(max)
			declare @MA_DZT_Name as varchar(500)

			IF  @busta in ( 'OFFERTA_BUSTA_ECO' , 'BUSTA_ECONOMICA')
				set @SectionName='ECONOMICA'

			IF @busta in ( 'OFFERTA_BUSTA_TEC','BUSTA_TECNICA')
				set @SectionName='TECNICA'

				declare CurUpdate Cursor FAST_FORWARD for 
					
					select MA_DescML , MA_DZT_Name 
						from  CTL_ModelAttributes  WITH(NOLOCK) 
							inner join LIB_Dictionary d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name and d.DZT_Type=18							
						where MA_MOD_ID=@ModelName

				open CurUpdate
				FETCH NEXT FROM CurUpdate  INTO @MA_DescML , @MA_DZT_Name 

				WHILE @@FETCH_STATUS = 0
				BEGIN
			
					set @MA_DescML = dbo.StripHTML( @MA_DescML  )


					set @SQL_UPD='
						
						declare @Idheader as int
						declare @AllegatoMulti as nvarchar(max)
						declare @NumeroLotto as varchar(10)
						declare @Voce as varchar(100)

						DECLARE @ListAttach TABLE
							(
								idHeader int,
								NumeroLotto varchar(10),
								Voce varchar(100),
								Allegato  nvarchar(max)
							)

					    
						--metto in una temp gli allegati, che possono essere multipli
						--applicando la split sul valore con il separatore *** degli n valori 
						DECLARE crsAttach CURSOR STATIC FOR 
			
							select 
								DM.idHeader, ' + @MA_DZT_Name + ' as Allegato, NumeroLotto , Voce
						
								from 
									Document_MicroLotti_Dettagli DM WITH(NOLOCK) 
								where DM.idHeader=' + CAST (@idofferta as varchar(20)) + ' and DM.TipoDoc=''OFFERTA'' and NumeroLotto=' + cast(@NUMERO_LOTTO as varchar(200)) + ' and ' + @MA_DZT_Name + ' <> '''' 
						
						OPEN crsAttach

						FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti,  @NumeroLotto, @Voce
						WHILE @@FETCH_STATUS = 0
						BEGIN
			
							insert into @ListAttach
									(idheader,Allegato,NumeroLotto,Voce)
								select @Idheader , *,  @NumeroLotto, @Voce 
									 from split(@AllegatoMulti,''***'')

							FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroLotto, @Voce
						END

						CLOSE crsAttach 
						DEALLOCATE crsAttach 

							

						declare @HASH_FILE as nvarchar(250)
						--select ''' + RTRIM(LTRIM(replace(@MA_DescML,'''',''''''))) + ''' as descrizione ,' + @MA_DZT_Name + ' as allegato,  dbo.GetPos(' + @MA_DZT_Name +',''*'',4) as HASH_FILE , cast(Voce as varchar(100)) as Voce into #tmp_work_r
						select ''' + RTRIM(LTRIM(replace(@MA_DescML,'''',''''''))) + ''' as descrizione , allegato,  dbo.GetPos(allegato,''*'',4) as HASH_FILE , cast(Voce as varchar(100)) as Voce into #tmp_work_r
							from 
								@ListAttach 
						--from Document_MicroLotti_Dettagli DM WITH(NOLOCK) 
						--	where idHeader=' + CAST (@idofferta as varchar(20)) + ' and TipoDoc=''OFFERTA'' and NumeroLotto=' + cast(@NUMERO_LOTTO as varchar(200)) + ' and ' + @MA_DZT_Name + ' <> '''' 
							
						--FACCIAMO UN CURSORE PER TOGLIERE DAL CF DEL FIRMATARIO AREA GEOGRAFICA
						declare CurUpdateCF Cursor FAST_FORWARD for
							select HASH_FILE 
								from #tmp_work_r  with(nolock)									
			
						open CurUpdateCF
						FETCH NEXT FROM CurUpdateCF INTO @HASH_FILE
						WHILE @@FETCH_STATUS = 0
						BEGIN
				
							exec [GET_INFO_FIRMA] '''','''','''','''',@HASH_FILE
				
							FETCH NEXT FROM CurUpdateCF  INTO @HASH_FILE
						END 
						CLOSE CurUpdateCF
						DEALLOCATE CurUpdateCF

						insert into Document_Offerta_Allegati (Idheader,SectionName,Attach_Description,Attach_Hash,Attach_Signers,Attach_Signers_CF,Obbligatorio,RichiediFirma,Attach_Name, statoFirma, numeroLotto)
							select '+ CAST(@id_off_all as varchar(500)) +',''' + @SectionName +''',descrizione + '' - Lotto ' +  CAST(@NUMERO_LOTTO as varchar(500)) + ' - Voce '' + Voce ,allegato,isnull(firmatario,''''),isnull(codFiscFirmatario,''''),NULL,NULL,'''', info.statoFirma, ' +  CAST(@NUMERO_LOTTO as varchar(500)) + '
								from #tmp_work_r t with(nolock)
									left join CTL_SIGN_ATTACH_INFO info with(nolock) on ATT_Hash=HASH_FILE
									left join Document_Offerta_Allegati DA with(nolock)  on DA.Idheader='+ CAST(@id_off_all as varchar(500)) +' and t.allegato=DA.Attach_Hash
								where DA.IdRow IS NULL
						
						drop table #tmp_work_r '
			
					--print @SQL_UPD
					--insert into CTL_TRACE (descrizione)
						--select @SQL_UPD
					exec (@SQL_UPD)
						
					FETCH NEXT FROM CurUpdate  INTO @MA_DescML , @MA_DZT_Name 

				END 

				CLOSE CurUpdate
				DEALLOCATE CurUpdate

		END

	END --FINE ALLEGATI BUSTA TECNICA/ECONOMICA PRODOTTI

	
	
	---Dopo aver aggiunto gli allegati deve analizzare il contenuto per stabilire lo stato da dare alla colonna "Stato Firma"
	-- cella vuota - La colonna si present inizialmente vuota, 
    -- Spunta verde OK - poi aprendo la busta amministrativa se tutti i documenti presenti sono firmati da una persona comune a tutti 
    -- X rossa KO - è presente un allegato senza firma
    -- warning WARNING - i documenti sono tutti firmati ma non c'è una persona comune a tutti
	EXEC AGGIORNA_OFFERTA_ALLEGATI @idpda, @id_off_all,@idofferta 
	


end


GO
