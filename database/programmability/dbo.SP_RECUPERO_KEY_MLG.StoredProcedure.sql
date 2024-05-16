USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_RECUPERO_KEY_MLG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_RECUPERO_KEY_MLG] (
@IdDoc INT

)
AS
 Select LIB_Multilinguismo.* from CTL_DOC_VALUE
 inner join LIB_Multilinguismo on ML_KEY=Value and ML_MODULE='MODELLI_LOTTI'
 where idHeader=@IdDoc 
 and DSE_ID='MODELLI' and DZT_NAME='Descrizione'
 
 
GO
