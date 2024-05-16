USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_ISTANZA_SDA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[CK_SEC_ISTANZA_SDA]( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255)) as
begin
        

	-- verifico se la sezione puo essere aperta.


	declare @idPfu int
	declare @Blocco as varchar(255)

        if  exists( select RichiediProdotti 
                        from document_bando b
                                inner join CTL_DOC i on i.linkedDoc = b.idheader 
                        where RichiediProdotti = '0' and i.id = @IdDoc )
        begin

	        if @SectionName in ( 'PRODOTTI' )
	        begin 
		        set @Blocco = 'NON_VISIBILE'		
	        end 


        end
    
        select @Blocco as Blocco

end



GO
