USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InserisciDescrArticolo]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[InserisciDescrArticolo] (@IdDsc INT, @bInserisci bit OUTPUT) as
DECLARE @IdCsp AS VARCHAR(20)
DECLARE @dscTesto AS NVARCHAR (4000)
set @bInserisci = 0
SELECT top 2 IdArt 
  FROM Articoli 
 WHERE artIdDscDescrizione = @IdDsc
IF @@rowcount > 1
   begin
         set @bInserisci = 1
         return
   end
set @IdCsp = NULL
SELECT @IdCsp = dgCodiceINterno 
  FROM DOminiGerarchici
 WHERE dgIdDsc = @IdDsc
    AND dgTipoGerarchia = 16
IF @IdCsp is not NULL 
begin
         set @bInserisci = 1
         return
end
GO
