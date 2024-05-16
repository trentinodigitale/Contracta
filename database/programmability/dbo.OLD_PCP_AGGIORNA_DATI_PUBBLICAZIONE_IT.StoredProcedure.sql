USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PCP_AGGIORNA_DATI_PUBBLICAZIONE_IT]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[OLD_PCP_AGGIORNA_DATI_PUBBLICAZIONE_IT] ( @idGara int, @dataPubblicazione datetime , @idAvvisoPVL nvarchar(100) )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @rowPVL INT = -1

	--SE ESISTE GIA UNA RIGA PER LA "PUBBLICITÀ VALORE LEGALE" LA AGGIORNIAMO, ALTRIMENTI NE INSERIAMO UNA NUOVA
	select top 1 @rowPVL = a.Row
		from ctl_doc_value a with(nolock) 
				--inner join ctl_doc_value b with(nolock) on b.IdHeader = a.IdHeader and b.DSE_ID = a.DSE_ID and b.Row = a.Row and b.DZT_Name = 'NumeroPub'
		where a.idHeader = @idGara and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.value = 'PVL'-- and b.Value = @idAvvisoPVL

	
	IF @rowPVL >= 0
	BEGIN

		update ctl_doc_value
				set value = @idAvvisoPVL
			where idHeader = @idGara and dse_id = 'InfoTec_DatePub' and DZT_Name = 'NumeroPub' and row = @rowPVL

		update ctl_doc_value
				set value = convert( varchar(50 ) , @dataPubblicazione , 121 )
			where idHeader = @idGara and dse_id = 'InfoTec_DatePub' and DZT_Name = 'DataPubblicazioneBando' and row = @rowPVL

	END
	ELSE
	BEGIN

		--Prendiamo l'ultima riga inserita nella griglia così da poter inserire un nuovo elemento con una row+1 ( se non ce ne sono partiremo da 0 )
		SELECT @rowPVL = max(a.Row)
			FROM CTL_DOC_VALUE a WITH(NOLOCK)
			WHERE a.idheader = @idGara and a.dse_id = 'InfoTec_DatePub'

		set @rowPVL = isnull(@rowPVL,-1) + 1

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'Pubblicazioni', 'PVL' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'FNZ_DEL', '' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'LblAttidiGara', '' )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'NumeroPub', @idAvvisoPVL )

		INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
							values ( @idGara, 'InfoTec_DatePub', @rowPVL, 'DataPubblicazioneBando', convert( varchar(50 ) , @dataPubblicazione , 121 )  )

		--INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
		--					values ( @idGara, 'InfoTec_DatePub', @rowGUUE, 'TED_VER_PUB_TED_LINK', @ted_link )

	END

END

GO
