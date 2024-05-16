USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_CONTEXT_GENERATE_UUID_REQUEST]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[TEMPLATE_CONTEXT_GENERATE_UUID_REQUEST] ( @idDoc int , @Modulo  varchar(20) ) as
begin

	set nocount on

	declare @id int
	declare @Row int
	declare @idTemplate int

	declare @DZT_Name nvarchar(100)
	declare @Value nvarchar(max)
	declare @EsitoRiga varchar(100)
	declare @KeyRiga varchar(100)

	-- prendo il documento collegato
	select @idTemplate = linkeddoc from ctl_doc with(nolock) where id = @idDoc 
	set @KeyRiga = ''

	-- se è un TEMPLATE_CONTEST genero gli UUID mancanti
	--if exists( select id from CTL_DOC with(nolock) where id = @idTemplate and tipodoc = 'TEMPLATE_CONTEST' )
	begin

		-- se è passato il modulo recupero la key associata per filtrare solo gli obbligatori del modulo
		if @Modulo <> '' 
		begin
			select @Row = row from ctl_doc_value with(nolock) where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name = 'idModulo' and value = @Modulo
			select @KeyRiga = 'MOD_' + replace( Value , '.','_') from ctl_doc_value with(nolock) where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name = 'KeyRiga' and Row = @Row 
		
		end


		-- metto in una tabella temporanea tutti i DZT_NAME presenti per l' ESPD_REQUEST
		select DZT_Name into #DZT from CTL_DOC_Value where idheader = @idDoc and DSE_ID = 'MODULO' and row = 0 and ( @KeyRiga = '' or DZT_Name like @KeyRiga + '%' )


		-- elimino tutti i GLI UUID non necessari
		delete from CTL_DOC_Value where idheader = @idDoc and DSE_ID = 'UUID' and row = 0 and ( @KeyRiga = '' or DZT_Name like @KeyRiga + '%' ) and DZT_NAME not in ( select DZT_Name from #DZT )


		-- genero tutti gli UUID mancanti
		insert into CTL_DOC_Value(  [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select @idDoc as [IdHeader], 'UUID' as [DSE_ID], 0 as [Row], DZT_Name, newid() as [Value]
				from #DZT 
				where DZT_Name not in ( select DZT_Name from CTL_DOC_Value where idheader = @idDoc and DSE_ID = 'UUID' and row = 0  )



	end


end


GO
