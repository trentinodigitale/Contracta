USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CRITERIA_CALC_PATH]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRITERIA_CALC_PATH] ( @idDoc int )
as
begin

	declare @SubLivelli varchar(100)
	declare @livello int
	declare @Prevlivello int
	declare @TypeRequest varchar(100)
	declare @SubType varchar(100)
	declare @Path  varchar(100)
	declare @idrow int

	set @Prevlivello = 0;

	set @SubLivelli = replicate(  ' ' , 100)
	set @SubType = replicate(  ' ' , 100)

	-- ciclo sulle righe caricate
	declare Cur_CRITERIA_CALC_PATH Cursor static for 
		select idrow , ItemLevel  , TypeRequest
			from DOCUMENT_REQUEST_GROUP
			where  idheader  = @idDoc
			order by idRow

	open Cur_CRITERIA_CALC_PATH


	FETCH NEXT FROM Cur_CRITERIA_CALC_PATH 	INTO @idrow , @livello , @TypeRequest
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		
		
		
	--	while ( getObj( 'RRIGHEGrid_' + row + '_ItemLevel'  ) != undefined )
		--{
			--set @livello = getObjValue( 'RRIGHEGrid_' + row + '_ItemLevel' );
			if @livello = '' or @livello = 0 
				set @livello = 1;
			
			if @livello > @Prevlivello
			BEGIN 
				set @SubLivelli  = stuff( @SubLivelli , @livello , 1 , '1')
			end
			else
			begin
				--SubLivelli[livello]++;
				set @SubLivelli  = stuff( @SubLivelli , @livello , 1 , cast( substring( @SubLivelli , @livello,1 ) as int )  + 1 )
			end
			
			--SubType[livello] = 	getObjValue( 'RRIGHEGrid_' + row + '_TypeRequest' );
			set @SubType  = stuff( @SubType , @livello , 1 , @TypeRequest)
			
			-- costruisco il path
			set @Path = '';
			declare @i int
			set @i = 1
			while @i <= @livello 
			begin
				set @Path = @Path + substring( @SubType , @i ,1) 
				if substring( @SubType , @i , 1)  in (  'G' , 'K' , 'T' , 'Q'  ) 
				begin
					declare @j int
					set @j = 1
					while @j <= @i  
					begin
						set @Path = @Path + substring( @SubLivelli , @j , 1)
						if  @j < @i
							set @Path = @Path + '.'

						set @j = @j + 1
					end
				end
				else
				begin
					set @Path = @Path + substring( @SubLivelli , @i ,1 )
				end

				if  @i < @livello
					set @Path = @Path + '/'

				set @i = @i +1
			end

			--SetTextValue( 'RRIGHEGrid_' + row + '_ItemPath' , Path );

			update DOCUMENT_REQUEST_GROUP set ItemPath = @Path where idrow = @idrow

			set @Prevlivello = @livello

		FETCH NEXT FROM Cur_CRITERIA_CALC_PATH 	INTO @idrow , @livello , @TypeRequest
	end	

	CLOSE Cur_CRITERIA_CALC_PATH
	DEALLOCATE Cur_CRITERIA_CALC_PATH
end
GO
