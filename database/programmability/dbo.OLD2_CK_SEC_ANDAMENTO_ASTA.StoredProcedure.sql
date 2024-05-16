USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_ANDAMENTO_ASTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  proc [dbo].[OLD2_CK_SEC_ANDAMENTO_ASTA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @StatoAsta as varchar(100)

	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	

	
	select 
		@StatoAsta=StatoAsta
		from document_asta
		where idheader = @IdDoc
	

    if  @StatoAsta not in ( 'chiusa', 'AggiudicazioneDef', 'AggiudicazioneProvv',  'AggiudicazioneCond') -- Bando - Ristretta
    begin

		if @SectionName in ( 'RIEPILOGOFINALE' )
		begin 
			set @Blocco = 'NON_VISIBILE'		
		end 
    
    end
    
    
	select @Blocco as Blocco

end













GO
