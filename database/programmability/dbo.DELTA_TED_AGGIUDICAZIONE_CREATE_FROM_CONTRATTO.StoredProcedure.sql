USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_CONTRATTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_CONTRATTO] ( @idcontratto int , @IdUser int, @lotti varchar(max) = null )
AS
BEGIN 

	SET NOCOUNT ON
	declare @idGara int
	-- questa stored viene chiamata dal documento contratto 	
	-- se sono necessari ragionamenti specifici per il giro  applicarli qui e non nella stored generica
	set @idGara=419585


	EXEC DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_BANDO @idGara ,@IdUser , @lotti , 'CONTRATTO', 1

END
GO
