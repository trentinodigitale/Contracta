USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetDomFromDztName]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[GetDomFromDztName] (@DZT VARCHAR(500) , @Filter VARCHAR(max), @LNG VARCHAR(20) , @Format nvarchar( 1000) )
AS
BEGIN 
 	
	set nocount on
	--declare @Ret nvarchar(max)
	declare @dm_query as nvarchar(max)
	declare @strSQL as nvarchar(max)
	declare @Dom as varchar(1000)

	select @Dom = [DZT_DM_ID] from LIB_Dictionary with(nolock)  where DZT_Name = @DZT

	select @dm_query =DM_Query from LIB_Domain with (nolock) where dm_id=@Dom


	if @dm_query=''
	begin

		set @dm_query = '
			select 

				a.id, 
				[DMV_DM_ID], 
				[DMV_Cod], 
				[DMV_Father], 
				[DMV_Level], 
				isnull( cast( ML_Description as nvarchar(2000)), cast( DMV_DescML as nvarchar( 2000))) as [DMV_DescML], 
				[DMV_Image], 
				[DMV_Sort], 
				[DMV_CodExt], 
				[DMV_Module], 
				[DMV_Deleted]
			
			from dbo.LIB_DomainValues as a
				left outer join dbo.LIB_Multilinguismo on DMV_DescML = ML_KEY and ''' + @LNG + ''' = ML_LNG
				where DMV_DM_ID = ''' + @Dom + ''' '
			
	end
	else
	begin
		
		set @dm_query = replace(@dm_query,'#LNG#',@LNG)

		if charindex( 'order by ' , @dm_query ) > 0 
		begin 
			set @dm_query = left( @dm_query , charindex( 'order by ' , @dm_query )-1 )
		end

		

	end


	if @Filter <> '' 
	begin

		set @strSQL= '
			
			select a.*
			from 
			 ( ' +  @dm_query + ') as a

				where (  ' + @Filter + ' ) 

				'
	
	end
	else
		set @strSQL = @dm_query

	exec ( @strSQL ) 
	--print @strSQL 

END
GO
