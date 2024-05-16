USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Di_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Di_Aggiorna] (@lastDate DATETIME = NULL OUTPUT)      
AS
      DECLARE @ConfDate DATETIME
      SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Document'
      IF (@ConfDate IS NULL) /* Non Accade */
                              BEGIN
                                    SELECT * FROM v_Document ORDER BY Id
                              END      
                        ELSE
                              BEGIN
                                    IF (@lastDate IS NULL)
                                                BEGIN
                                                   SELECT * FROM v_Document ORDER BY Id
                                                END      
                                          ELSE
                                                BEGIN
                                                      IF (@lastDate < @ConfDate)
                                                                        BEGIN
                                                                              SELECT * 
                                                                              FROM v_document
                                                                              WHERE Ultimamod > @lastDate
                                                                              ORDER BY Id
                                                                              SELECT @lastDate = @ConfDate
                                                                        END 
                                                END
                              END
      
GO
