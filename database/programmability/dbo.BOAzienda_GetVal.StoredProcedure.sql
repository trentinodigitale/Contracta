USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_GetVal]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_GetVal] (@IdAzi INT, @IdDzt INT, @Valore NVARCHAR(20) OUTPUT)
AS
DECLARE @TipoMem INT
DECLARE @IdVat INT
    
SELECT @TipoMem = ValoriAttributi.vatTipoMem, @IdVat = ValoriAttributi.IdVat 
  FROM ValoriAttributi, DfVatAzi
 WHERE ValoriAttributi.IdVat = DfVatAzi.IdVat 
   AND ValoriAttributi.VatIdDzt = @IdDzt
   AND DfVatAzi.IdAzi = @IdAzi
IF NOT(@TipoMem IS NULL)
   BEGIN
        IF (@TipoMem = 1)
            SELECT @Valore = ValoriAttributi_Int.vatValore FROM ValoriAttributi_Int  WHERE ValoriAttributi_Int.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 2)
            SELECT @Valore = CONVERT(varchar(20),ValoriAttributi_Money.vatValore,2) FROM ValoriAttributi_Money  WHERE ValoriAttributi_Money.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 3)
            SELECT @Valore = ValoriAttributi_Float.vatValore FROM ValoriAttributi_Float  WHERE ValoriAttributi_Float.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 4)
            SELECT @Valore = ValoriAttributi_NVarChar.vatValore FROM ValoriAttributi_NVarChar  WHERE ValoriAttributi_NVarChar.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 5)
            SELECT @Valore = ValoriAttributi_Datetime.vatValore FROM ValoriAttributi_Datetime  WHERE ValoriAttributi_Datetime.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 6) 
            SELECT @Valore =  ValoriAttributi_Descrizioni.vatIdDsc 
              FROM ValoriAttributi_Descrizioni
             WHERE ValoriAttributi_Descrizioni.IdVat = @IdVat
        ELSE
        IF (@TipoMem = 7)
            SELECT @Valore = ValoriAttributi_Keys.vatValore FROM ValoriAttributi_Keys  WHERE ValoriAttributi_Keys.IdVat = @IdVat
   END 
SELECT @Valore = ISNULL(@Valore,'Null')
GO
