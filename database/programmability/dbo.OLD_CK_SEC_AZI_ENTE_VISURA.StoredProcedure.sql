USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_AZI_ENTE_VISURA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[OLD_CK_SEC_AZI_ENTE_VISURA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	
	SET NOCOUNT ON

	declare @idPfu int
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	IF  @SectionName = 'PEPPOL' 
	BEGIN

		set @Blocco = 'NON_VISIBILE'

		-- SE FACCIO PARTE DELL'AZI MASTER o SE SONO UN UTENTE DI UN ENTE E SE SONO PRESENTI IDNOTIER O PARTICIPANTID
		IF	(	
				EXISTS ( select idpfu from profiliutente with(nolock) where idpfu = @IdUser and pfuIdAzi = 35152001	)
					OR
				EXISTS ( select idazi from aziende with(nolock),profiliutente with(nolock) where pfuidazi = idazi and idpfu = @IdUser and aziAcquirente <> 0 and @IdDoc = idazi)
			)
				AND EXISTS ( select idazi from aziende with(nolock),DM_Attributi with(nolock) where lnk = @IdDoc and ( dztnome = 'PARTICIPANTID' or dztnome = 'IDNOTIER' ) and isnull(vatValore_FT,'') <> '' ) 
					
		BEGIN

			set @Blocco = ''

		END
			
	END

	IF  @SectionName = 'IPA' 
	BEGIN
		
		set @Blocco = 'NON_VISIBILE'

		-- se si sta aprendo una scheda anagrafica di un ente e se ci sono i dati peppol/notier
		IF EXISTS ( select idazi from aziende with(nolock) where aziAcquirente <> 0 and idazi = @IdDoc )
				AND
			EXISTS ( select id 
						from VIEW_SCHEDA_ANAGRAFICA_IPA 
						where idazi = @idDoc and 
								( 
									Peppol_Invio_DDT = '1' 
									or 
									Peppol_Invio_Ordine = '1' 
									or 
									Peppol_Ricezione_DDT = '1' 
									or 
									Peppol_Ricezione_Ordine = '1' 
									Or 
									Peppol_Invio_Fatture = '1'
									Or
									Peppol_Invio_NoteDiCredito = '1'
								)
					)
		BEGIN
			set @Blocco = ''
		END

	END
	
	
			
	select @Blocco as Blocco 
	
	

end

GO
