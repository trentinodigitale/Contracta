USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STORED_attributi_template_mail]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[STORED_attributi_template_mail]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)


as
declare @Param varchar(8000)	  
	declare @SQLCmd			varchar(8000)
	declare @LISTViewName varchar(200)
	declare @count int
	
	set @LISTViewName=@Filter
	
	set @LISTViewName=REPLACE(substring(@LISTViewName,len(' ViewName = ')+1,len(@LISTViewName)),'''','')
	set @SQLCmd =  'select a0.ViewName,a0.colonna,a0.colonnatecnica,a0.ID from view_attributi_template A0 '
	
	set @LISTViewName=LTRIM(@LISTViewName)
	set @LISTViewName=RTRIM(@LISTViewName)
	select @count=count(items) from dbo.split(@LISTViewName,'###')
	IF @count>0
	BEGIN
			--cursore per ciclare sulle n viste
			declare @items as varchar(2000) 
		    declare @i as int
		    declare @viewStart as varchar(200)
		    set @viewStart='' 
		    set @i=1  
			declare CurProg Cursor static for 
			
			
			
			select items from dbo.split(@LISTViewName,'###')

		    
			open CurProg

			FETCH NEXT FROM CurProg 
			INTO @items
				WHILE @@FETCH_STATUS = 0
						BEGIN
						IF (@viewStart='')BEGIN SET @viewStart=@items END
						ELSE
						BEGIN
						 set @SQLCmd=@SQLCmd + ' inner join view_attributi_template as A'+convert( varchar(10),@i)+
											   ' on A'+convert( varchar(10),@i)+'.colonna=A'+convert( varchar(10),@i-1)+'.colonna and A'+convert( varchar(10),@i)+
											   '.ViewName='''+@items+''''										     
			            
						set @i=@i+1
			            END
			            
			            
						 FETCH NEXT FROM CurProg 
						INTO @items
					END 

			CLOSE CurProg
			DEALLOCATE CurProg
		set @SQLCmd=@SQLCmd +  ' where A0.ViewName='''+@viewStart +''''
	END
	set @SQLCmd=@SQLCmd + ' union select REL_TYPE as ViewName,REL_ValueInput + ''('' + dbo.Cnv_Estesa( REL_ValueOutput , ''I'' ) + '')'' as colonna,REL_ValueOutput as colonnatecnica,REL_ValueInput as ID from CTL_RELATIONS  where REL_TYPE=''MAIL_TEMPLATE_KEY_ML'''
	set nocount on	
	
	
 exec (@SQLCmd)
	
--print @SQLCmd


GO
