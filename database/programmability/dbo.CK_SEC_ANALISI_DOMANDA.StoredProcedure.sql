USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_ANALISI_DOMANDA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[CK_SEC_ANALISI_DOMANDA]( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as 
begin


	-- verifico se la sezione puo essere aperta.
	declare @DSE_ID  varchar(1000)
	declare @Blocco varchar(1000)

	select @DSE_ID = isnull( Value , '' ) from ctl_doc_value where DSE_ID = 'VISUALIZZAZIONE'  and DZT_Name = 'FOLDER' and idheader = @IdDoc
	set @Blocco = ''

    if @SectionName <> 'ORIGINE'
	begin

		if @SectionName <> @DSE_ID
		begin 
			set @Blocco = 'NON_VISIBILE'		
		end 
    
    end
    
 
	select @Blocco as Blocco

end






GO
