USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_GARA_AQ_ENTE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CK_SEC_BANDO_GARA_AQ_ENTE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
AS
BEGIN
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	-- verifico se la sezione puo essere aperta.
	-- se il documento di “Abilitazione Rilancio” è stata approvato, 
	-- visualizzare le offerte tecniche/economiche degli aggiudicatari (N.B. solo il RUP accreditato avrà accesso alle offerte) 
	IF upper(@SectionName) = 'LISTA_OFFERTE' 
	BEGIN
		set @Blocco = 'NON_VISIBILE'
		IF EXISTS ( select AB.id 
						from CTL_DOC AQ with(nolock) 
							inner join CTL_DOC AB with(nolock) on AB.LinkedDoc=AQ.Id and AB.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and AB.StatoFunzionale='Confermato'
					where AQ.Id=@IdDoc and AB.IdPfu=@IdUser
				  )
		BEGIN
			set @Blocco = ''
		END		
	END





	select @Blocco as Blocco

END
GO
