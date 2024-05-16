USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMpGerarchiaAttributiPadre_Lng4]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Gerarchia MpGerarchiaAttributi Padre
Data: 20/6/2001
*/
CREATE PROCEDURE [dbo].[GetMpGerarchiaAttributiPadre_Lng4] (@Idmp int,@mpgaContesto varchar(50),@IdMpga int) AS
begin
--nel caso in cui non esiste il MP
if not exists (select * from MPGerarchiaAttributi
where mpgaIdmp=@Idmp  and mpgaContesto=@mpgaContesto and mpgaDeleted=0  ) 	begin
				set @Idmp=0
				end
--per i nodi
select a.*, cast(mlngDesc_Lng4 as nvarchar(200))  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
where b.IdMpga=@IdMpga and b.mpgaIdmp=@Idmp and  a.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and a.mpgaIdDzt=-1
and a.mpgaDescr=IdMultiLng and a.mpgaDeleted=0 and b.mpgaDeleted=0 and mlngCancellato=0
UNION --per le foglia
select a.*, dscTesto  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsLng4
where b.IdMpga=@IdMpga and a.mpgaIdmp=@Idmp and  b.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and a.mpgaIdDzt<>-1 and a.mpgaIdDzt=IdDzt
and dztIdDsc=IdDsc and a.mpgaDeleted=0 and b.mpgaDeleted=0 and dztDeleted=0
order by a.mpgaPath
end
GO
