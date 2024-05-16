USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PCP_AGGIORNA_DATI_PUBBLICAZIONE_EU]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PCP_AGGIORNA_DATI_PUBBLICAZIONE_EU] ( @idGara int, @dataPubblicazione datetime , @publicationId nvarchar(100), @publicationUrl nvarchar(1000) )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @rowPVL INT = -1

	--Aggiorno il campo sulla tabella del contract notice ( utilizzato ad es. nel recupero dati del change notice )
	UPDATE Document_E_FORM_CONTRACT_NOTICE
			SET cn16_publication_id = @publicationId
		where idHeader = @idGara

	--SE ESISTE GIA UNA RIGA PER LA "GUUE" LA AGGIORNIAMO, ALTRIMENTI NE INSERIAMO UNA NUOVA
	select top 1 @rowPVL = a.Row
		from ctl_doc_value a with(nolock) 
		where a.idHeader = @idGara and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.value = '01'
	
	IF @rowPVL >= 0
	BEGIN

		update ctl_doc_value
				set value = @publicationId
			where idHeader = @idGara and dse_id = 'InfoTec_DatePub' and DZT_Name = 'NumeroPub' and row = @rowPVL

		update ctl_doc_value
				set value = convert( varchar(50 ) , @dataPubblicazione , 121 )
			where idHeader = @idGara and dse_id = 'InfoTec_DatePub' and DZT_Name = 'DataPubblicazioneBando' and row = @rowPVL

		update ctl_doc_value
				set value = @publicationUrl
			where idHeader = @idGara and dse_id = 'InfoTec_DatePub' and DZT_Name = 'TED_VER_PUB_TED_LINK' and row = @rowPVL

	END
	ELSE
	BEGIN

		--Prendiamo l'ultima riga inserita nella griglia così da poter inserire un nuovo elemento con una row+1 ( se non ce ne sono partiremo da 0 )
		SELECT @rowPVL = max(a.Row)
			FROM CTL_DOC_VALUE a WITH(NOLOCK)
			WHERE a.idheader = @idGara and a.dse_id = 'InfoTec_DatePub'

		set @rowPVL = isnull(@rowPVL,-1) + 1

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'Pubblicazioni', '01' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'FNZ_DEL', '' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'LblAttidiGara', '' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'NumeroPub', @publicationId )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'DataPubblicazioneBando', convert( varchar(50 ) , @dataPubblicazione , 121 )  )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'TED_VER_PUB_TED_LINK', @publicationUrl )

	END

END

GO
