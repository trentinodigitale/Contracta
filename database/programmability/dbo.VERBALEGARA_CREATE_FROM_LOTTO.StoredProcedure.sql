USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERBALEGARA_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create  PROCEDURE [dbo].[VERBALEGARA_CREATE_FROM_LOTTO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN


	exec VERBALEGARA_CREATE_FROM_DOCUMENT @idDoc , @IdUser   , 'LOTTO' 

	END














GO
