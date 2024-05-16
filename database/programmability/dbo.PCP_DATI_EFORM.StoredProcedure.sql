USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PCP_DATI_EFORM]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PCP_DATI_EFORM] 	(@idDoc int, @Tipo_E_FORM varchar(100)='CN16')
AS
BEGIN

	SET NOCOUNT ON

	select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) 
		where idheader = @idDoc and operationType = @Tipo_E_FORM order by idRow desc

END
GO
