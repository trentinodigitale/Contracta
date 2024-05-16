USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  proc [dbo].[CK_SEC_DOC_CONVENZIONE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @jumpcheck varchar(50)
	set @jumpcheck=''

	select  @jumpcheck=ISNULL(jumpcheck,'') from ctl_doc where id = @IdDoc
	

	if @SectionName = 'VINCOLI' and @jumpcheck = 'INTEGRAZIONE' 
	begin 
		set @Blocco = 'NON_VISIBILE'
	end 

	if @SectionName = 'ALLEGATI_RICHIESTI' and @jumpcheck = 'INTEGRAZIONE' 
	begin 
		set @Blocco = 'NON_VISIBILE'
	end 

	if @SectionName = 'DIREZIONI' and @jumpcheck = 'INTEGRAZIONE' 
	begin 
		set @Blocco = 'NON_VISIBILE'
	end 

	if @SectionName = 'QUOTE' and @jumpcheck = 'INTEGRAZIONE' 
	begin 
		set @Blocco = 'NON_VISIBILE'
	end 

	if @SectionName = 'NOTE' and @jumpcheck = 'INTEGRAZIONE' 
	begin 
		set @Blocco = 'NON_VISIBILE'
	end 


	select @Blocco as Blocco

end



GO
