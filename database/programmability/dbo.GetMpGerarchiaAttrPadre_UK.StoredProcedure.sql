USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMpGerarchiaAttrPadre_UK]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Gerarchia MpGerarchiaAttributi Padre
Data: 20/6/2001
*/
CREATE PROCEDURE [dbo].[GetMpGerarchiaAttrPadre_UK] (@Idmp INT,@mpgaContesto VARCHAR(50),@IdMpga INT) AS
begin
--nel caso in cui non esiste il MP
IF not exists (SELECT * FROM MPGerarchiaAttributi
WHERE mpgaIdmp=@Idmp  AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0  )       BEGIN
                        set @Idmp=0
                        END
--per i nodi
SELECT a.*, cast(mlngDesc_UK AS NVARCHAR(200))  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
WHERE b.IdMpga=@IdMpga AND b.mpgaIdmp=@Idmp AND  a.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND a.mpgaIdDzt=-1
and a.mpgaDescr=IdMultiLng AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND mlngCancellato=0
UNION --per le foglia
SELECT a.*, dscTesto  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsUK
WHERE b.IdMpga=@IdMpga AND a.mpgaIdmp=@Idmp AND  b.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND a.mpgaIdDzt<>-1 AND a.mpgaIdDzt=IdDzt
and dztIdDsc=IdDsc AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND dztDeleted=0 
ORDER BY a.mpgaPath
end
GO
