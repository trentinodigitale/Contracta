USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_Desc_Dom]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[Get_Desc_Dom] (@Dom VARCHAR(500) , @Cod VARCHAR(max),@LNG VARCHAR(20)  )
AS
BEGIN 
 	
	set nocount on
	--declare @Ret nvarchar(max)
	declare @dm_query as nvarchar(max)
	declare @strSQL as nvarchar(max)

	select @dm_query =DM_Query from LIB_Domain with (nolock) where dm_id=@Dom

	--select @dm_query as query

	--set @Ret  = ''

	if @dm_query=''
	begin

		--select @Ret =  @Ret + isnull( cast( ML_Description as nvarchar(2000)), cast( DMV_DescML as nvarchar( 2000)))  + ','
		select isnull( cast( ML_Description as nvarchar(2000)), cast( DMV_DescML as nvarchar( 2000))) as Descrizione
			from dbo.LIB_DomainValues
				left outer join dbo.LIB_Multilinguismo on DMV_DescML = ML_KEY and @LNG = ML_LNG
			where DMV_DM_ID = @Dom and DMV_Cod in ( select items from dbo.split(@Cod,'###') )
		
		
			
	end
	else
	begin
		
		set @dm_query = replace(@dm_query,'#LNG#',@LNG)

		if charindex( 'order by ' , @dm_query ) > 0 
		begin 
			set @dm_query = left( @dm_query , charindex( 'order by ' , @dm_query )-1 )
		end

		set @strSQL= '
			
			--declare @Ret nvarchar(max)
			
			--set @Ret=''''

			--select @Ret =  @Ret +  DMV_DescML  + '',''
			select DMV_DescML as Descrizione
			from 
			 ( ' +  @dm_query + ') A

				where  A.DMV_Cod in ( select items from dbo.split(''' + replace( @Cod,'''','''''' ) + ''',''###'') )
				
				'
		
		--execute sp_executeSql @strSQL
		exec ( @strSQL ) 
		--print @strSQL
		

	end

	--if @Ret <> ''
	--	set  @Ret = left (@Ret ,len(@Ret)-1) 
	
	--select  @Ret
	
	

END
GO
