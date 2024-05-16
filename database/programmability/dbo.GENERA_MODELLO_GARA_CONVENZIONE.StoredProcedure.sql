USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GENERA_MODELLO_GARA_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[GENERA_MODELLO_GARA_CONVENZIONE] 
		 (
			 @idDoc int, @IdUser as int
		 )
AS
BEGIN

	--declare @idDoc int
	declare @idmod_copia int
	declare @IdNewDoc int
	declare @titolo_doc as varchar(250)
	declare @tipodoc as varchar(250)
	declare @linkeddoc as int
	declare @ModelloTipoBando varchar(500)
	--declare @IdUser as int

	declare @TipoBandoScelta varchar(500)

	--set @iddoc = <ID_DOC>

	--set @IdUser = <ID_USER>

	set @TipoBandoScelta=''
	set @idmod_copia=0

	select @tipodoc=tipodoc,@linkeddoc=LinkedDoc from ctl_doc where id=@iddoc

	IF @tipodoc = 'CONVENZIONE'
	BEGIN
		select @TipoBandoScelta=value 
			from ctl_doc_value  with (nolock)
			where idheader=@iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione_Scelta'
	END
	ELSE
	BEGIN
		select @TipoBandoScelta=value 
		from ctl_doc_value   with (nolock)
			where idheader=@iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBandoScelta'
	END




	--cancello un precedente documento se esiste
	IF EXISTS (Select * from ctl_doc  with (nolock) where tipodoc like 'CONFIG_MODELLI%' and linkedDoc=@idDoc and deleted=0)
	BEGIN


		declare @id_del as int
		declare @mod_del as varchar(100)	
		Select @id_del=id, @mod_del=Titolo from ctl_doc  with (nolock) where tipodoc like 'CONFIG_MODELLI%' and linkedDoc=@idDoc 

		--cancello le entrate relative al modello
		delete DOMINIO_AttributoCriterio where TipoBando like @mod_del + '%'

		--aggiunta dse_id per evitare di cancellare cose non dei modelli ma di documenti imperniati sulla document_microlotti_dettagli
		delete from ctl_doc_value where IdHeader=@id_del and DSE_ID in ( select dse_id from LIB_DocumentSections with (nolock) where DSE_DOC_ID in ( 'config_modelli' , 'config_modelli_lotti' ) )
		delete from ctl_doc where id=@id_del
		delete from Document_Vincoli where IdHeader=@id_del

		delete from document_modelli_microlotti where codice  like '%' + @mod_del +'%'
		delete from Document_Modelli_MicroLotti_Formula where codice  like '%' + @mod_del +'%'

		--per velocizzare le cancellazioni che venivano fatte con like '%'+ @mod_del + '%' e non sfruttavano l'indice
		IF @tipodoc = 'CONVENZIONE'
		BEGIN
			set @mod_del = 'MODELLO_BASE_CONVENZIONI_' + @mod_del 
		end
		else
		begin
			set @mod_del = 'MODELLI_LOTTI_' + @mod_del 
		end

		--delete from CTL_Models where  mod_name like @mod_del +'%'
		--delete from CTL_ModelAttributes where MA_MOD_ID like @mod_del +'%'
		--delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID like @mod_del +'%'
		select MOD_Name into #tmp_del_mod from  CTL_Models with(INDEX(IX_CTL_Models_Mod_Name)nolock)  where MOD_Name like @mod_del +'%'
		delete from CTL_Models where MOD_Name in (select MOD_Name from #tmp_del_mod)
		delete from CTL_ModelAttributes where MA_MOD_ID in (select MOD_Name from #tmp_del_mod)
		delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID in (select MOD_Name from #tmp_del_mod)
		drop table #tmp_del_mod

	END

	IF @tipodoc='CONVENZIONE'
	BEGIN
		select @idmod_copia=C.Id,@titolo_doc=C.titolo
			from ctl_doc C  with (nolock)
			where tipodoc like 'CONFIG_MODELLI%' and C.titolo=@TipoBandoScelta and C.deleted=0 and C.StatoFunzionale='Pubblicato' and JumpCheck='CONVENZIONI'
	END
	ELSE
	BEGIN
		select @idmod_copia=C.Id,@titolo_doc=C.titolo
			from Document_Modelli_MicroLotti D  with (nolock)
				inner join ctl_doc C  with (nolock) on C.id=D.LinkedDoc
			where D.Codice=@TipoBandoScelta and D.deleted=0
	END

	--if @tipodoc='BANDO_SEMPLIFICATO'
	--BEGIN
	--	select @idmod_copia=C.Id,@titolo_doc=C.titolo
	--	from Document_Modelli_MicroLotti D
	--	inner join ctl_doc C on C.id=D.LinkedDoc
	--	where D.Codice=@TipoBandoScelta+ '_' + cast( @linkeddoc as varchar(50)) and D.deleted=0
	--END

	if @idmod_copia > 0 
	BEGIN
		--genero il record nella ctl_doc
		insert into ctl_doc (idPfuInCharge, idpfu,titolo,LinkedDoc)
			select @IdUser,@IdUser,titolo + '_' + cast(@idDoc as varchar(10)),@idDoc
				from CTL_DOC with (nolock)
				where id=@idmod_copia

				
		set @IdNewDoc = SCOPE_IDENTITY() 
	
		select @ModelloTipoBando = titolo from ctl_doc where id = @IdNewDoc 

		exec COPY_RECORD  'CTL_DOC'  , @idmod_copia  , @IdNewDoc , ',idPfuInCharge,Id,idpfu,titolo,linkedDoc,Statodoc,Statofunzionale,protocollo,DataInvio,Data'
	
		--copio i record nella ctl_doc_value
		insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value)
			select @IdNewDoc, DSE_ID, Row, DZT_Name, Value
				from CTL_DOC_VALUE with (nolock)
				where idheader=@idmod_copia
				order by idrow

		--copio i record nella Document_vincoli
		insert into Document_Vincoli ( IdHeader, Espressione, Descrizione, EsitoRiga, Seleziona,[contesto_vincoli])
			select @IdNewDoc,Espressione, Descrizione, EsitoRiga, Seleziona,[contesto_vincoli]
				from Document_Vincoli  with (nolock)
				where IdHeader=@idmod_copia
				order by IdRow

		--copio i record nella CTL_DOC_SECTION_MODEL
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
			select @IdNewDoc, CM.DSE_ID, MOD_Name
				from CTL_DOC_SECTION_MODEL CM with(nolock)
				inner join CTL_DOC C with(nolock) ON C.Id=@idmod_copia
				inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=C.TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
			where IdHeader = @idmod_copia and CM.DSE_ID=LIB_DocumentSections.DSE_ID
	END

	if @TipoBandoScelta <> ''
	BEGIN
	
		if @tipodoc <> 'CONVENZIONE'
		BEGIN
			update Document_Bando set TipoBando = case 
													when CHARINDEX('_MONOLOTTO',@TipoBandoScelta) > 0 then @titolo_doc  + '_' + cast(@idDoc as varchar(10)) + '_MONOLOTTO' 
													when CHARINDEX('_COMPLEX',@TipoBandoScelta) > 0 then @titolo_doc  + '_' + cast(@idDoc as varchar(10)) + '_COMPLEX' 
													else @TipoBandoScelta + '_' + cast(@idDoc as varchar(10)) 
											end
			where idHeader=@idDoc


			--if @tipodoc = 'BANDO_SEMPLIFICATO' 
			--begin
			--	update Document_Bando set TipoBando = @ModelloTipoBando where idHeader=@idDoc
			--	update ctl_doc set statofunzionale = 'InLavorazione' where id = @idDoc
			--end

		END
		
		if @tipodoc = 'CONVENZIONE'
		BEGIN
			update CTL_DOC_Value set value=@TipoBandoScelta + '_' + cast(@idDoc as varchar(10)) 
				where dse_id='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione' and idHeader=@idDoc
		END

		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'

		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','id_modello',@IdNewDoc)

		--inizio controllo se il modello ha un ampiezza di gamma 
		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='PresenzaAmpiezzaDiGamma'
		
		declare @PresenzaAmpiezzaDiGamma varchar(2)

		if not exists(select top 1 * from ctl_doc_value with(nolock) where IdHeader = @IdNewDoc and DSE_ID = 'AMBITO' and DZT_Name = 'PresenzaAmpiezzaDiGamma')
			begin 
				set @PresenzaAmpiezzaDiGamma = 'no'
			end
		else
			begin 
				select @PresenzaAmpiezzaDiGamma = isnull(value, 'no') from ctl_doc_value with(nolock) where IdHeader = @IdNewDoc and DSE_ID = 'AMBITO' and DZT_Name = 'PresenzaAmpiezzaDiGamma'
				
				if @PresenzaAmpiezzaDiGamma = ''
					begin
						set @PresenzaAmpiezzaDiGamma = 'no'
					end
			end

		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','PresenzaAmpiezzaDiGamma',@PresenzaAmpiezzaDiGamma)
		--fine controllo se il modello ha un ampiezza di gamma 	

		-- gestione per il caso di IMPRESA
		if exists(select * from marketplace where mpLog = 'IM') and
			not exists(select * from marketplace where mpLog = 'PA')
		begin
			insert into CTL_DOC_SECTION_MODEL (Idheader,DSE_ID,MOD_NAME)
				Values(@IdNewDoc,'TESTATA','CONFIG_MODELLI_LOTTI_TESTATA_GARA_IM')
		end
		
		else		-- comportamento vecchio di default
		begin
			insert into CTL_DOC_SECTION_MODEL (Idheader,DSE_ID,MOD_NAME)
				Values(@IdNewDoc,'TESTATA','CONFIG_MODELLI_LOTTI_TESTATA_GARA')
		end

	END
	ELSE
	BEGIN

		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'
	
		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','id_modello','')

		--controllo se il modello ha un ampiezza di gamma 
		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='PresenzaAmpiezzaDiGamma'
		
		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','PresenzaAmpiezzaDiGamma','no')

		if @tipodoc <> 'CONVENZIONE'
		BEGIN
			update Document_Bando set TipoBando = ''
				where idHeader=@idDoc
		END

		if @tipodoc = 'CONVENZIONE'
		BEGIN
			update CTL_DOC_Value set value='' 
				where dse_id='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione'
					and idHeader=@idDoc
		END

	END

END
GO
