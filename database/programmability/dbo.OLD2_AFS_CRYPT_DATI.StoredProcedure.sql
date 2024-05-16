USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AFS_CRYPT_DATI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_AFS_CRYPT_DATI]( @TableName varchar(500) , @fieldKeyDoc as varchar(200) ,  @ValueKeyDoc  as varchar(100)  ,@ModelName as varchar(200) , @AttrEccezzioni  as varchar(1000) , @FilterRow as varchar(1000))
as
begin

	SET NOCOUNT ON;
	declare @Ver varchar(10)
	declare @SqlScript nvarchar(max)	
	
	select @Ver = CRYPT_VER from  CTL_DOC with(nolock) where Id = @ValueKeyDoc


	set @Ver = ISNULL( @Ver ,  '0' ) 

	--exec AFS_CRYPT_DATI_VER_0 @TableName , @fieldKeyDoc ,  @ValueKeyDoc    ,@ModelName , @AttrEccezzioni  , @FilterRow 
	set @SqlScript =  'exec AFS_CRYPT_DATI_VER_' + @Ver  + ' ''' +  replace( @TableName , '''' , '''''' ) + ''' , ''' + @fieldKeyDoc + ''' , ''' + REPLACE(  @ValueKeyDoc  ,'''' , '''''' ) + '''  , ''' + @ModelName + ''' , ''' + REPLACE(  @AttrEccezzioni , '''' , '''''' ) + ''' , ''' + replace ( @FilterRow , '''' , '''''' ) + ''' '
	exec ( @SqlScript  ) 
end

GO
