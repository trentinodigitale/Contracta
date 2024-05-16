USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[IsArticoloFittizio]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[IsArticoloFittizio] (@IdDsc INT, @bInserisci bit OUTPUT) as
DECLARE @dscTesto AS NVARCHAR (4000)
set @bInserisci = 0
SELECT @dscTesto = dscTesto FROM descsi WHERE IdDsc = @IdDsc
IF @dscTesto = 'articolo dimostrativo (da cancellare contestualmente all''inserimento della tabella prodotti dell''azienda)'
begin
         set @bInserisci = 1
         return   
end
GO
