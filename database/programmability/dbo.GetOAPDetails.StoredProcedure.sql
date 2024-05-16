USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetOAPDetails]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetOAPDetails] 
 @VcIdOap VARCHAR(8000),
 @VcArtcode1 NVARCHAR(4000), 
 @VcArtcode2 NVARCHAR(4000),
 @VcArtcode3 NVARCHAR(4000), 
 @VcArtcode4 NVARCHAR(4000)
as
   begin
       
      DECLARE @stringa_rec1 NVARCHAR(4000)
      DECLARE @stringa_rec2 NVARCHAR(4000)
      set @stringa_rec1 = 'SELECT Distinct convert(varchar(10),dataScad,20) AS dataScad FROM oapdettaglio WHERE (idoap in ('+@VcIdOap+') AND artcode in ('
      set @stringa_rec2 = 'SELECT IdOaP,ArtCode,QO,SottoTipoRiga,Modify,QTAOrdPrec,SottoTipoRigaOrdPrec,convert(varchar(10),dataScad,20) AS dataScad,CodiceArtForn  FROM oapdettaglio WHERE (idoap in ('+@VcIdOap+') AND artcode in ('
      --print @stringa_rec1+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY datascad asc'
      --print @stringa_rec2+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY datascad asc'
      execute (@stringa_rec1+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY datascad asc')
      execute (@stringa_rec2+@VcArtcode1 +@VcArtcode2+@VcArtcode3+@VcArtcode4 + ')) ORDER BY ArtCode desc,datascad  desc')
       
   end
GO
