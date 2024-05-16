USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TEMPLATE_REQUEST_COMMAND]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  proc [dbo].[OLD2_TEMPLATE_REQUEST_COMMAND] ( @idDoc  int , @Comando varchar(1000) , @Modulo varchar(1000), @Gruppo varchar(1000), @Indice int)
as

begin 
	set nocount on

	--declare @idDoc				int
	declare @Statofunzionale	varchar(1000)
	--declare @Comando			varchar(1000)
	--declare @Modulo				varchar(1000)
	--declare @Gruppo				varchar(1000)
	--declare @Indice				varchar(1000)
	declare @Note				varchar(max)
	declare @NRow				int
	declare @idTemplate			int
	declare @Scroll				varchar(1000)
	declare @Modello_Modulo		as varchar (500)
	
	set @Modello_Modulo = ''


	--set @idDoc = <ID_DOC>

	select @Statofunzionale = statofunzionale , @Note = Note , @idTemplate = LinkedDoc from ctl_doc where id = @idDoc -- and statofunzionale = 'InLavorazione' 




	if @Comando = 'REMOVE_MEM_TEMPLATE'
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idDoc as varchar )

	

	-- se il documento è in lavorazione possono essere eseguiti i comandi
	if @statofunzionale = 'InLavorazione' and @Comando <> 'REMOVE_MEM_TEMPLATE'
	begin
	
		--set @Comando	= dbo.GetPos( @Note , '@@@' , 1 )
		--set @Modulo		= dbo.GetPos( @Note , '@@@' , 2 )
		--set @Gruppo		= dbo.GetPos( @Note , '@@@' , 3 )
		--set @Indice		= dbo.GetPos( @Note , '@@@' , 4 )
		--set @Scroll		= dbo.GetPos( @Note , '@@@' , 5 )


		select @NRow = value from CTL_DOC_Value where idheader = @idDoc and DZT_Name = @Modulo + '@@@' + @Gruppo and DSE_ID = 'ITERAZIONI' and row = 0
	
		set @NRow = isnull( @NRow , 1 ) 
		if @NRow <= 0
			set @NRow = 1

		-- aggiunge o sottrae all'area iterabile
		if @Comando = 'ADDITEM'
			set @NRow = @NRow + 1

		if @Comando = 'DELITEM'
			set @NRow = @NRow - 1

		if @NRow <= 0
			set @NRow = 1

		if exists( select  value from CTL_DOC_Value where idheader = @idDoc and DZT_Name = @Modulo + '@@@' + @Gruppo and DSE_ID = 'ITERAZIONI' and row = 0 )
			update CTL_DOC_Value set value = @NRow where idheader = @idDoc and DZT_Name = @Modulo + '@@@' + @Gruppo and DSE_ID = 'ITERAZIONI' and row = 0
		else
			insert into CTL_DOC_Value ( idheader , DSE_ID , Row , DZT_Name , Value ) values ( @idDoc , 'ITERAZIONI' , 0 , @Modulo + '@@@' + @Gruppo , @NRow )

		-- azzero il comando eseguito lascio lo scroll
		--update ctl_doc set Note = @Scroll where id = @idDoc

		---------------------------------------------------
		-- rigenero il modello per la visualizzazione considerando le specializzazioni
		---------------------------------------------------
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idDoc as varchar )


		---- se il @idTemplate è un documento template va bene altrimenti occorre prendere il template collegato a quel documento
		--if not exists( select id from ctl_doc where id = @idTemplate and tipodoc = 'TEMPLATE_REQUEST' )
		--begin
			
		--	select @idTemplate = id from ctl_doc where linkeddoc = @idTemplate and tipodoc = 'TEMPLATE_CONTEST' and deleted = 0 
		--	-- se il documento recupoerato è un template ok altrimenti lo ricavo partendo dall'istanza
		--	if not exists( select id from ctl_doc where id = @idTemplate and tipodoc = 'TEMPLATE_CONTEST' and deleted = 0  )
		--	begin
		--		select @idTemplate = t.id 
		--			from ctl_doc M
		--				inner join CTL_DOC I on m.LinkedDoc = I.id
		--				inner join ctl_doc t on I.linkeddoc = t.LinkedDoc and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 
		--			where M.id = @idDoc
		--	end

		--end

		--associo il modello per la compilazione del modulo 
		delete from CTL_DOC_SECTION_MODEL where IdHeader = @idDoc and DSE_ID in ( 'MODULO','MODULO_SAVE' )
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @idDoc  , 'MODULO' , @Modello_Modulo )
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @idDoc  , 'MODULO_SAVE' , @Modello_Modulo )

		delete from CTL_Models where [MOD_ID] = @Modello_Modulo
		delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo
		delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo


		--exec MAKE_MODULO_TEMPLATE_REQUEST @idTemplate , @Modello_Modulo , @idDoc
		exec MAKE_MODULO_TEMPLATE_REQUEST 0 , @Modello_Modulo , @idDoc


		---------------------------------------------------
		-- Sposto i valori in basso o in alto dipendente dal comando
		---------------------------------------------------
		-------------------------------------------
		-- per ogni gruppo  iterabile 
		-------------------------------------------
		--declare CurModuloRequest Cursor LOCAL static for 
		--	select upper(  replace( k.value , '.' , '_' ) ) as KeyRiga ,   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) as DZT_Name ,ItemPath

		--		from CTL_DOC_Value t with(nolock)
		--			inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
		--			inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
		--			inner join CTL_DOC M  with(nolock) on M.TipoDoc = 'TEMPLATE_REQUEST_GROUP' and replace( cast( m.numerodocumento as varchar(500)) , '-' , '_' ) = a.Value --TEMPLATE_REQUEST_GROUP
		--			inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.id and Iterabile = 1
		--		where t.idHeader=@idDoc and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' 

		--open CurModuloRequest

		-------------------------------------------
		-- ciclo per il numero di occorrenze, recuperato dal documento per generare gli attributi
		-------------------------------------------

		-- il codice sottostante è solo di esempio

		--FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath
		--WHILE @@FETCH_STATUS = 0
		--BEGIN
		--	select @NRow = value from CTL_DOC_Value where idheader = @idDocInUse and DZT_Name = @KeyRiga + '@@@' + @ItemPath and DSE_ID = 'ITERAZIONI'		
		--	if isnull( @NRow , 0 ) = 0 
		--		set @NRow = 1

		--	set @ix = 0 
		--	while @ix < @NRow
		--	begin
			
		--		-- genera le istanze per gli attributi 
		--		insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		--			select MA_MOD_ID, 
						
		--					'MOD_' + @KeyRiga  + '_FLD_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_' , 2) as MA_DZT_Name, 
						
		--					MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
		--				from CTL_ModelAttributes
		--				where MA_MOD_ID = @Modello_Modulo 
		--					and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_' +  @RG_FLD_TYPE + '%'
		--					and MA_DZT_Name not like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


		--		-- genera le istanze per i domini currency
		--		insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		--			select MA_MOD_ID, 
						
		--					'MOD_' + @KeyRiga  + '_FLD_CUR_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_CUR_' , 2) as MA_DZT_Name, 
						
		--					MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
		--				from CTL_ModelAttributes
		--				where MA_MOD_ID = @Modello_Modulo 
		--					and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


		--		set @ix = @ix +1
		--	end



		--	FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath
		--END 
		--CLOSE CurModuloRequest
		--DEALLOCATE CurModuloRequest


	end

	
	select 	@Modello_Modulo as Modello

end






GO
