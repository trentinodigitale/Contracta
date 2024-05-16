USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_GET_SIMOG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_GET_SIMOG]  ( @gara int , @IdUser int ) AS
BEGIN

	SET NOCOUNT ON

	DELETE FROM CTL_DOC_Value where IdHeader = @gara and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'

	exec RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI @gara, @IdUser, 1

END
GO
