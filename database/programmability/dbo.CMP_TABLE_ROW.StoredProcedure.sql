USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CMP_TABLE_ROW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[CMP_TABLE_ROW]( @Table as Varchar(200) ,@Col_Identity varchar(500), @Col_List varchar(500) , @id_List1 int , @id_List2 int , @Col_Escludi varchar(4000))
AS
begin
	
	set nocount on
	--la stored confronta tutte le colonne, tranne le colonne indicate in @Col_Escludi, di due insiemi di record indicati da @id_List1 e @id_List2
	--ritorna un record con una colonna ESITO con valore: EQUAL ( se non ci sono differente ) / DIFFERENT se ci sono differenze

	--declare @Table as Varchar(200) ,@Col_Identity varchar(500), @Col_List varchar(500) , @id_List1 int , @id_List2 int , @Col_Escludi varchar(4000)

	--set @Table = 'DOCUMENT_REQUEST_GROUP'
	--set @Col_Identity = 'idrow'
	--set @Col_List = 'idheader'
	--set @id_List1 = 407862
	--set @id_List2 = 429591
	--set @Col_Escludi = 'idrow,idheader'

	--NOTA BENE: ANDREBBE ESTESA SE L'INSIEME DI RECORD NON è IDENTIFICATO DA UNA SOLA COLONNA
	--			(AD ESEMPIO I RECORD DELLA TABELLA DOCUMENT_MICROLOTTI_DETTAGLI)

	declare @sql as varchar(MAX)
	declare @crlf varchar(10)
	declare @Cond_Compare as varchar(MAX)

	set @Cond_Compare=''

	--ricavo la condizione di confronto sulle colonne della tabella 
	SELECT 
	    @Cond_Compare= @Cond_Compare +  'LIST1.' + c.name + ' <> LIST2.' + c.name + ' OR '
		--t.Name 'Data type'
	FROM    
		syscolumns c, sysobjects b
	--INNER JOIN 
		--sys.types t ON c.user_type_id = t.user_type_id
		--sysobjects b on c.id = b.id 

	WHERE
		c.id = b.id
		and b.name = @Table 
		--c.object_id = OBJECT_ID(@Table)
		and PATINDEX (  '%,' + c.name + ',%' , ',' + @Col_Escludi + ','   ) = 0 
		and b.xtype='U'
		order by c.name
	
	
	if @Cond_Compare <> ''
	begin
		set @Cond_Compare = left( @Cond_Compare , len( @Cond_Compare ) - 3 )
		--select @Cond_Compare
	end

	
	set @crlf = '
'
	
	
	set @sql = '
		
		declare @Esito as varchar(30) ' + @crlf + '

		declare @NumRecord1 as int ' + @crlf + '
		declare @NumRecord2 as int ' + @crlf + '

		set @Esito = ''EQUAL'' ' + @crlf + '

		--travaso la prima lista di record in una tabella temporanea #T1 creando la colonna NumRiga sulla colonna identity	
		select ROW_NUMBER() over (order by ' + @Col_Identity + ' asc) as NumRiga, * into #T1 from ' + @Table + ' with (nolock) where ' + @Col_List + ' = ' + cast(@id_List1 as varchar(100)) + @crlf + '
		
		--travaso la seconda lista di record in una tabella temporanea #T2 creando la colonna NumRiga sulla colonna identity
		select ROW_NUMBER() over (order by ' + @Col_Identity + ' asc) as NumRiga, * into #T2 from ' + @Table + ' with (nolock) where ' + @Col_List + ' = ' + cast(@id_List2 as varchar(100)) + @crlf + '

		--determino numero righe prima lista
		select @NumRecord1 = count(*) from #T1 ' + @crlf + '

		--determino numero righe seconda lista
		select @NumRecord2 = count(*) from #T1 ' + @crlf + '

		if @NumRecord1 <> @NumRecord2			' + @crlf + '
			set @Esito = ''DIFFERENT''			' + @crlf + '
		
		--se hanno lo stesso numero di record allora procedo a confrontare il contenuto 
		--che collego per numero riga
		if @Esito = ''EQUAL'' ' + @crlf + '
		begin
			
			select LIST1.Numriga into #DIFF from 
			( select * from #T1 ) LIST1
				inner join ( select * from #T2 ) LIST2 on LIST1.Numriga = LIST2.Numriga
				where ' + @Cond_Compare + '
			
			if exists ( select top 1 Numriga from #DIFF )
				
				set @Esito = ''DIFFERENT''

		end ' + @crlf + '
		
		select 	 @Esito as Esito

		'

		exec (@sql)
		--select (@sql)
	
end



GO
