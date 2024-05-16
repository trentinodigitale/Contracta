USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INSERT_RECORD_NEW]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[INSERT_RECORD_NEW]( @Table as Varchar(200) ,@idSource int ,@idDest int , @Key varchar(200) , @Escludi varchar(max) , @filter nvarchar(max), 
							 @StaticSourceField as varchar(max)='', @StaticDestField as varchar(max)='', @OrderBy as varchar(max)='')

AS

/*
    @Table = tabella da cui copia e poi inserisce
    @idSource = valore della colonna identity per copiare
    @idDest = valore della colonna identity sulle nuove righe da inserire
    @Key = colonna identity 
    @Escludi = colonne da escludere dalla copia nella forma col1,....col,colN
    @filter = condizione di filtro per la sorgente da cui copiare
    @StaticSourceField = lista colonne statiche da aggiungere nella copia ( subito dopo la colonna identity )
    @StaticDestField = valori della lista colonne statiche da aggiungere nella copia
*/

begin
    
     
	declare @sql as nvarchar(MAX)
	declare @sqlColonne as nvarchar(MAX)

	declare @crlf varchar(10)
	set @crlf = '
'

	set @sqlColonne = ''

	-- determino le colonne da riportare
	select @sqlColonne = @sqlColonne + a.name + ' , '
		from syscolumns a, sysobjects b
		where a.id = b.id
			and b.name = @Table 
				and PATINDEX (  '%,' + a.name + ',%' , ',' + rtrim(ltrim(@Escludi)) + ',' + rtrim(ltrim(@Key)) + ',' + rtrim(ltrim(@StaticSourceField)) + ','  ) = 0 
				and b.xtype='U'
    
	set @sqlColonne = left ( @sqlColonne , len( @sqlColonne ) -2)


	-- conpongo lo script 
	set @sql = 'insert into ' + @Table + ' ( ' 
	
	--aggiungo la colonna identity 
	set @sql = @sql + @Key 
	
	--aggiungo le colonne fisse se passate
	if @StaticSourceField <> '' 
	   set @sql = @sql + ' ,'  + @StaticSourceField

     --aggiungo tutte le altre colonne dinamiche della tabella	      
	if @sqlColonne <> ''
	   set  @sql = @sql + ' ,' + @sqlColonne 
	   
	set @sql = @sql + ' ) ' + @crlf

	--aggiungo la parte dei valori
	set @sql = @sql + '  select '

	--aggiungo valore colonna identity
	set @sql = @sql + cast( @idDest as nvarchar(20))

     --se passata lista colonne fisse le aggiungo come valori @StaticDestField
	if @StaticSourceField <> ''
	begin
	    set @sql = @sql + ' , ' + @StaticDestField
     end

	--aggiungo le altre colonne dinamiche
	if @sqlColonne <> ''
	   set @sql = @sql + '  , ' + @sqlColonne + ' from ' + @Table + ' with (nolock) where 1=1 '


	--applico la condizione su colonna identity con il valore di idsource
	if @idSource <> -1  
		set @sql = @sql + ' and ' + @Key + ' = ' + cast( @idSource as varchar(20))
	   
	
	if isnull( @filter , '' ) <> '' 
	   set @sql = @sql + ' and ' + @filter 
	
     if @OrderBy <> ''
	   set @sql = @sql + ' order by ' + @OrderBy

	
    --select @sql
	exec ( @sql )

end






GO
