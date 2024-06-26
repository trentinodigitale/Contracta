USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GENERA_MODELLO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD2_GENERA_MODELLO_PROGRAMMAZIONE] 
		 (
			 @idDoc int, @IdUser as int
		 )
AS
BEGIN

	


	declare @idmod_copia int
	declare @IdNewDoc int
	declare @titolo_doc as varchar(250)
	declare @tipodoc as varchar(250)
	declare @linkeddoc as int
	declare @ModelloTipoBando varchar(500)
	declare @TipoBandoScelta varchar(500)


	--set @iddoc = <ID_DOC>
	--set @IdPfu = <ID_USER>

	set @TipoBandoScelta=''
	set @idmod_copia=0

	select @tipodoc=tipodoc,@linkeddoc=LinkedDoc from ctl_doc where id=@iddoc


	IF @tipodoc = 'BANDO_PROGRAMMAZIONE'
	BEGIN
		select @TipoBandoScelta=value 
			from ctl_doc_value with (nolock)
			where idheader=@iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBandoSceltaProgrammazione'
	END


	--cancello un precedente documento se esiste
	IF EXISTS (Select * from ctl_doc with (nolock) where tipodoc like 'CONFIG_MODELLI%' and linkedDoc=@iddoc and deleted=0)
	BEGIN

		declare @id_del as int
		declare @mod_del as varchar(100)	
	
		Select @id_del=id, @mod_del=Titolo from ctl_doc with (nolock) where tipodoc like 'CONFIG_MODELLI%' and linkedDoc=@idDoc and deleted=0
	
		delete from ctl_doc_value where IdHeader=@id_del
		delete from ctl_doc where id=@id_del
		--delete from Document_Vincoli where IdHeader=@id_del

		--inizano tutti così per i fabbisogni
		--in questo modo nelle delete che seguono applico solo like a destra e sfrutta l'indice
		set @mod_del = 'MODELLO_BASE_PROGRAMMAZIONE_' + @mod_del 

		--delete from CTL_Models where  mod_name like  @mod_del +'%'
		--delete from CTL_ModelAttributes where MA_MOD_ID like  @mod_del +'%'
		--delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID like  @mod_del +'%'
		select MOD_Name into #tmp_del_mod from  CTL_Models with(INDEX(IX_CTL_Models_Mod_Name)nolock)  where MOD_Name like @mod_del +'%'
		delete from CTL_Models where MOD_Name in (select MOD_Name from #tmp_del_mod)
		delete from CTL_ModelAttributes where MA_MOD_ID in (select MOD_Name from #tmp_del_mod)
		delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID in (select MOD_Name from #tmp_del_mod)
		drop table #tmp_del_mod
    
	

	END

	IF @tipodoc='BANDO_PROGRAMMAZIONE'
	BEGIN
		select @idmod_copia=C.Id,@titolo_doc=C.titolo
			from ctl_doc C with (nolock)
			--where C.titolo=@TipoBandoScelta and c.tipodoc='CONFIG_MODELLI_FABBISOGNI' and C.StatoFunzionale='Pubblicato' and  C.deleted=0  and JumpCheck='FABBISOGNI'
			where c.tipodoc = 'CONFIG_MODELLI_FABBISOGNI' and C.titolo=@TipoBandoScelta and C.deleted=0 and C.StatoFunzionale='Pubblicato' and JumpCheck='PROGRAMMAZIONE'
	END


	if @idmod_copia > 0 
	BEGIN
	--genero il record nella ctl_doc
		insert into ctl_doc (idpfu,titolo,LinkedDoc)
			select 
				@IdUser, titolo + '_' + cast(@idDoc as varchar(10)), @idDoc
				from 
					CTL_DOC with (nolock)
				where id=@idmod_copia

		set @IdNewDoc = SCOPE_IDENTITY() 	
	
		select @ModelloTipoBando = titolo from ctl_doc where id = @IdNewDoc 

		exec COPY_RECORD  'CTL_DOC'  , @idmod_copia  , @IdNewDoc , ',Id,idpfu,titolo,linkedDoc,Statodoc,Statofunzionale,protocollo,DataInvio,Data'
	
	--copio i record nella ctl_doc_value
		insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value)
			select @IdNewDoc, DSE_ID, Row, DZT_Name, Value
				from CTL_DOC_VALUE with (nolock)
				where idheader=@idmod_copia
				--order by IdRow

		--copio i record nella CTL_DOC_SECTION_MODEL
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
			select @IdNewDoc, DSE_ID, MOD_Name
				from CTL_DOC_SECTION_MODEL with (nolock)
				where IdHeader=@idmod_copia
	END

	if @TipoBandoScelta <> ''
	BEGIN
		
		update Document_Bando set TipoBando = @ModelloTipoBando where idHeader=@idDoc		

		update CTL_DOC_Value 
			set value=@TipoBandoScelta + '_' + cast(@idDoc as varchar(10)) 
			where dse_id='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione' and idHeader=@idDoc


		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'
	
		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','id_modello',@IdNewDoc)

		insert into CTL_DOC_SECTION_MODEL (Idheader,DSE_ID,MOD_NAME)
			Values(@IdNewDoc,'TESTATA','CONFIG_MODELLI_PROGRAMMAZIONE_TESTATA_GARA')



	END
	ELSE
	BEGIN
		delete from CTL_DOC_Value where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'
	
		Insert into ctl_doc_value(idheader,DSE_ID,DZT_Name,value)
			values (@idDoc,'TESTATA_PRODOTTI','id_modello','')
	
		update Document_Bando set TipoBando = ''where idHeader=@idDoc
	
	 
		update CTL_DOC_Value 
				set value='' 
			 where dse_id='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione' and idHeader=@idDoc
	

	END

END
GO
