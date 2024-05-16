USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateCompanyLink]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateCompanyLink] (
                                     @cur@IdAzi INT,
                                     @prevIdAzi INT
                                   )
AS
                                    
INSERT CompanyLink (clCurIdAzi, clPrevIdAzi)
       VALUES (@cur@IdAzi, @prevIdAzi)
IF @@ERROR <> 0
   BEGIN 
        RAISERROR ('Errore "INSERT" CompanyLink (1)', 16, 1)
        RETURN 99
   END
INSERT CompanyLink (clCurIdAzi, clPrevIdAzi)
SELECT @cur@IdAzi, clPrevIdAzi
  FROM CompanyLink
 WHERE clCurIdAzi = @prevIdAzi
IF @@ERROR <> 0
   BEGIN 
        RAISERROR ('Errore "INSERT" CompanyLink (2)', 16, 1)
        RETURN 99
   END
GO
