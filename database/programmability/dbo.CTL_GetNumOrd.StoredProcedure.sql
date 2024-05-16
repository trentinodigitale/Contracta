USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CTL_GetNumOrd]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[CTL_GetNumOrd] ( @dztName varchar(50) , @Plant varchar(50) , @NumOrd as varchar(50) output )
--RETURNS VARCHAR(200)
AS
BEGIN 
 	set nocount on

	declare @max varchar(20)
	declare @last int
	declare @EndValue int
	declare @StartValue int

	set @max = ''
	set @last = -1

	select @EndValue = EndValue ,@StartValue = StartValue , @last = currentvalue from CountersPlant where dztname =  @dztName and sedidest = @Plant



	if @last = -1 
	begin

		set @max = right( cast( year( getdate()) as varchar) ,2 ) + '00001'

	end
	else
	begin		
		set @last = @last + 1 
		If @last < @StartValue Or @last > @EndValue
		begin
            set @last = @StartValue
		end

        update CountersPlant set currentvalue = @last 
			where dztname =  @dztName and sedidest = @Plant

		set @max = right( cast( year( getdate()) as varchar) ,2 ) + right( '000000' + cast( @last as varchar(5) ) ,5)

	end

	set nocount off
	
	--print @max
	set @NumOrd = @max

END



GO
