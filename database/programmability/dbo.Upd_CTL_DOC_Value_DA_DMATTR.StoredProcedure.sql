USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Upd_CTL_DOC_Value_DA_DMATTR]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upd_CTL_DOC_Value_DA_DMATTR] (  @IdAzi INT
                            , @dztNome varchar(50)
                            , @IdDoc INT
                            , @sezione varchar(200)
                           )
AS
SET NOCOUNT ON

DECLARE @valore			  VARCHAR(8000)

--recupera il valore nella DM_ATTRIBUTI 
IF EXISTS (select 1 from lib_dictionary where dzt_name=@dztNome and DZT_MULTIVALUE=1 )
BEGIN
	set @valore='###'
	SELECT @valore=@valore + vatValore_FT + '###'
		 from DM_ATTRIBUTI 
		 WHERE dztNome=@dztNome
			 and lnk=@IdAzi
	if @valore='###'
	begin
		set @valore=''
	end
END
ELSE
BEGIN
	SELECT @valore=vatValore_FT
	 from DM_ATTRIBUTI 
	 WHERE dztNome=@dztNome
		 and lnk=@IdAzi
END
 

IF @valore IS NULL
BEGIN
        RAISERROR('Valore %s non trovato', 16, 1, @dztNome)
        RETURN 99
END


/* Insert oppure Update */

IF EXISTS (Select * from CTL_DOC_VALUE  where idHeader = @IdDoc and DZT_Name = @dztNome )
	BEGIN	
		update CTL_DOC_Value set Value=@valore  from CTL_DOC_Value where idHeader = @IdDoc and DSE_ID=@sezione and DZT_Name = @dztNome
	END
ELSE
	BEGIN
		Insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
		VALUES (@IdDoc,@sezione,0,@dztNome,@valore)
	END


SET NOCOUNT OFF



GO
