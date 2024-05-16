USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PCP_DATI_EFORM]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_PCP_DATI_EFORM] 	(@idDoc int)
AS
BEGIN

	SET NOCOUNT ON

	select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) where idheader = @idDoc and operationType = 'CN16' order by idRow desc

END
GO
