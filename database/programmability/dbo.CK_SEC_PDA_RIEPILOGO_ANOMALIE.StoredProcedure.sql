USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_PDA_RIEPILOGO_ANOMALIE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[CK_SEC_PDA_RIEPILOGO_ANOMALIE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.


	declare @idPfu int
	declare @idPDA int
	set @idPDA = @IdDoc
	declare @Blocco nvarchar(1000)
	set @Blocco = ''


	
	-- verifico la presenza di anomalie di tipo lotti multipli
	if @SectionName = 'INTERSEZIONE'
	begin 
		if not exists( select * from  document_pda_offerte_anomalie where  IdRowOfferta = @IdDoc and TipoAnomalia = 'Conflitto'  )
			set @Blocco = 'NON_VISIBILE' 

	end

	select @Blocco as Blocco

end





GO
