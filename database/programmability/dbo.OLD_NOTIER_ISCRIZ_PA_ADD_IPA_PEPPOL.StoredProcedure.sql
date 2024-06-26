USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_NOTIER_ISCRIZ_PA_ADD_IPA_PEPPOL]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_NOTIER_ISCRIZ_PA_ADD_IPA_PEPPOL] (  @idAzi int , 
															@idUser int, 
															@ipa nvarchar(1000),
															@idNotier nvarchar(1000),
															@idPeppol nvarchar(1000),
															@CodiceFiscale nvarchar(1000), 
															@piva nvarchar(100),
															@denominazione nvarchar(1000),
															@indirizzo nvarchar(1000),
															@telefono nvarchar(1000),
															@pec nvarchar(1000),
															@referente nvarchar(1000),
															@emailReferente nvarchar(1000),
															@Invio_DDT varchar(10),
															@Invio_Ordine varchar(10),
															@Ricezione_DDT varchar(10),
															@RIcezione_Ordine varchar(10),
															@Invio_Fatture varchar(10),
															@Invio_NoteDiCredito varchar(10)
															)
AS
BEGIN
	
	SET NOCOUNT ON

	declare @denominazioneEnte nvarchar(1000)

	select @denominazioneEnte = aziRagioneSociale from aziende with(nolock) where idazi =@idAzi

	IF EXISTS ( select id from Document_NoTIER_Destinatari with(nolock) where piva_cf = @CodiceFiscale and ID_IPA = @ipa )
	BEGIN

		UPDATE Document_NoTIER_Destinatari
				set sorgente = case when @Ricezione_DDT = '1' then NULL else 'ISCRIZ_PA' end, -- se ricezione DDt è ad 1 lasciamo la sorgente vuota per far si che questa riga entri tra i destinatari peppol dei DDT lato OE
					EmailReferenteIPA = @emailReferente,
					ReferenteIPA = @referente,
					pecIPA = @pec,
					TelefonoIPA = @telefono,
					IndirizzoIPA = @indirizzo,
					denominazione = @denominazioneEnte + ' - ' + @denominazione,
					DenominazioneIPA = @denominazione,
					ID_NOTIER = @idNotier,
					ID_PEPPOL = @idPeppol,
					bdeleted = 0,
					Peppol_Invio_DDT = @Invio_DDT,
					Peppol_Ricezione_DDT = @Ricezione_DDT,
					Peppol_Invio_Ordine = @Invio_Ordine,
					Peppol_Ricezione_Ordine = @RIcezione_Ordine,
					Peppol_Invio_Fatture = @Invio_Fatture,
					Peppol_Invio_NoteDiCredito  = @Invio_NoteDiCredito
			where piva_cf = @CodiceFiscale and ID_IPA = @ipa

	END
	ELSE
	BEGIN

		INSERT INTO Document_NoTIER_Destinatari ( ID_NOTIER, ID_PEPPOL, ID_IPA, piva_cf, denominazione, bDeleted, sorgente, EmailReferenteIPA, ReferenteIPA, pecIPA, TelefonoIPA, IndirizzoIPA, DenominazioneIPA, Peppol_Invio_DDT, Peppol_Ricezione_DDT, Peppol_Invio_Ordine, Peppol_Ricezione_Ordine, Peppol_Invio_Fatture, Peppol_Invio_NoteDiCredito)
										 values ( @idNotier, @idPeppol, @ipa, @CodiceFiscale, @denominazioneEnte + ' - ' + @denominazione, 0,case when @Ricezione_DDT = '1' then NULL else 'ISCRIZ_PA' end, @emailReferente, @referente, @pec, @telefono, @indirizzo, @denominazione, @Invio_DDT, @Ricezione_DDT, @Invio_Ordine, @RIcezione_Ordine, @Invio_Fatture, @Invio_NoteDiCredito )

	END

END


GO
