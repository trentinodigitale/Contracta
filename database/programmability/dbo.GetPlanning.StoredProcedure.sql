USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPlanning]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPlanning] 
 @VcIdOap VARCHAR(8000),
 @VcArtcode1 NVARCHAR(4000), 
 @VcArtcode2 NVARCHAR(4000),
 @VcArtcode3 NVARCHAR(4000), 
 @VcArtcode4 NVARCHAR(4000)
AS
   BEGIN
       
      DECLARE @stringa_rec1 NVARCHAR(4000)
      DECLARE @stringa_rec2 NVARCHAR(4000)
      SET @stringa_rec1 = 'SELECT DISTINCT CONVERT(VARCHAR(10),dataScad,20) AS dataScad FROM oapdettaglio,oapdettaglioriga WHERE oapdettaglio.IdDett=oapdettaglioriga.IdDett AND InsForn=0 AND (idoap in ('+@VcIdOap+') AND artcode in ('
      SET @stringa_rec2 = 'SELECT IdOaP,ArtCode,QO,SottoTipoRiga,Modify,QTAOrdPrec,SottoTipoRigaOrdPrec,CONVERT(VARCHAR(10),dataScad,20) AS dataScad,CodiceArtForn  FROM oapdettaglio,oapdettaglioriga WHERE oapdettaglio.IdDett=oapdettaglioriga.IdDett AND InsForn=0 AND (idoap in ('+@VcIdOap+') AND artcode in ('
      EXECUTE (@stringa_rec1+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY datascad ASC')
      EXECUTE (@stringa_rec2+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY ArtCode desc,datascad  DESC')
       
   END
GO
