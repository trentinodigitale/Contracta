USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GET_HASH_FOR_DOWNLOAD_ATTACH_CONTEXT]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_GET_HASH_FOR_DOWNLOAD_ATTACH_CONTEXT] (@Contesto varchar(500), @idDoc int , @IdUser int )
AS
BEGIN
    
	set nocount off
	
	declare @ModelloBusta as varchar (1000)
	declare @IdGara as int
	declare @AttribAttach as varchar(500)
	declare @strSQL as nvarchar(max)
	declare @dse_id as varchar(500)
	declare @PrefisoContesto as varchar(10)
	declare @ColBustaFirmata as varchar(500)
	declare @dse_id_Letta_busta as varchar(500)
	declare @idPda as int
	declare @NumeroLotto as varchar (100)
	declare @Idheader as int
	declare @AllegatoMulti as nvarchar(max)

	set @ModelloBusta=''
	set @IdGara = -1


	DECLARE @ListAttach TABLE
	(
		idHeader int,
		Allegato  nvarchar(max)
	)

	--RECUPERO HASH ALLEGATI DELLA BUSTA AMMINISTRATIVA DI TUTTE LE OFFERTE
	if @Contesto ='BUSTA_AMMINISTRATIVA' 
	begin
		
			--SE SONO PRESENTI OFFERTE CON IL DGUE STRUTTURATO AGGIUNGE EVENTUALI DGUE
			select * INTO #tmp_work_dgue  
				from (
					--PRENDO IL DGUE DELLA MANDATARIA
					select  PO.IdMsg as Idheader,value as allegato,A.aziragionesociale 
						from document_pda_offerte PO with (nolock) 
							inner join OFFERTA_VIEW_DGUE O on O.idheader=PO.IdMsg and dse_id='DISPLAY_DGUE' and DZT_NAME='Allegato' and value <> ''
							inner join ctl_doc C with(nolock) on C.id=PO.IdMsg 
							inner join aziende A with(nolock) on A.idazi=C.azienda
						where PO.idheader = @idDoc
					--AGGIUNGO ALLA TEMP I DGUE DELLE PARTECIPANTI DOVE LE TROVO
					union all
					select PO.IdMsg as Idheader,AllegatoDGUE as allegato,A.aziragionesociale 					
						from document_pda_offerte PO with (nolock)
							inner join  Document_Offerta_Partecipanti PA with(nolock) on PA.idheader=PO.IdMsg and ISNULL(allegatodgue,'') <> '' 
							inner join aziende A with(nolock) on A.idazi=PA.idazi							
						where PO.idheader = @idDoc
			) as a 
				
			--SE SONO PRESENTI AGGIUNGE ALLEGATI DEL MODULO QUESTIONARIOAMMINISTRATIVO
			select * INTO #tmp_work_Questionario  
				from (
					--PRENDO allegato firmato DEL #tmp_work_Questionario
					select  PO.IdMsg as Idheader,value as allegato,A.aziragionesociale 
						from document_pda_offerte PO with (nolock) 
							inner join OFFERTA_VIEW_QUESTIONARIO O on O.idheader=PO.IdMsg and dse_id='DISPLAY_QUESTIONARIO' and DZT_NAME='AllegatoQuestionario' and value <> ''
							inner join ctl_doc C with(nolock) on C.id=PO.IdMsg 
							inner join aziende A with(nolock) on A.idazi=C.azienda
						where PO.idheader = @idDoc
					--AGGIUNGO ALLA TEMP GLI ALLEGATI CONTENUTI ALL'INTERNO DEL MODULO QUESTIONARIO
					union all
					select PO.IdMsg as Idheader,MA.value as allegato,A.aziragionesociale 					
						from document_pda_offerte PO with (nolock)
							--modulo questionario legato all'offerta
							inner join ctl_doc M with(nolock) on M.linkedDoc=PO.IdMsg and M.tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and isnull(m.SIGN_ATTACH,'')<>''
							inner join CTL_DOC_SECTION_MODEL MO with(nolock) on MO.IdHeader = M.id  and MO.DSE_ID='MODULO'
							inner join CTL_ModelAttributes MOA with(nolock) on MOA.MA_MOD_ID = MO.MOD_Name and MOA.DZT_Type=18
							inner join ctl_doc_value MA with(nolock) on MA.IdHeader = M.id and ma.DZT_Name = MOA.MA_DZT_Name and ma.value <>''

							--inner join  Document_Offerta_Partecipanti PA with(nolock) on PA.idheader=PO.IdMsg and ISNULL(allegatodgue,'') <> '' 
							inner join aziende A with(nolock) on A.idazi=PO.idAziPartecipante							
						where PO.idheader = @idDoc
			) as a 


		
		--Nome PIxxxxxx-yy_BA_CODFISC - RagioneSociale ( primi 5 caratteri )   
		
		--metto in una temp gli allegati, che possono essre multipli, della busta documentazione
		--applicando la split sul valore con il separatore *** degli n valori 
		DECLARE crsAttach CURSOR STATIC FOR 
			
			select 
				OA.idHeader, OA.Allegato
			from 
				document_pda_offerte PO with (nolock)
					inner join ctl_doc_value OL with (nolock) on OL.IdHeader = PO.idmsg and OL.DSE_ID ='BUSTA_DOCUMENTAZIONE' and OL.DZT_Name ='LettaBusta' and OL.value='1'
					inner join ctl_doc_allegati OA with (nolock) on OA.idHeader = PO.idmsg and ISNULL( OA.Allegato , '' ) <> '' 
			where 
				PO.idheader = @idDoc
			
			union all
			
			select 
				OA.idHeader, OA.Allegato
			from #tmp_work_dgue OA

			union all

			select 
				OA.idHeader, OA.Allegato
			from #tmp_work_Questionario OA


		OPEN crsAttach

		FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			insert into @ListAttach
					(idheader,Allegato)
				select @Idheader , *
					 from split(@AllegatoMulti,'***')

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
		END

		CLOSE crsAttach 
		DEALLOCATE crsAttach 



		insert into 
			ctl_import
			(idpfu,A,B,C,D,E)
		select 
			@IdUser,
			O.protocollo + '_BA_' + AE.vatValore_FT + ' - ' + left(PO.aziRagioneSociale,5) as Cartella , 
			dbo.getpos( OA.Allegato,'*',4) as Att_Hash,
			dbo.getpos( OA.Allegato,'*',3) as Size,
			'' as Esito,
			ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
			from 
				document_pda_offerte PO with (nolock)
					inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome ='codicefiscale'
					inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc in ('OFFERTA','DOMANDA_PARTECIPAZIONE') and statopda not in ('99')
					inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='BUSTA_DOCUMENTAZIONE' and OL.DZT_Name ='LettaBusta' and OL.value='1'
					--inner join ctl_doc_allegati OA with (nolock) on OA.idHeader = O.id and ISNULL( OA.Allegato , '' ) <> '' 
					inner join @ListAttach OA on OA.idHeader = O.id --and ISNULL( OA.Allegato , '' ) <> ''  
					--inner join ctl_attach ATT with (nolock) on ATT.ATT_Hash = dbo.getpos( OA.Allegato,'*',4)
			where 
				PO.idheader = @idDoc
				order by O.Protocollo asc
			
	end  

	 --select * from ctl_doc_allegati where idheader = 413252
	 --2020_06_11_richiesta_sater.pdf*pdf*499849*rb69ce1d0b874449a_20210601074336285*SHA256*D8196A5F737D53B24E6529F02FDCBE1B92E0E6F625BF8F5C9A24801569A00519*2021-06-01T09:43:37
	 --select * from ctl_Attach where att_hash = 'rb69ce1d0b874449a_20210601074336285'

	--RECUPERO HASH ALLEGATI DELLA BUSTA TECNICA DI TUTTE LE OFFERTE
	if @Contesto  in ('TECNICA_MONOLOTTO','ECONOMICA_MONOLOTTO')
	begin
		
		--RECUPERO ID GARA 
		select @IdGara= linkeddoc from ctl_doc with (nolock) where id = @idDoc
		--select linkeddoc from ctl_doc with (nolock) where id = 413263
		--select 
		--	* 
		--	from 
		--		CTL_DOC_SECTION_MODEL with (nolock) where idheader =  413247

		set @dse_id='BUSTA_TECNICA'
		set @PrefisoContesto= 'BT'
		set @ColBustaFirmata = 'F3_SIGN_ATTACH'
		if @Contesto = 'ECONOMICA_MONOLOTTO'
		begin
			set @dse_id='BUSTA_ECONOMICA'
			set @PrefisoContesto ='BE'
			set @ColBustaFirmata = 'F1_SIGN_ATTACH'
		end

		--RECUPERO NOME MODELLO BUSTA TECNICA/BUSTA ECONOMICA
		select 
			@ModelloBusta=Mod_Name 
			from 
				CTL_DOC_SECTION_MODEL with (nolock)  
			where idheader = @IdGara and dse_id= @dse_id

		--CONSERVO ATTRIBUTI DI TIPO ALLEGATO IN UNA TEMP
		select 
			MA_DZT_Name into #colAttach
			from 
				CTL_ModelAttributes with (nolock)
					inner join LIB_Dictionary L with (nolock) on MA_DZT_Name = dzt_name and L.DZT_Type  =18
			where MA_MOD_ID =@ModelloBusta order by MA_Pos 
		
		
		set @strSQL=''
		DECLARE crsAttrib CURSOR STATIC FOR 
			select ma_dzt_name from #colAttach

		OPEN crsAttrib

		FETCH NEXT FROM crsAttrib INTO @AttribAttach
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			set @strSQL='
			
			declare @Idheader as int
			declare @AllegatoMulti as nvarchar(max)
			declare @NumeroRiga as int

			DECLARE @ListAttach TABLE
				(
					idHeader int,
					NumeroRiga int,
					Allegato  nvarchar(max)

				)

			--metto in una temp gli allegati, che possono essre multipli, della busta documentazione
			--applicando la split sul valore con il separatore *** degli n valori 
			DECLARE crsAttach CURSOR STATIC FOR 
			
				select 
					DO.idHeader, ' + @AttribAttach + ' as Allegato, NumeroRiga
				from 
					document_pda_offerte PO with (nolock)
						inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
						inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1''
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc 
						
					where 
						PO.idheader = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @AttribAttach + ' , '''' )  <> '''' order by O.Protocollo,NumeroLotto asc 
			
			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroRiga
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				insert into @ListAttach
						(idheader,Allegato,NumeroRiga)
					select @Idheader , *, @NumeroRiga
						 from split(@AllegatoMulti,''***'')

				FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroRiga
			END

			CLOSE crsAttach 
			DEALLOCATE crsAttach 


			insert into 
				ctl_import
				(idpfu,A,B,C,D)
				select 
					' + cast(@IdUser as varchar(50)) + ',
					O.protocollo + ''_' + @PrefisoContesto + '_'' + AE.vatValore_FT + '' - '' + left(PO.aziRagioneSociale,5) as Cartella , 
					--dbo.getpos( ' + @AttribAttach + ',''*'',4) as Att_Hash,
					--dbo.getpos( ' + @AttribAttach + ',''*'',3) as Size,
					dbo.getpos( allegato,''*'',4) as Att_Hash,
					dbo.getpos( allegato,''*'',3) as Size,
					'''' as Esito--,
					--ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
				from 
					document_pda_offerte PO with (nolock)
						inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome =''codicefiscale''
						inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
						inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1''
						--inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc
						inner join @ListAttach DO on DO.idHeader = O.id
				where 
					--PO.idheader = ' + cast(@idDoc as varchar(50)) + ' and ' + @AttribAttach + ' <> '''' order by O.Protocollo,NumeroRiga asc 
					  PO.idheader = ' + cast(@idDoc as varchar(50)) + ' order by O.Protocollo,NumeroRiga asc 
				
				'
			
			exec ( @strSQL )

			

		FETCH NEXT FROM crsAttrib INTO @AttribAttach
		END

		CLOSE crsAttrib 
		DEALLOCATE crsAttrib 

		--cancello la tabella temporanea
		drop table #colAttach

		
		--AGGIUNGO ALLEGATO DELLA BUSTA DI COMPETENZA FIRMATA
		set @strSQL='
		
			insert into 
				ctl_import
				(idpfu,A,B,C,D)
				select 
					' + cast(@IdUser as varchar(50)) + ',
					O.protocollo + ''_' + @PrefisoContesto + '_'' + AE.vatValore_FT + '' - '' + left(PO.aziRagioneSociale,5) as Cartella , 
					dbo.getpos( ' + @ColBustaFirmata + ',''*'',4) as Att_Hash,
					dbo.getpos( ' + @ColBustaFirmata + ',''*'',3) as Size,
					'''' as Esito--,
					--ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
				from 
					document_pda_offerte PO with (nolock)
						inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome =''codicefiscale''
						inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
						inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1''
						inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 
				where 
					PO.idheader = ' + cast(@idDoc as varchar(50)) + ' order by O.Protocollo asc '
			

			
		
		exec ( @strSQL )
		
		--valorizzo la colonna E in modo crescente
		UPDATE  D
			SET D.E = x.E_NEW
			FROM (
				  SELECT ID, ROW_NUMBER() OVER (ORDER BY [id]) AS E_NEW
					FROM ctl_import where idpfu = @IdUser
				  ) x inner join ctl_import D on x.id=D.id

			


		
				
	end 


	--RECUPERO HASH ALLEGATI DELLA BUSTA TECNICA DI TUTTE LE OFFERTE
	if @Contesto  in ('TECNICA_LISTA_LOTTI','ECONOMICA_LISTA_LOTTI','TECNICA_DETTAGLIO_LOTTO','ECONOMICA_DETTAGLIO_LOTTO')
	begin
		set @NumeroLotto=''

		--SUL DETTAGLIO ID IN INPUT E' QUELLO DEL LOTTO PDA
		if @Contesto  in ('TECNICA_DETTAGLIO_LOTTO','ECONOMICA_DETTAGLIO_LOTTO')
		begin
			
			select 
				@idPda = idheader , @NumeroLotto=NumeroLotto
				from 
					Document_MicroLotti_Dettagli with (nolock)
				where Id = @idDoc
			
			set @idDoc = @idPda

		end
		
		--RECUPERO ID GARA 
		select @IdGara= linkeddoc from ctl_doc with (nolock) where id = @idDoc
		--select linkeddoc from ctl_doc with (nolock) where id = 413263
		--select 
		--	* 
		--	from 
		--		CTL_DOC_SECTION_MODEL with (nolock) where idheader =  413247

		set @dse_id='BUSTA_TECNICA'
		set @dse_id_Letta_busta = 'OFFERTA_BUSTA_TEC'
		set @PrefisoContesto= 'BT'
		set @ColBustaFirmata = 'F2_SIGN_ATTACH'
		if @Contesto in ( 'ECONOMICA_LISTA_LOTTI','ECONOMICA_DETTAGLIO_LOTTO')
		begin
			set @dse_id='BUSTA_ECONOMICA'
			set @PrefisoContesto ='BE'
			set @ColBustaFirmata = 'F1_SIGN_ATTACH'
			set @dse_id_Letta_busta = 'OFFERTA_BUSTA_ECO'
		end

		--RECUPERO NOME MODELLO BUSTA TECNICA/BUSTA ECONOMICA
		select 
			@ModelloBusta=Mod_Name 
			from 
				CTL_DOC_SECTION_MODEL with (nolock)  
			where idheader = @IdGara and dse_id= @dse_id

		--CONSERVO ATTRIBUTI DI TIPO ALLEGATO IN UNA TEMP
		select 
			MA_DZT_Name into #colAttach1
			from 
				CTL_ModelAttributes with (nolock)
					inner join LIB_Dictionary L with (nolock) on MA_DZT_Name = dzt_name and L.DZT_Type  =18
			where MA_MOD_ID =@ModelloBusta order by MA_Pos 
		
		
		set @strSQL=''
		DECLARE crsAttrib CURSOR STATIC FOR 
			select ma_dzt_name from #colAttach1

		OPEN crsAttrib

		FETCH NEXT FROM crsAttrib INTO @AttribAttach
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			set @strSQL='
			
			declare @Idheader as int
			declare @AllegatoMulti as nvarchar(max)
			declare @NumeroLotto as varchar(10)

			DECLARE @ListAttach TABLE
				(
					idHeader int,
					NumeroLotto varchar(10),
					Allegato  nvarchar(max)
				)

			--metto in una temp gli allegati, che possono essre multipli, della busta documentazione
			--applicando la split sul valore con il separatore *** degli n valori 
			DECLARE crsAttach CURSOR STATIC FOR 
			
				select 
					DO.idHeader, ' + @AttribAttach + ' as Allegato, NumeroLotto
				from 
					document_pda_offerte PO with (nolock)
						inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc ' 
						
						if @NumeroLotto <> '' 
							set @strSQL= @strSQL + ' and numerolotto = ' + @NumeroLotto 

						set @strSQL= @strSQL +	'
							--inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id_Letta_busta + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1'' and OL.row = DO.id
						
					where 
						PO.idheader = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @AttribAttach + ' , '''' )  <> '''' order by O.Protocollo,NumeroLotto asc 
			
			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti,  @NumeroLotto
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				insert into @ListAttach
						(idheader,Allegato,NumeroLotto)
					select @Idheader , *,  @NumeroLotto
						 from split(@AllegatoMulti,''***'')

				FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroLotto
			END

			CLOSE crsAttach 
			DEALLOCATE crsAttach 


			insert into 
				ctl_import
				(idpfu,A,B,C,D)
				select 
					' + cast(@IdUser as varchar(50)) + ',
					O.protocollo + ''_' + @PrefisoContesto + '_Lotto-'' + DO.NumeroLotto + ''-'' + AE.vatValore_FT + '' - '' + left(PO.aziRagioneSociale,5) as Cartella , 
					
					--dbo.getpos( ' + @AttribAttach + ',''*'',4) as Att_Hash,
					--dbo.getpos( ' + @AttribAttach + ',''*'',3) as Size,
					dbo.getpos( Allegato ,''*'',4) as Att_Hash,
					dbo.getpos( Allegato ,''*'',3) as Size,
					'''' as Esito --,
					--ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
					from 
						document_pda_offerte PO with (nolock)
							inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome =''codicefiscale''
							inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
							--inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc 
							inner join @ListAttach DO on DO.idHeader = O.id' 
						
						--if @NumeroLotto <> '' 
						--	set @strSQL= @strSQL + ' and numerolotto = ' + @NumeroLotto 

					set @strSQL= @strSQL +	'
							--inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id_Letta_busta + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1'' and OL.row = DO.id
							
					where 
						--PO.idheader = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @AttribAttach + ' , '''' )  <> '''' order by O.Protocollo,NumeroLotto asc 
						PO.idheader = ' + cast(@idDoc as varchar(50)) + ' order by O.Protocollo, cast(NumeroLotto as int) asc 
					'
			
			exec  ( @strSQL )
			--return

			

		FETCH NEXT FROM crsAttrib INTO @AttribAttach
		END

		CLOSE crsAttrib 
		DEALLOCATE crsAttrib 

		--cancello la tabella temporanea
		--drop table #colAttach

		
		--AGGIUNGO ALLEGATO DELLA BUSTA DI COMPETENZA FIRMATA
		set @strSQL='
			
			insert into 
				ctl_import
				(idpfu,A,B,C,D)
				select 
					' + cast(@IdUser as varchar(50)) + ',
					O.protocollo + ''_' + @PrefisoContesto + '_Lotto-'' + DO.NumeroLotto + ''-'' + AE.vatValore_FT + '' - '' + left(PO.aziRagioneSociale,5) as Cartella , 

					 
					dbo.getpos( ' + @ColBustaFirmata + ',''*'',4) as Att_Hash,
					dbo.getpos( ' + @ColBustaFirmata + ',''*'',3) as Size,
					'''' as Esito--,
					--ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
				from 
					document_pda_offerte PO with (nolock)
						inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome =''codicefiscale''
						inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc '

						if @NumeroLotto <> '' 
							set @strSQL= @strSQL + ' and numerolotto = ' + @NumeroLotto 
				
				set @strSQL= @strSQL +	'
						inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id_Letta_busta + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1'' and OL.row = DO.id
						inner join Document_Microlotto_Firme BF with (nolock) on BF.idheader=DO.id  
				where 
					PO.idheader = ' + cast(@idDoc as varchar(50)) + ' order by O.Protocollo,NumeroLotto asc '
			

			
		
		exec  ( @strSQL )
		
		--valorizzo la colonna E in modo crescente
		UPDATE  D
			SET D.E = x.E_NEW
			FROM (
				  SELECT ID, ROW_NUMBER() OVER (ORDER BY [id]) AS E_NEW
					FROM ctl_import where idpfu = @IdUser
				  ) x inner join ctl_import D on x.id=D.id

			

		---------INIZIO RECUPERO ALLEGATO LOTTI GARE INFORMALI
		--VEDIAMO SE E' UNA GARA INFORMALE		
		IF EXISTS ( select id 
							from ctl_doc with(nolock) 
								inner join document_bando with(nolock) on idHeader=LinkedDoc and ProceduraGara in ('15583','15479')
						where  id=@idDoc  --idpda
					)
		BEGIN
			--AGGIUNGO ALLEGATO DELLA BUSTA DI COMPETENZA FIRMATA
			set @strSQL='
		
				insert into 
					ctl_import
					(idpfu,A,B,C,D)
					select 
						' + cast(@IdUser as varchar(50)) + ',
						O.protocollo + ''_' + @PrefisoContesto + '_'' + AE.vatValore_FT + '' - '' + left(PO.aziRagioneSociale,5) as Cartella , 
						dbo.getpos( ' + @ColBustaFirmata + ',''*'',4) as Att_Hash,
						dbo.getpos( ' + @ColBustaFirmata + ',''*'',3) as Size,
						'''' as Esito--,
						--ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
					from 
						document_pda_offerte PO with (nolock)
							inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome =''codicefiscale''
							inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc=''OFFERTA'' and statopda not in (''99'')
							inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID =''OFFERTA_BUSTA_ECO'' and OL.DZT_Name =''LettaBusta'' and OL.value=''1''
							inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 
					where 
						PO.idheader = ' + cast(@idDoc as varchar(50)) + ' order by O.Protocollo asc '
			

			
		
			exec ( @strSQL )
		
			--valorizzo la colonna E in modo crescente
			UPDATE  D
				SET D.E = x.E_NEW
				FROM (
					  SELECT ID, ROW_NUMBER() OVER (ORDER BY [id]) AS E_NEW
						FROM ctl_import where idpfu = @IdUser
					  ) x inner join ctl_import D on x.id=D.id

			
		---------FINE RECUPERO ALLEGATO LOTTI GARE INFORMALI		
		END
	end 


	--RECUPERO HASH ALLEGATI DELLA BUSTA TECNICA DI TUTTE LE RISPOSTE
	if @Contesto ='TECNICA_CONCORSO' 
	begin

		DECLARE crsAttach CURSOR STATIC FOR 
			
			select 
				OA.idHeader, OA.Allegato
			from 
				document_pda_offerte PO with (nolock)
					inner join ctl_doc_value OL with (nolock) on OL.IdHeader = PO.idmsg and OL.DSE_ID ='BUSTA_TECNICA' and OL.DZT_Name ='LettaBusta' and OL.value='1'
					inner join ctl_doc_allegati OA with (nolock) on OA.idHeader = PO.idmsg and ISNULL( OA.Allegato , '' ) <> '' and OA.DSE_ID = 'DOCUMENTAZIONE_RICHIESTA_TECNICA'
			where 
				PO.idheader = @idDoc


		OPEN crsAttach

		FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			insert into @ListAttach
					(idheader,Allegato)
				select @Idheader , *
					 from split(@AllegatoMulti,'***')

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
		END

		CLOSE crsAttach 
		DEALLOCATE crsAttach 



		insert into 
			ctl_import
			(idpfu,A,B,C,D,E)
		select 
			@IdUser,
			--O.protocollo + '_BT_' + AE.vatValore_FT + ' - ' + left(PO.aziRagioneSociale,5) as Cartella , 
			case
				when isnull(AN.Value,'0') = '1'
					then O.protocollo + '_BT_' + AE.vatValore_FT + ' - ' + left(PO.aziRagioneSociale,5) 
				else O.Titolo +'_BT'
					
				end as Cartella , 
			dbo.getpos( OA.Allegato,'*',4) as Att_Hash,
			dbo.getpos( OA.Allegato,'*',3) as Size,
			'' as Esito,
			ROW_NUMBER() OVER(ORDER BY O.Protocollo  ASC) as CurrentElement
			from 
				document_pda_offerte PO with (nolock)
					inner join dm_attributi AE with (nolock) on AE.lnk=PO.idAziPartecipante and idApp = 1 and AE.dztNome ='codicefiscale'
					inner join ctl_doc O with (nolock)on PO.IdMsg=id and O.tipodoc in ('RISPOSTA_CONCORSO') and statopda not in ('99')
					inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='BUSTA_TECNICA' and OL.DZT_Name ='LettaBusta' and OL.value='1'
					left join ctl_doc_value AN with (nolock) on O.id = AN.IdHeader and AN.DSE_ID = 'ANONIMATO' and AN.DZT_NAME = 'DATI_IN_CHIARO'
					--inner join ctl_doc_allegati OA with (nolock) on OA.idHeader = O.id and ISNULL( OA.Allegato , '' ) <> '' 
					inner join @ListAttach OA on OA.idHeader = O.id --and ISNULL( OA.Allegato , '' ) <> ''  
					--inner join ctl_attach ATT with (nolock) on ATT.ATT_Hash = dbo.getpos( OA.Allegato,'*',4)
			where 
				PO.idheader = @idDoc
				order by O.Protocollo asc
			
	end  

	-- tolgo eventuali spazi in coda al nome della cartella per evitare problemi con windows
	update CTL_Import set A = rtrim(LTRIM( A ) ) , B =  rtrim(LTRIM( B ) )  where idPfu = @IdUser

	--aggiorno per ogni allegato info se cifrato oppure no nella colonna F
	update AU
		set AU.F = Att.Att_Cifrato
			from 
				CTL_Import AU
					inner join	CTL_Attach Att with (nolock) on AU.B = Att.ATT_Hash 
			where AU.idpfu = @IdUser


END
GO
