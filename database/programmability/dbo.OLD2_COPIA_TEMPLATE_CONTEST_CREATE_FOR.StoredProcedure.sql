USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_COPIA_TEMPLATE_CONTEST_CREATE_FOR]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  Proc [dbo].[OLD2_COPIA_TEMPLATE_CONTEST_CREATE_FOR]
	( @Iddoc int , @Id_TemplateFROM int  , @idUser int , @tipoTemplate varchar(200) )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as int
	declare @MODULO_TEMPLATE_REQUEST as int
	declare @Errore as nvarchar(2000)
	declare @IdTemplate as int
	
	set @Id = null
	set @Errore=''
	
	--CONTROLLO SE PER CASO ERA STATO CREATO GIA' IL DGUE PER IL @tipoTemplate
	
	select @id = id from ctl_doc where deleted = 0 and linkeddoc = @IdDoc and tipodoc = 'TEMPLATE_CONTEST' and jumpcheck = @tipoTemplate 
	
	--in caso lo trovo lo elimino
	
	if   isnull( @id , 0 ) > 0
	begin
		update ctl_doc set Deleted=1 where id=@id
	end
   
    --FACCIO LA COPIA TEMPLATE_CONTEST 		
	insert into CTL_DOC (IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale )
		select @idUser, IdDoc, TipoDoc, StatoDoc,  getdate() , '', PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, NULL, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, @IdDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, @tipoTemplate , 'InLavorazione', Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, @idUser, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale 
			from ctl_doc with(nolock) where id=@Id_TemplateFROM and tipodoc = 'TEMPLATE_CONTEST'

	set @IdTemplate = SCOPE_IDENTITY()

	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
		select @IdTemplate, DSE_ID, Row, DZT_Name, Value
			from CTL_DOC_Value with(nolock) where IdHeader=@Id_TemplateFROM and DSE_ID='VALORI'
	

	--FACCIO LA COPIA MODULO_TEMPLATE_REQUEST 
	select @MODULO_TEMPLATE_REQUEST=id from CTL_DOC where LinkedDoc=@Id_TemplateFROM and tipodoc = 'MODULO_TEMPLATE_REQUEST'

	insert into CTL_DOC (IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale )
		select @idUser, IdDoc, TipoDoc, StatoDoc,  getdate() , '', PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, NULL, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, @id, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, @tipoTemplate , 'InLavorazione', Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, @idUser, CanaleNotifica, URL_CLIENT, 'Modulo di esempio - ' + @tipoTemplate , FascicoloGenerale 
			from ctl_doc  with(nolock) where Id=@MODULO_TEMPLATE_REQUEST

	set @id = SCOPE_IDENTITY()

	--LEGO IL MODELLI DINAMICI AL DOCUMENTO APPENA CREATO E NE CREO UNO PER COPIA
	insert into CTL_DOC_SECTION_MODEL (IdHeader , DSE_ID , MOD_Name)
		select @id,'MODULO','MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50))

	insert into CTL_DOC_SECTION_MODEL (IdHeader , DSE_ID , MOD_Name)
		select @id,'MODULO_SAVE','MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) + '_SAVE'

	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) , 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)), 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)), MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template  
			from CTL_Models  with(nolock) where MOD_Id='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50))

	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) + '_SAVE' , 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) + '_SAVE', 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) + '_SAVE', MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template  
			from CTL_Models with(nolock) where MOD_Id='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50)) + '_SAVE'

	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module )
		select 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) , MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
			from CTL_ModelAttributes with(nolock) where MA_MOD_ID='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50))

	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module )
		select 'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) + '_SAVE' , MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
			from CTL_ModelAttributes with(nolock) where MA_MOD_ID='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50)) + '_SAVE'
	
	insert into CTL_ModelAttributeProperties (  MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50)) , MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
			from CTL_ModelAttributeProperties with(nolock) where MAP_MA_MOD_ID='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50))

	insert into CTL_ModelAttributeProperties (  MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  'MODULO_TEMPLATE_REQUEST_' + CAST(@id as varchar(50))  + '_SAVE' , MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
			from CTL_ModelAttributeProperties with(nolock) where MAP_MA_MOD_ID='MODULO_TEMPLATE_REQUEST_' + CAST(@MODULO_TEMPLATE_REQUEST as varchar(50))  + '_SAVE'

	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
		select @id, DSE_ID, Row, DZT_Name, Value
			from CTL_DOC_Value with(nolock) where IdHeader=@MODULO_TEMPLATE_REQUEST and DSE_ID='MODULO'
	
	--effettuo la chiamata per svuotare i campi della gara
	declare @Modello_Modulo as varchar(500)
	set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + CAST(@IdTemplate as varchar(50))

	exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE  @IdTemplate , @Modello_Modulo , @Id, 1
		
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	
end









GO
