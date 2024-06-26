USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_PCP_BASE_PROCEDURA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_DATI_PCP_BASE_PROCEDURA] 
	-- Add the parameters for the stored procedure here
	@IdDoc as int

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @DataScadenzaPresentazione as varchar(50)

    -- Insert statements for procedure here
	select 

	@DataScadenzaPresentazione = DataScadenzaOfferta

	  from document_bando with(nolock) where idHeader = @IdDoc


	Select 
	case
		when isdate(@DataScadenzaPresentazione) = 1 then dbo.GetStrTecDateUTC( cast(@DataScadenzaPresentazione as datetime))
		else ''
	end AS DataScadenzaPresentazione

END
GO
