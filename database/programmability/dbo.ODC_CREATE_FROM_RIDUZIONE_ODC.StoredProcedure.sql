USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ODC_CREATE_FROM_RIDUZIONE_ODC]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ODC_CREATE_FROM_RIDUZIONE_ODC] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	EXEC ODC_CREATE_FROM_ODC @IdDoc, @idUser, 1

END



GO
