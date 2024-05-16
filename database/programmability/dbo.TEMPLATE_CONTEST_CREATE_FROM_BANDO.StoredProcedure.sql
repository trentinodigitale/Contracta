USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_CONTEST_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  Proc [dbo].[TEMPLATE_CONTEST_CREATE_FROM_BANDO]
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	
	
	--select top 0 
	--	cast( '' as varchar(250)) as id , 
	--	cast( '' as varchar(max)) as Errore
	--	into #Result

	--insert into #Result exec TEMPLATE_CONTEST_CREATE_FOR @IdDoc , @idUser , 'DGUE'

	--select * from #Result

	exec TEMPLATE_CONTEST_CREATE_FOR @IdDoc , @idUser , 'DGUE'

	--declare @id as varchar(50)
	--declare @Errore as nvarchar(2000)
	
	--set @Id = ''
	--set @Errore=''

	--select @id = id from ctl_doc where deleted = 0 and linkeddoc = @IdDoc and tipodoc = 'TEMPLATE_CONTEST'

	--if not exists( select * from ctl_doc where deleted = 0 and linkeddoc = @IdDoc and tipodoc = 'TEMPLATE_CONTEST' )
	--begin

		
	--	declare @idTemplate int


	--	-- recupero il template
	--	select @idTemplate = id  from ctl_doc where deleted = 0 and tipodoc = 'TEMPLATE_REQUEST' and StatoFunzionale = 'Pubblicato' and jumpcheck = 'DGUE'


	--	-- genero il template
	--	insert into ctl_doc ( [TipoDoc], [IdPfu], [Data], [Titolo], [LinkedDoc] , [IdDoc]  , jumpcheck )
	--		values( 'TEMPLATE_CONTEST' , @idUser , getdate() , '' , @IdDoc , @idTemplate , 'DGUE' )

	--	set @id = SCOPE_IDENTITY()


	--	-- recupero le parti che sono obbligatori
	--	select  distinct k2.Row as Riga , k2.Value as KeyRiga , t2.Value as Parti  , m2.Value as idModulo into #Temp
	--		from ctl_doc_value o 
	--			inner join ctl_doc_value t on t.idheader = o.IdHeader and t.Row = o.Row and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.Value = 'Parti'
	--			inner join ctl_doc_value k on k.idheader = o.IdHeader and k.Row = o.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga' 

	--			-- recupero tutti gli elementi delle parti non obbligatorie
	--			inner join ctl_doc_value k2 on k2.idheader = o.IdHeader and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga'  and left( k.Value ,1 ) = left( k2.Value , 1 ) 
	--			inner join ctl_doc_value t2 on t2.idheader = o.IdHeader and t2.Row = k2.Row and t2.DSE_ID = 'VALORI' and t2.DZT_Name = 'REQUEST_PART' 
	--			inner join ctl_doc_value m2 on m2.idheader = o.IdHeader and m2.Row = k2.Row and m2.DSE_ID = 'VALORI' and m2.DZT_Name = 'idModulo' 
	--		where  o.idheader = @idTemplate and o.DSE_ID = 'VALORI' and o.DZT_Name = 'Obbligatorio' and o.Value <> '1'


				
	--	-- Porto le righe da selezionare sul template per contesto
	--	declare CurTemplateRequest Cursor local static for 
	--		select Riga  , Parti , idModulo from #Temp order by riga

	--	declare @row int
	--	declare @Riga int
	--	declare @Parti varchar(500)
	--	declare @idModulo int
	--	declare @Desc nvarchar(max)
	--	set @row = 0

	--	open CurTemplateRequest

	--	FETCH NEXT FROM CurTemplateRequest 	INTO  @Riga , @Parti , @idModulo
	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN
	
	--		-- gli associo tutte le richieste
	--		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
	--			select @id as IdHeader, DSE_ID, @Row, DZT_Name, Value
	--				from ctl_doc_value 
	--					where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name not in ( 'FNZ_DEL' , 'FNZ_COPY' , 'FNZ_UPD'  ) and row = @Riga


	--		-- se il rigo è riferito ad un modulo si aggiorna la descrizione recuperandola dal modulo
	--		if @Parti = 'Modulo'
	--		begin
	--			--select @Desc = '<b>' + dbo.HTML_Encode( Body ) + '</b></br>' + + dbo.HTML_Encode( Note ) from ctl_doc where id = @idModulo
	--			select @Desc = '<b>' +  cast(  Body  as nvarchar(max)) + '</b></br>' +  cast( Note as nvarchar(max))  from ctl_doc where id = @idModulo
	--			update CTL_DOC_Value set Value = @Desc where IdHeader = @id and DSE_ID = 'VALORI' and Row = @row and DZT_Name = 'DescrizioneEstesa'
	--		end

	--		-- rendo non editabili le spunte delle aree non removibili
	--		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
	--			select  @id as IdHeader, 'VALORI' as DSE_ID, @Row, 'NotEditable' as DZT_Name, case when o.Value = '1' then ' SelRow ' else '' end as Value
	--				from ctl_doc_value o 
	--				where  idheader = @idTemplate and o.DSE_ID = 'VALORI' and o.DZT_Name = 'Obbligatorio' and row = @Riga

	--		set @row = @row + 1
	--		FETCH NEXT FROM CurTemplateRequest 	INTO  @Riga , @Parti , @idModulo
	--	end
	--	CLOSE CurTemplateRequest
	--	DEALLOCATE CurTemplateRequest


	--	--metto le spunte per le selezioni implicite
	--	delete from CTL_DOC_Value  where idheader = @id and DSE_ID = 'VALORI'  and DZT_Name = 'SelRow'
	--	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
	--		select  @id as IdHeader, 'VALORI' as DSE_ID, Row, 'SelRow' as DZT_Name, '1' as Value
	--			from ( select distinct [Row] from ctl_doc_value where idheader = @id and DSE_ID = 'VALORI' /*and DZT_Name = 'KeyRiga' */ ) as a






	--end


	
	--if @Errore=''
	--	-- rirorna id odc creato
	--	select @Id as id , @Errore as Errore
	--else
	--begin
	--	-- rirorna l'errore
	--	select 'Errore' as id , @Errore as Errore
	--end
		
	
	
end




GO
