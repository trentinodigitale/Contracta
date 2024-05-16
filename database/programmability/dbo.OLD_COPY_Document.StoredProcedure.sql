USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COPY_Document]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  PROCEDURE [dbo].[OLD_COPY_Document]( @TIPODOC as Varchar(200) ,@IdDoc int , @IdNewDoc int output ) 
AS
begin

	

	declare @sqlCol varchar(max)
	declare @DES_Table varchar(500)
	declare @DES_FieldIdDoc varchar(500)
	declare @DES_FieldIdRow varchar(500)

	declare @sql as varchar(MAX)
	declare @crlf varchar(10)
	set @crlf = '
'


	-- prepara il record base che come presupposto deve stare sulla CTL_DOC	
	insert into CTL_DOC ( TipoDoc ) values ( @TipoDoc  ) 
	set @IdNewDoc = SCOPE_IDENTITY()


	exec COPY_RECORD 'CTL_DOC'   ,@IdDoc  , @IdNewDoc, 'ID'

	update ctl_doc set deleted = 1 where id = @IdNewDoc



	-- recupera dalla documentazione le tabelle coinvolte
	declare CurProg_COPY_Document Cursor static for 
		Select distinct  DES_Table , DES_FieldIdDoc , DES_FieldIdRow from LIB_DocumentSections 
			where [DSE_DOC_ID] = @TIPODOC and DES_Table <> 'CTL_DOC'
			--order by [DES_Order]
	
	open CurProg_COPY_Document

	FETCH NEXT FROM CurProg_COPY_Document 	INTO @DES_Table , @DES_FieldIdDoc , @DES_FieldIdRow
	WHILE @@FETCH_STATUS = 0
	BEGIN

		print @DES_Table

		begin
	             
			
			set @sqlCol = ''

			select @sqlCol = @sqlCol + '[' + a.name + '] , ' + @crlf
			
				from syscolumns a, sysobjects b
				where a.id = b.id
					and b.name = @DES_Table 
					and PATINDEX (  '%,' + a.name + ',%' , ',' + @DES_FieldIdRow + ',' + @DES_FieldIdDoc + ','  ) = 0 
					and b.xtype='U'
			
			--E.P. att. 416087 nel caso di viste non torna nulla 
			--e quindi non copio
			if @sqlCol <> ''
			begin
				set @sqlCol = left( @sqlCol , len( @sqlCol ) - 5 )
			

				set @sql= 'insert into ' + 	@DES_Table + ' ( ' + @DES_FieldIdDoc + ',' + @sqlCol + ' ) 
							select  ' +  cast( @IdNewDoc as varchar ) + ' , '  + @sqlCol + ' from ' + @DES_Table + ' with(nolock)
								Where  ' + @DES_FieldIdDoc + ' = ' + cast( @IdDoc as varchar ) + '
								order by ' + @DES_FieldIdRow + ' asc '

				
				exec ( @sql )
			end

		end
	
		FETCH NEXT FROM CurProg_COPY_Document 	INTO @DES_Table , @DES_FieldIdDoc , @DES_FieldIdRow
	
	END 
	CLOSE CurProg_COPY_Document
	DEALLOCATE CurProg_COPY_Document

	
end
GO
