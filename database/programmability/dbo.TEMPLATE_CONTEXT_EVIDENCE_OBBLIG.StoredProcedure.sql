USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_CONTEXT_EVIDENCE_OBBLIG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[TEMPLATE_CONTEXT_EVIDENCE_OBBLIG] ( @idDoc int , @Modulo  varchar(20) ) as
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

	-- se è un TEMPLATE_CONTEST aggiorno il flag degli obbligatori
	if exists( select id from CTL_DOC with(nolock) where id = @idTemplate and tipodoc = 'TEMPLATE_CONTEST' )
	begin

		-- se è passato il modulo recupero la key associata per filtrare solo gli obbligatori del modulo
		if @Modulo <> '' 
		begin
			select @Row = row from ctl_doc_value with(nolock) where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name = 'idModulo' and value = @Modulo
			select @KeyRiga = 'MOD_' + replace( Value , '.','_') from ctl_doc_value with(nolock) where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name = 'KeyRiga' and Row = @Row 
		end


		-- ciclo sulle righe caricate
		declare CurProg_TCEO Cursor static for 
			select DZT_Name, Value 
				from ctl_doc_value 
				where idheader = @idDoc and DSE_ID = 'OBBLIGATORI' 
						and ( @KeyRiga = '' or   DZT_Name = @KeyRiga  )

		open CurProg_TCEO

		FETCH NEXT FROM CurProg_TCEO 	INTO  @DZT_Name, @Value
		WHILE @@FETCH_STATUS = 0
		BEGIN

			select @Row = row from ctl_doc_value with(nolock) where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name = 'KeyRiga' and 'MOD_' + replace( value , '.','_') = @DZT_Name
	
			if @Value = '[]' 
				set @EsitoRiga = ''
			else
			begin
				-- controllo che tutti i campi obbligatori del modulo siano stati caricati
				-- se trova un campo contenuto fra gli obbligatori con valore vuoto
				if exists ( select idrow from ctl_doc_value with(nolock) where idheader = @idDoc and DSE_ID = 'MODULO' and row = 0 and  @value like '%~~~' + DZT_Name + '~~~%' and rtrim( value ) = '' and DZT_Name like @DZT_Name + '%' )
					set @EsitoRiga = '<img src="../images/Domain/State_ERR.png"/>'
				else
					set @EsitoRiga = '<img src="../images/Domain/State_OK.png"/>'

			end
			update CTL_DOC_Value set Value = @EsitoRiga where idheader =  @idTemplate and DSE_ID = 'VALORI' and row = @Row and  DZT_Name = 'EsitoRiga' 


			FETCH NEXT FROM CurProg_TCEO INTO @DZT_Name, @Value
		END 

		CLOSE CurProg_TCEO
		DEALLOCATE CurProg_TCEO


	end


end


GO
