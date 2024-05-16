USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_RICHIESTA_SMART_CIG_DATI_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  PROCEDURE [dbo].[CK_RICHIESTA_SMART_CIG_DATI_GARA] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Oggetto nvarchar(max)
	declare @OldOggetto nvarchar(max)
	declare @importoBaseAsta2 float
	declare @nEqual as int
	declare @IdRichiesta as int
	set @nEqual = 1
	
	--recupero id richiesta cig
	set @IdRichiesta=0
	select @IdRichiesta=ID
		from 
			CTL_DOC with (nolock)
		where 
			LinkedDoc = @idDoc and TipoDoc='RICHIESTA_SMART_CIG' and StatoFunzionale='Inviato' and Deleted=0

	if isnull(@IdRichiesta,0) > 0
	begin
		
		select @Oggetto = Body from CTL_DOC with(nolock)  where id = @idDoc
		
		select @OldOggetto = Body from CTL_DOC with(nolock)  where id = @IdRichiesta

		select  
			@importoBaseAsta2 = importoBaseAsta2
			from 
				document_bando with(nolock) 
			where idHeader = @idDoc

		--se cambiato oggotto oppure importobaseasta
		if exists (
			select idrow from 
				Document_SIMOG_SMART_CIG with(nolock) 
				where idHeader = @IdRichiesta
					and (   
							@OldOggetto <> @Oggetto 
							or	
							dbo.AFS_ROUND(@importoBaseAsta2,2) <> dbo.AFS_ROUND(IMPORTO_GARA,2) 
						)
			)
			set @nEqual = 0

		
	end

	IF @nEqual = 1
		select 'OK' as Esito
	else
		select 'KO' as Esito

END










GO
