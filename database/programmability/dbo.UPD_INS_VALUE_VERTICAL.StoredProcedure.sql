USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UPD_INS_VALUE_VERTICAL]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UPD_INS_VALUE_VERTICAL]	( @idDoc int , @dse_id varchar(500), @dzt_name nvarchar(max),@value nvarchar(max), @row int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and DSE_ID = @dse_id and DZT_Name = @dzt_name and Row = @row )
	BEGIN

		UPDATE ctl_doc_value
				set Value = @value
			where IdHeader = @idDoc and DSE_ID = @dse_id and DZT_Name = @dzt_name and Row = @row

	END
	ELSE
	BEGIN

		INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @idDoc , @dse_id , @row , @dzt_name ,@value )

	END

	


END



GO
