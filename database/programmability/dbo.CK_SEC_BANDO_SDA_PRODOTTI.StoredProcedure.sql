USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_SDA_PRODOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[CK_SEC_BANDO_SDA_PRODOTTI] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	declare @RichiediProdotti as int


	set @Blocco = ''
	
	if left( @IdDoc , 3 ) <> 'new'
	begin

	
		select @RichiediProdotti = isnull(RichiediProdotti,0)  from document_bando where idheader = @IdDoc

		if  @RichiediProdotti = 2
		begin
			set @Blocco = 'NON_VISIBILE'		
    
		end
    
	end
	ELSE
	if @SectionName = 'PRODOTTI'
		set @Blocco = 'NON_VISIBILE'		   
	
	select @Blocco as Blocco

end














GO
