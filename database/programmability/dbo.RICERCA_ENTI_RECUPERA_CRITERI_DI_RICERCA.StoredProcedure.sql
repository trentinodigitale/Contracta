USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICERCA_ENTI_RECUPERA_CRITERI_DI_RICERCA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RICERCA_ENTI_RECUPERA_CRITERI_DI_RICERCA]( @IdDoc int , @Row int , 
														 @AttrName						varchar(8000) output,
														 @AttrValue						varchar(8000) output,
														 @AttrOp 						varchar(8000) output )
AS
BEGIN

	declare @Modello varchar( 200)
    declare @MA_DZT_Name		varchar(50)
    declare @DZT_Type			int
    
    
	declare @VARAttrName		varchar(8000) 
	declare @VARAttrValue		varchar(8000) 
	declare @VARAttrOp 			varchar(8000)     
	declare @Value	 			varchar(8000)     
	
	set @VARAttrName		= ''
	set @VARAttrValue		= ''
	set @VARAttrOp 			= ''
	
	set @Modello = 'RICERCA_ENTI_CRITERI'
	
	

	declare CurModello Cursor static for 
		Select MA_DZT_Name  , DZT_Type
			from LIB_ModelAttributes 
				inner join LIB_Dictionary on DZT_Name = MA_DZT_Name
			where MA_MOD_ID = @Modello and MA_DZT_Name not in ( 'FNZ_DEL' , 'Sort' )
			order by MA_Order
	
	open CurModello

	FETCH NEXT FROM CurModello 	INTO @MA_DZT_Name , @DZT_Type
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- recupero il valore eventualmente inputato
		set @Value = ''
		select @Value = Value from CTL_DOC_Value where IdHeader = @IdDoc and DSE_ID = 'CRITERI' and Row = @Row and DZT_Name = @MA_DZT_Name
		
		if isnull( @Value  , '' ) <> ''
		begin

			-- aggiungo l'attributo come filtro di ricerca
			set @VARAttrName = @VARAttrName + @MA_DZT_Name + '#@#'
		
			-- aggiungo il valore da filtrare e la condizione
			if @DZT_Type in ( 1 , 3 ) -- testo
			begin
				set @VARAttrValue = @VARAttrValue + '''%' + replace( replace( @Value , '*' , '%' ) , '''','''''') + '%''#@#'
				set @VARAttrOp = @VARAttrOp + ' like #@#'
			end
			else 
			begin
				set @VARAttrValue = @VARAttrValue + '''' + @Value + '''#@#'
				set @VARAttrOp = @VARAttrOp + ' = #@#'
			end
		
		end

		FETCH NEXT FROM CurModello 	INTO @MA_DZT_Name , @DZT_Type
	END 
	CLOSE CurModello
	DEALLOCATE CurModello	
	

	if @VARAttrName <> '' 
	begin
		set @VARAttrName		= left( @VARAttrName , len(@VARAttrName) - 3 )
		set @VARAttrValue		= left( @VARAttrValue , len(@VARAttrValue) - 3 )
		set @VARAttrOp	 		= left( @VARAttrOp , len( @VARAttrOp ) - 3 )
	end

	set @AttrName		= @VARAttrName 
	set @AttrValue		= @VARAttrValue 
	set @AttrOp 		= @VARAttrOp 
	

end









GO
