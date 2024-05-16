USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Set_Descrizione_Vincolo]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Set_Descrizione_Vincolo] (
 @IdProduct int , @Descrizione as nvarchar(1000) , @Ret as nvarchar(1000) OUTPUT )
AS
BEGIN 

	SET NOCOUNT ON

	declare @Pos as int	
	declare @TempCol as varchar(1000)
	declare @PosFine as int
	DECLARE @IntVariable int;
	DECLARE @SQLString nvarchar(500);
	DECLARE @ParmDefinition nvarchar(500);
	DECLARE @Val_Out float;
	declare @Val_Format as varchar(30)

	SET @IntVariable = @IdProduct;
	SET @ParmDefinition = N'@id int, @Val float OUTPUT';

	set @Ret = @Descrizione
	
	set @Pos=0
	--in descrizione individuo le colonne da sostituire racchiuse in ###col###
	set @Pos = charindex('[',@Descrizione)
	--print @Pos 
	--set @PosFine=charindex('###',@Descrizione,@Pos+3)
	--print @PosFine 
	--set @TempCol = substring(@Descrizione,@Pos+3,@PosFine-(@Pos+3))
	--print @TempCol
	while @Pos > 0
	begin
		
		set @PosFine=charindex(']',@Descrizione,@Pos+1)
		
		if @PosFine > 0
		begin
			set @TempCol = substring(@Descrizione,@Pos+1,@PosFine-(@Pos+1))
			
			--print '@TempCol=' + @TempCol
			
			--recupero valore colonna
			SET @SQLString = N'SELECT @Val = ' + @TempCol + '
			   FROM document_microlotti_dettagli
			   WHERE id = @id';

			EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @IntVariable, @Val=@Val_Out OUTPUT;
			
			set @Val_Format = dbo.FormatMoney(@Val_Out)
			if @Val_Format = ''
				set @Val_Format = 'NULL'			
			
			--sostituisco in descrizione ###tempcol### con il valore
			set @Descrizione = replace( @Descrizione , '[' + @TempCol + ']' , @Val_Format)
	
		end

		set @Pos = charindex('[',@Descrizione)

	end	
	SET @Ret = @Descrizione
	
END
GO
