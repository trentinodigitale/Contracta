USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_BANDO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD_CK_SEC_BANDO_PROGRAMMAZIONE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.


	
	
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @richiestafirma varchar(50)
	
	set @Blocco = ''



	if @SectionName in ( 'ANALISI' )
		begin 
			IF EXISTS ( select id from CTL_DOC with(nolock) where Id=@IdDoc and StatoFunzionale in ('InLavorazione', 'Inviato') )
				set @Blocco = 'NON_VISIBILE'		
		end 

		
	
 


	select @Blocco as Blocco

end
GO
