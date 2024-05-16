USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_FIELD_MESSAGGIO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_FIELD_MESSAGGIO] ( @fieldin as varchar(500)  , @IdMsg int , @valuein as varchar(2000) )
AS
BEGIN
--FRANCESCO--ATT.56591--30-04-2014
--Esempio di chiamata
--exec UPDATE_FIELD_MESSAGGIO 'IdDoc','100028','222211111111'	

	declare @indexinizio INT
	declare @indexfine INT
	DECLARE @Ptr   BINARY(16)
	declare @field varchar(500)
	declare @string as varchar(8000)
	declare @diff as INT
	set @field='<AFLinkField'+ @fieldin +'>'
	set @indexinizio=0

	SELECT @Ptr = TEXTPTR(msgText) ,@indexinizio=PATINDEX('%'+ @field +'%',msgText),
		   @indexfine=PATINDEX('%'+ replace(@field,'<','</') +'%',msgText)
					  FROM TAB_MESSAGGI
					 WHERE IdMsg = @IdMsg

	if @indexinizio > 0
	BEGIN
		set @indexinizio=@indexinizio+len(@field)-1
		set  @diff = (@indexfine-1) - @indexinizio
	
			UPDATETEXT TAB_MESSAGGI.msgText @Ptr @indexinizio @diff @valuein
			EXEC sp_invalidate_textptr @Ptr        
	
	END

	IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TAB_MESSAGGI_FIELDS' AND COLUMN_NAME = @fieldin)
	BEGIN
		
		set @string = 'UPDATE TAB_MESSAGGI_FIELDS set ' + @fieldin +'='''+@valuein+''' where idMsg='+cast(@IdMsg as varchar(100)) 
		EXEC (  @string )
	END



END
GO
