USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_BANDO_CRONOLOGIA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[OLD2_CK_SEC_BANDO_CRONOLOGIA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @del varchar(20)
	

	


	select @del = deleted  from CTL_DOC where id = @IdDoc
	

    if  @del = '1'
    begin

			set @Blocco = 'NON_VISIBILE'		
		
    end
    



	select @Blocco as Blocco

end


GO
