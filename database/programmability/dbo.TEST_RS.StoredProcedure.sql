USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEST_RS]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TEST_RS] (@idDoc int)
AS

	select aziragionesociale from aziende

GO
