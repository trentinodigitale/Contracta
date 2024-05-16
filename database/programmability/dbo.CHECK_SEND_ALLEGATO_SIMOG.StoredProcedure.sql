USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHECK_SEND_ALLEGATO_SIMOG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--===========================================================================================================================================
--	STORED UTILIZZATA SIA COME CONTROLLO BLOCCANTE ALL'INVIO DELLE PROCEDURE, SIA DALL'INTEGRAZIONE SIMOG PER CAPIRE SE INVIARE L'ALLEGATO	=
--===========================================================================================================================================
CREATE PROCEDURE [dbo].[CHECK_SEND_ALLEGATO_SIMOG]
( 
  @idGara INT,
  @obblig INT OUTPUT,
  @attach nvarchar(4000) = '' OUTPUT
)
AS  
BEGIN

	declare @descrizioneATTO nvarchar(500)

	set @obblig = 0

	--Il file "bando di gara" è obbligatorio se 
	--	S01.10 >= € 500.000
	--	S02.07 = ‘L’ 
	--  S02.06 è uguale a : 1,2,8,92, 29, 30
	IF EXISTS ( 
		select a.id 
			from CTL_DOC a with(nolock) 
					inner join Document_SIMOG_GARA b with(nolock) on b.idHeader = a.Id and b.IMPORTO_GARA >= 500000 and b.ID_SCELTA_CONTRAENTE IN ('1','2','8','92','29','30' )
					inner join Document_SIMOG_LOTTI c with(nolock) on c.idHeader = a.id and c.TIPO_CONTRATTO = 'L'
			where TipoDoc = 'RICHIESTA_CIG' and StatoFunzionale = 'Inviato' and Deleted = 0 and a.LinkedDoc = @idGara
	)
	BEGIN

		set @descrizioneATTO = dbo.PARAMETRI ( 'GARE','ATTI','BandoDiGara','Bando di gara',-1 )

		set @attach = ''
		select top 1 @attach = isnull(Allegato,'') From CTL_DOC_ALLEGATI with(nolock) where idHeader = @idGara and AnagDoc = @descrizioneATTO and Allegato <> '' order by idrow 

		IF @attach = ''
		BEGIN
			set @obblig = 1
		END

	END
       
END


GO
