USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_AFFIDAMENTO_SENZA_NEGOZIAZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  proc [dbo].[CK_SEC_DOC_AFFIDAMENTO_SENZA_NEGOZIAZIONE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255), @Blocco  nvarchar(1000)=null OUTPUT , @NoSquenza int = 0 )
AS
BEGIN

	-- verifico se la sezione puo essere visualizzata.
	declare @StatoFunzionale varchar(50)
	set @Blocco = ''

	select 
		@StatoFunzionale = StatoFunzionale
	from CTL_Doc C with (nolock)
	where id = @IdDoc


	if @SectionName = 'ANNULLA' and @StatoFunzionale not in ('Annullato', 'InAnnullamento')
	begin 
		set @Blocco = 'NON_VISIBILE'
	end

	--Ritorno lo stato non visibile in caso soddisfi la condizione
	select @Blocco as Blocco

END

GO
