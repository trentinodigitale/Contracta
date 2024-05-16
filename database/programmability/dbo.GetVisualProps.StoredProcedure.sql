USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetVisualProps]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetVisualProps]
AS
SELECT CAST (avpIdMp AS VARCHAR(10)) + 
       '_'                           + 
       LOWER (avpContext)                    +
       '_'                           +
       LOWER(a.dztNome)                 + 
       '_'                           +
        LOWER(b.dztNome)                       AS gKey,
       avpValue                        AS gValue
  FROM DizionarioAttributi a,DizionarioAttributi b,
       AttrVisualProp
 WHERE avpIdDzt = a.IdDzt AND avpIdDztCrt=b.IdDzt
GO
