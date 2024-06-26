USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_PadriSA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Get_PadriSA] (@IdAzi AS INTeger, @Path AS VARCHAR(100)) AS
DECLARE @MinLen AS INTeger
set @MinLen = 5
IF @Path = '-1'
   begin
         /* restituisce sempre un recordset vuoto */
         SELECT cast(@Idazi AS VARCHAR (10)) + '#' + a.Path AS Chiave,
                isNULL(b1.Valore, '') + ' ' + isNULL(b2.Valore, '') AS Descrizione
           FROM az_struttura a, az_attributi b1, az_attributi b2
          WHERE a.idaz = b1.idaz
            AND a.idstrutt = b1.idstrutt       
            AND a.idaz = b2.idaz
            AND a.idstrutt = b2.idstrutt
            AND b1.idattr = 4
            AND b2.idattr = 3
            AND a.path like @Path
            AND a.idaz = -1
          goto ExitStored
   end
IF len(@Path) = @MinLen
   begin
         SELECT cast(@Idazi AS VARCHAR (10)) + '#' + a.Path AS Chiave,
                isNULL(b1.Valore, '') + ' ' + isNULL(b2.Valore, '') AS Descrizione
          FROM az_struttura a, az_attributi b1, az_attributi b2
         WHERE a.idaz = b1.idaz
           AND a.idstrutt = b1.idstrutt       
           AND a.idaz = b2.idaz
           AND a.idstrutt = b2.idstrutt
           AND b1.idattr = 4
           AND b2.idattr = 3
           AND a.path like @Path
           AND a.idaz = @Idazi
         goto ExitStored
   End
   SELECT cast(@Idazi AS VARCHAR (10)) + '#' + a.Path AS Chiave,
          isNULL(b1.Valore, '') + ' ' + isNULL(b2.Valore, '') AS Descrizione 
     FROM az_struttura a, az_struttura z, az_attributi b1, az_attributi b2
    WHERE a.idaz = b1.idaz
      AND a.idstrutt = b1.idstrutt       
      AND a.idaz = z.idaz
      AND a.idstrutt = z.idstrutt       
      AND a.idaz = b2.idaz
      AND a.idstrutt = b2.idstrutt
      AND b1.idattr = 4
      AND b2.idattr = 3
      AND a.path like left (@path, len(a.path))
      AND a.idaz = @Idazi
ExitStored:
GO
