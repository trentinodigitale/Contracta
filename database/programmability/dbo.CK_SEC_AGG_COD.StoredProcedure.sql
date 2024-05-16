USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_AGG_COD]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[CK_SEC_AGG_COD] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
AS
BEGIN


	-- verifico se la sezione puo essere aperta.


	
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	if not exists (select top 1 idrow from CTL_DOC_Value where IdHeader=@IdDoc and DSE_ID=@SectionName)
		set @Blocco = 'NON_VISIBILE'
	--if @SectionName ='AREA_MERCEOLOGICA'
	--	set @Blocco = 'NON_VISIBILE'	

	
	select @Blocco as Blocco

end























GO
