USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetScadenzaContratto]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.GetScadenzaContratto    Script Date: 29/06/2000 16.12.34 ******/
/****** Object:  Stored Procedure dbo.GetScadenzaContratto    Script Date: 27/06/00 16.54.04 ******/
CREATE PROCEDURE [dbo].[GetScadenzaContratto](@IdAzi INT, @ScadenzaContratto AS DATETIME OUTPUT, @bScaduto AS bit OUTPUT) AS
DECLARE @CurDate           AS DATETIME
set @bScaduto          = 0
set @CurDate           = GETDATE()
set @ScadenzaContratto = NULL
SELECT @ScadenzaContratto = ScadenzaContratto 
  FROM Aziende_Informazioni
 WHERE IdAzi = @IdAzi
IF @ScadenzaContratto IS NULL
   begin
          set @ScadenzaContratto = '01/01/1900'
   end
IF @ScadenzaContratto < @CurDate
   begin
         set @bScaduto = 1      
   end
    
GO
