USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Upd_CTL_DOC_Value_DA_DMATTR_TRY]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upd_CTL_DOC_Value_DA_DMATTR_TRY] (  @IdAzi INT
                            , @dztNome varchar(50)
                            , @IdDoc INT
                            , @sezione varchar(200)
                           )

AS
SET NOCOUNT ON

BEGIN TRY  
	execute Upd_CTL_DOC_Value_DA_DMATTR @IdAzi , @dztNome , @IdDoc ,@sezione
END TRY  
BEGIN CATCH  
END CATCH  

SET NOCOUNT OFF




GO
