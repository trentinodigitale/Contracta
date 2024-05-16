USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA] (@IdDocFascicolo as int ,  @idDoc int, @Contesto varchar(500)  )
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
		idRow int,
		DSE_id varchar(100),
		Allegato  nvarchar(max),
		Hash_Source  nvarchar(255)
	)

	--RECUPERO HASH ALLEGATI DELLA BUSTA AMMINISTRATIVA DI TUTTE LE OFFERTE
	if @Contesto ='BUSTA_AMMINISTRATIVA' 
	begin
		--metto in una temp gli allegati, che possono essre multipli, della busta documentazione
		--applicando la split sul valore con il separatore *** degli n valori 

		DECLARE crsAttach CURSOR STATIC FOR 
			
				select 
						OA.idrow, OA.Allegato
					from 
						CTL_DOC_ALLEGATI OA with(nolock)	
					where idHeader=@idDoc and ISNULL(Allegato,'')<> ''

			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
			insert into @ListAttach
					(idRow,DSE_id,Allegato,Hash_Source)
				select @Idheader ,'DOCUMENTAZIONE', items , dbo.GetPos ( items, '*', 4)  as Hash_Source
						from split(@AllegatoMulti,'***')

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti
			END

		CLOSE crsAttach 
		DEALLOCATE crsAttach 


		--AGGIUNGIAMO allegato DGUE MNADATARIA se presente
		insert into @ListAttach
					(idRow,DSE_id,Allegato,Hash_Source)
			select 
				@Idheader ,'DGUE', value , dbo.GetPos ( value, '*', 4)  as Hash_Source
				from 
					OFFERTA_VIEW_DGUE
				where idheader=@idDoc and dzt_name='Allegato' and value <>''
		
		--AGGIUNGIAMO ALLEGATI DEI PARTECIPANTI
		insert into @ListAttach
					(idRow,DSE_id,Allegato,Hash_Source)
			select 
				@Idheader , 'DGUE_' + TipoRiferimento , allegatodgue , dbo.GetPos ( allegatodgue, '*', 4)  as Hash_Source
				from 
					Document_Offerta_Partecipanti with (nolock)
				where 
					idheader=@idDoc and allegatodgue<>''

		--AGGIUNGIAMO allegato QUESTIONARIO AMMINISTRATIVO se presente
		insert into @ListAttach
					(idRow,DSE_id,Allegato,Hash_Source)
			select 
				@Idheader ,'QUESTIONARIO', value , dbo.GetPos ( value, '*', 4)  as Hash_Source
				from 
					OFFERTA_VIEW_QUESTIONARIO 
				where idheader=@idDoc and dzt_name='AllegatoQuestionario' and value <>''
		
		--AGGIUNGIAMO ALLEGATI PARAEMTRI ALL'INTERNO DEL MODULO QUESTIONARIO AMMINISTRATIVO
		insert into @ListAttach
					(idRow,DSE_id,Allegato,Hash_Source)
			select 
				@Idheader ,'QUESTIONARIO', ma.value , dbo.GetPos ( ma.value, '*', 4)  as Hash_Source
				from 
					Ctl_doc M with(nolock) 
						inner join CTL_DOC_SECTION_MODEL MO with(nolock) on MO.IdHeader = M.id  and MO.DSE_ID='MODULO'
						inner join CTL_ModelAttributes MOA with(nolock) on MOA.MA_MOD_ID = MO.MOD_Name and MOA.DZT_Type=18
						inner join ctl_doc_value MA with(nolock) on MA.IdHeader = M.id and ma.DZT_Name = MOA.MA_DZT_Name and ma.value <>''

				where linkeddoc=@idDoc   and M.tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and isnull(m.SIGN_ATTACH,'')<>''


		--AGGIUNGIAMO GLI ALLEGATI ALLA TABELLA DEL FASCICOLO DEGLI ALLEGATI	
		insert into document_Fascicolo_Gara_Allegati
			(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [Encrypted]  ) 
			
		select 
				@IdDocFascicolo , Allegato, @IdDoc, DSE_ID, '' AS [Esito] , 0  AS [NumRetry], case 
																									when isnull(att_cifrato,0) <> 0 then 1
																									else 0
																							   end as [Encrypted]
				from 
					@ListAttach
						inner join ctl_attach with (nolock) on att_hash = Hash_Source
							

		


		--RECUPERO allegato DGUE MNADATARIA se presente
		--insert into document_Fascicolo_Gara_Allegati
		--		(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [Encrypted] ) 
			
		--	select 
		--		@IdDocFascicolo , value, @IdDoc, 'DGUE' as [DSE_ID], '' AS [Esito] , 0  AS [NumRetry], case 
		--																									when isnull(att_cifrato,0) <> 0 then 1
		--																									else 0
		--																								end as [Encrypted]
		--		from 
		--			OFFERTA_VIEW_DGUE
		--				inner join ctl_attach with (nolock) on att_hash = dbo.GetPos ( value, '*', 4) 
		--		where 
		--			idheader=@idDoc and dzt_name='Allegato' and value <>''
		
		

		--RECUPERO allegato DGUE PARTECIPANTI se presenti
		--insert into document_Fascicolo_Gara_Allegati
		--		(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry],  [Encrypted] ) 
			
		--	select 
		--		@IdDocFascicolo , allegatodgue , @IdDoc, 'DGUE_' + TipoRiferimento  as [DSE_ID], '' AS [Esito] , 0  AS [NumRetry], case 
		--																																when isnull(att_cifrato,0) <> 0 then 1
		--																																else 0
		--																															end as [Encrypted]
		--		from 
		--			Document_Offerta_Partecipanti with (nolock)
		--				inner join ctl_attach with (nolock) on att_hash = dbo.GetPos ( allegatodgue, '*', 4) 
		--		where 
		--			idheader=@idDoc and allegatodgue<>''

	
			
	end  

	
	--RECUPERO ID GARA 
	select @IdGara= linkeddoc from ctl_doc with (nolock) where id = @idDoc


	--RECUPERO HASH ALLEGATI DELLA BUSTA TECNICA DI TUTTE LE OFFERTE
	if @Contesto  in ('TECNICA_MONOLOTTO','ECONOMICA_MONOLOTTO')
	begin
		

		set @dse_id='BUSTA_TECNICA'
		--set @PrefisoContesto= 'BT'
		set @ColBustaFirmata = 'F3_SIGN_ATTACH'
		if @Contesto = 'ECONOMICA_MONOLOTTO'
		begin
			set @dse_id='BUSTA_ECONOMICA'
			--set @PrefisoContesto ='BE'
			set @ColBustaFirmata = 'F1_SIGN_ATTACH'
		end

		--RECUPERO NOME MODELLO BUSTA TECNICA/BUSTA ECONOMICA dalla ctl_doc_sectionmodel della gara
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
					inner join LIB_Dictionary L with (nolock) on MA_DZT_Name = dzt_name and L.DZT_Type  = 18 --dzt_type degli attributi attach
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
					idRow int,
					NumeroRiga int,
					Allegato  nvarchar(max),
					Hash_Source  nvarchar(255)

				)

			--metto in una temp gli allegati, che possono essre multipli
			--applicando la split sul valore con il separatore *** degli n valori 
			DECLARE crsAttach CURSOR STATIC FOR 
				
				select 
					DO.idHeader, ' + @AttribAttach + ' as Allegato, NumeroRiga
				from 
					
					ctl_doc O with (nolock) 
						--inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1''
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc 
						
					where 
						O.id = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @AttribAttach + ' , '''' )  <> '''' 
				
			
			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroRiga
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				
				insert into @ListAttach
					(idRow,Allegato,Hash_Source)
				select @Idheader , items , dbo.GetPos ( items, ''*'', 4)  as Hash_Source
						from split(@AllegatoMulti,''***'')

				FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroRiga
			END

			CLOSE crsAttach 
			DEALLOCATE crsAttach 
		

			insert into document_Fascicolo_Gara_Allegati
				(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry],  [Encrypted] ) 
			
				select 
					' + cast(@IdDocFascicolo as varchar(50))   + ', Allegato ,' + cast(@idDoc as varchar(50)) + ', ''' + @dse_id + ''' as [DSE_ID], '''' AS [Esito] , 0  AS [NumRetry] ,  case 
																																															when isnull(att_cifrato,0) <> 0 then 1
																																															else 0
																																														end as [Encrypted]
					from 
						--split(@AllegatoMulti,''***'')
						@ListAttach
							inner join ctl_attach with (nolock) on att_hash = Hash_Source -- dbo.GetPos ( items, ''*'', 4) 

				'
			--print ( @strSQL )
			exec ( @strSQL )

			

		FETCH NEXT FROM crsAttrib INTO @AttribAttach
		END

		CLOSE crsAttrib 
		DEALLOCATE crsAttrib 

		--cancello la tabella temporanea
		drop table #colAttach

		
		--AGGIUNGO ALLEGATO DELLA BUSTA DI COMPETENZA FIRMATA
		set @strSQL='
			

			DECLARE @ListAttach1 TABLE
			(
					idRow int,
					Allegato  nvarchar(max),
					Hash_Source  nvarchar(255)

			)

			insert into @ListAttach1
					(idRow,Allegato,Hash_Source)
			select 
				idrow ,  ' + @ColBustaFirmata + ' , dbo.GetPos (  ' + @ColBustaFirmata + ' , ''*'', 4)  as Hash_Source
				from 
					ctl_doc O with (nolock)
							inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 

				where
					O.id = ' + cast(@idDoc as varchar(50))  + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> ''''

					

			insert into document_Fascicolo_Gara_Allegati
					(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [AreaDiAppartenenza] ,  [Encrypted] ) 
				select 
					
					' + cast(@IdDocFascicolo as varchar(50))   + ', Allegato ,' + cast(@idDoc as varchar(50)) + ', ''' + @dse_id + ''' as [DSE_ID], '''' AS [Esito] , 
																												0  AS [NumRetry], '''' as [AreaDiAppartenenza], 
																												case when isnull(att_cifrato,0) <> 0 then 1
																													else 0
																												end as [Encrypted]
					
					from 
						--ctl_doc O with (nolock)
						--	inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 
						@ListAttach1
							inner join ctl_attach with (nolock) on att_hash = Hash_Source --dbo.GetPos ( ' + @ColBustaFirmata + ', ''*'', 4) 
					--where 
					--	O.id = ' + cast(@idDoc as varchar(50))  + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> ''''' 
			
		--print ( @strSQL )
		exec ( @strSQL )
		
				
	end 


	--RECUPERO HASH ALLEGATI DELLA BUSTA TECNICA DI TUTTE LE OFFERTE
	if @Contesto  in ('TECNICA_LISTA_LOTTI','ECONOMICA_LISTA_LOTTI')
	begin
		
		set @dse_id='BUSTA_TECNICA'
		set @dse_id_Letta_busta = 'OFFERTA_BUSTA_TEC'
		--set @PrefisoContesto= 'BT'
		set @ColBustaFirmata = 'F2_SIGN_ATTACH'
		
		if @Contesto in ( 'ECONOMICA_LISTA_LOTTI')
		begin
			set @dse_id='BUSTA_ECONOMICA'
			set @dse_id_Letta_busta = 'OFFERTA_BUSTA_ECO'
			--set @PrefisoContesto ='BE'
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
			MA_DZT_Name into #colAttach1
			from 
				CTL_ModelAttributes with (nolock)
					inner join LIB_Dictionary L with (nolock) on MA_DZT_Name = dzt_name and L.DZT_Type  = 18 --dzt_type degli attributi attach
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
					idRow int,
					NumeroLotto varchar(10),
					Allegato  nvarchar(max),
					Hash_Source  nvarchar(255)
				)
			



			--metto in una temp gli allegati, che possono essre multipli
			--applicando la split sul valore con il separatore *** degli n valori 
			DECLARE crsAttach CURSOR STATIC FOR 
			
				select 
					DO.idHeader, ' + @AttribAttach + ' as Allegato, NumeroLotto
				from 
					ctl_doc O with (nolock)
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc  
						--inner join ctl_doc_value OL with (nolock) on OL.IdHeader = O.id and OL.DSE_ID ='''+ @dse_id_Letta_busta + ''' and OL.DZT_Name =''LettaBusta'' and OL.value=''1'' and OL.row = DO.id
						
					where 
						O.id = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @AttribAttach + ' , '''' )  <> '''' order by NumeroLotto asc 
			
			OPEN crsAttach

			FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti,  @NumeroLotto
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				insert into @ListAttach
					(idRow,Allegato,Hash_Source,NumeroLotto)
					select 
						@Idheader , items , dbo.GetPos ( items, ''*'', 4)  as Hash_Source , @NumeroLotto
							from split(@AllegatoMulti,''***'')

				FETCH NEXT FROM crsAttach INTO @Idheader, @AllegatoMulti, @NumeroLotto
			END

			CLOSE crsAttach 
			DEALLOCATE crsAttach 
			

			insert into document_Fascicolo_Gara_Allegati
					(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [AreaDiAppartenenza],  [Encrypted] ) 
			
					select 
						' + cast(@IdDocFascicolo as varchar(50))   + ', Allegato ,' + cast(@idDoc as varchar(50)) + ', ''' + @dse_id + ''' as [DSE_ID], '''' AS [Esito] , 0  AS [NumRetry], ''Lotto '' + NumeroLotto , case 
																																																						when isnull(att_cifrato,0) <> 0 then 1
																																																						else 0
																																																					end as [Encrypted]
				
						 from 
							--split(@AllegatoMulti,''***'')
							@ListAttach
								inner join ctl_attach with (nolock) on att_hash = Hash_Source --dbo.GetPos ( items, ''*'', 4) 

			'
			
			--print  ( @strSQL )
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
			

			DECLARE @ListAttach1 TABLE
			(
					idRow int,
					NumeroLotto varchar(100),
					Allegato  nvarchar(max),
					Hash_Source  nvarchar(255)

			)

			insert into @ListAttach1
					(idRow,NumeroLotto,Allegato,Hash_Source)
			select 
				DO.idheader , DO.NumeroLotto, ' + @ColBustaFirmata + ' , dbo.GetPos (  ' + @ColBustaFirmata + ' , ''*'', 4)  as Hash_Source
				from 
					ctl_doc O with (nolock) 
						inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc 
						inner join Document_Microlotto_Firme BF with (nolock) on BF.idheader=DO.id  

				where
					O.id = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> '''' order by NumeroLotto asc 



			insert into document_Fascicolo_Gara_Allegati
					(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [AreaDiAppartenenza],  [Encrypted]  ) 
				select 
					
					' + cast(@IdDocFascicolo as varchar(50))   + ', Allegato ,' + cast(@idDoc as varchar(50)) + ', ''' + @dse_id + ''' as [DSE_ID], '''' AS [Esito] , 0  AS [NumRetry],
																																			 ''Lotto '' + numerolotto  as [AreaDiAppartenenza], 
																																				case 
																																					when isnull(att_cifrato,0) <> 0 then 1
																																					else 0
																																				end as [Encrypted]
					
			
				from 
					--ctl_doc O with (nolock) 
					--	inner join document_microlotti_dettagli DO with (nolock) on DO.idheader=O.id and DO.tipodoc=O.tipodoc 
					--	inner join Document_Microlotto_Firme BF with (nolock) on BF.idheader=DO.id  
					 @ListAttach1
						inner join ctl_attach with (nolock) on att_hash = Hash_Source --dbo.GetPos ( ' + @ColBustaFirmata + ', ''*'', 4) 
				--where 
				--	O.id = ' + cast(@idDoc as varchar(50)) + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> '''' order by NumeroLotto asc '
			

			
		
		exec  ( @strSQL )
		--print  ( @strSQL )
		
		
		--INIZIO RECUPERO ALLEGATO LOTTI GARE INFORMALI
		--VEDIAMO SE E' UNA GARA INFORMALE		
		IF EXISTS ( select idheader from document_bando with(nolock) where idHeader=@IdGara and ProceduraGara in ('15583','15479') )
		BEGIN
			--AGGIUNGO ALLEGATO DELLA BUSTA DI COMPETENZA FIRMATA
			set @strSQL='
				

				DECLARE @ListAttach1 TABLE
			(
					idRow int,
					Allegato  nvarchar(max),
					Hash_Source  nvarchar(255)

			)


			insert into @ListAttach1
					(idRow,Allegato,Hash_Source)
			select 
				IdRow ,  ' + @ColBustaFirmata + ' , dbo.GetPos (  ' + @ColBustaFirmata + ' , ''*'', 4)  as Hash_Source
				from 
					ctl_doc O with (nolock)
							inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 

				where
					O.id = ' + cast(@idDoc as varchar(50))  + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> ''''
					

			insert into document_Fascicolo_Gara_Allegati
					(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry], [AreaDiAppartenenza] ,  [Encrypted] ) 
				select 
					
					' + cast(@IdDocFascicolo as varchar(50))   + ', Allegato ,' + cast(@idDoc as varchar(50)) + ', ''' + @dse_id + ''' as [DSE_ID], '''' AS [Esito] , 
																												0  AS [NumRetry], '''' as [AreaDiAppartenenza], 
																												case when isnull(att_cifrato,0) <> 0 then 1
																													else 0
																												end as [Encrypted]
					
					from 
						--ctl_doc O with (nolock)
						--	inner join ctl_doc_sign BF with (nolock) on BF.idheader=O.id 
						@ListAttach1
							inner join ctl_attach with (nolock) on att_hash = Hash_Source --dbo.GetPos ( ' + @ColBustaFirmata + ', ''*'', 4) 
					--where 
					--	O.id = ' + cast(@idDoc as varchar(50))  + ' and isnull( ' + @ColBustaFirmata + ' , '''' )  <> '''''

			
		
			exec ( @strSQL )
			-- print ( @strSQL )
			

			
		-----------FINE RECUPERO ALLEGATO LOTTI GARE INFORMALI		
		END
	end 
	

END




GO
