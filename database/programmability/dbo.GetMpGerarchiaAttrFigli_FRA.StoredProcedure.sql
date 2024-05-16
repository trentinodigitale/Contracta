USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMpGerarchiaAttrFigli_FRA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Gerarchia MpGerarchiaAttributi Figli
Data: 20/6/2001
*/
CREATE PROCEDURE [dbo].[GetMpGerarchiaAttrFigli_FRA] (@Idmp INT,@mpgaContesto VARCHAR(50),@IdMpga INT) AS
begin
--nel caso in cui non esiste il MP
IF not exists (SELECT * FROM MPGerarchiaAttributi
WHERE mpgaIdmp=@Idmp  AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0  )       BEGIN
                        set @Idmp=0
                        END
IF @IdMpga=-1       BEGIN 
SELECT b.*, cast(mlngDesc_FRA AS NVARCHAR(200))  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
WHERE  a.mpgaIdmp=@Idmp AND b.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' AND b.mpgaLivello=1 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND b.mpgaIdDzt=-1
and b.mpgaDescr=IdMultiLng AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND mlngCancellato=0
UNION --per le foglie
SELECT b.*, dscTesto  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsFRA
WHERE  a.mpgaIdmp=@Idmp AND  b.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' AND b.mpgaLivello=1 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND b.mpgaIdDzt<>-1 AND b.mpgaIdDzt=IdDzt
and dztIdDsc=IdDsc  AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND dztDeleted=0
ORDER BY b.mpgaPath
            END
ELSE            BEGIN            
--per i nodi
SELECT b.*, cast(mlngDesc_FRA AS NVARCHAR(200))  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
WHERE a.IdMpga=@IdMpga AND a.mpgaIdmp=@Idmp AND  b.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND b.mpgaIdDzt=-1
and (b.mpgaLivello = a.mpgaLivello + 1 or b.mpgaLivello = a.mpgaLivello)
and b.mpgaDescr=IdMultiLng AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND mlngCancellato=0
UNION --per le foglie
SELECT b.*, dscTesto  AS Descrizione  FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsFRA
WHERE a.IdMpga=@IdMpga AND a.mpgaIdmp=@Idmp AND  b.mpgaIdmp=@Idmp AND b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto AND b.mpgaIdDzt<>-1 AND b.mpgaIdDzt=IdDzt
and (b.mpgaLivello = a.mpgaLivello + 1 or b.mpgaLivello = a.mpgaLivello)
and dztIdDsc=IdDsc  AND a.mpgaDeleted=0 AND b.mpgaDeleted=0 AND dztDeleted=0
ORDER BY b.mpgaPath
            END
end
GO
