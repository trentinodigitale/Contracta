USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INS_CTL_DOC_Value_DA_DMATTR]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[INS_CTL_DOC_Value_DA_DMATTR] (  @IdAzi INT
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
        set @valore=''
END


/* Insert   */


		Insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
		VALUES (@IdDoc,@sezione,0,@dztNome,@valore)
	


SET NOCOUNT OFF




GO
