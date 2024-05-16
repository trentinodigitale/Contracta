USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMpGerarchiaAttributiFigli_FRA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Gerarchia MpGerarchiaAttributi Figli
Data: 20/6/2001
*/
CREATE PROCEDURE [dbo].[GetMpGerarchiaAttributiFigli_FRA] (@Idmp int,@mpgaContesto varchar(50),@IdMpga int) AS
begin
--nel caso in cui non esiste il MP
if not exists (select * from MPGerarchiaAttributi
where mpgaIdmp=@Idmp  and mpgaContesto=@mpgaContesto and mpgaDeleted=0  ) 	begin
				set @Idmp=0
				end
if @IdMpga=-1 	begin 
select b.*, cast(mlngDesc_FRA as nvarchar(200))  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
where  a.mpgaIdmp=@Idmp and b.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' and b.mpgaLivello=1 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and b.mpgaIdDzt=-1
and b.mpgaDescr=IdMultiLng and a.mpgaDeleted=0 and b.mpgaDeleted=0 and mlngCancellato=0
UNION --per le foglie
select b.*, dscTesto  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsFRA
where  a.mpgaIdmp=@Idmp and  b.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' and b.mpgaLivello=1 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and b.mpgaIdDzt<>-1 and b.mpgaIdDzt=IdDzt
and dztIdDsc=IdDsc  and a.mpgaDeleted=0 and b.mpgaDeleted=0 and dztDeleted=0
order by b.mpgaPath
		end
else		begin		
--per i nodi
select b.*, cast(mlngDesc_FRA as nvarchar(200))  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,Multilinguismo
where a.IdMpga=@IdMpga and a.mpgaIdmp=@Idmp and  b.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and b.mpgaIdDzt=-1
and (b.mpgaLivello = a.mpgaLivello + 1 or b.mpgaLivello = a.mpgaLivello)
and b.mpgaDescr=IdMultiLng and a.mpgaDeleted=0 and b.mpgaDeleted=0 and mlngCancellato=0
UNION --per le foglie
select b.*, dscTesto  as Descrizione  from MPGerarchiaAttributi b,MPGerarchiaAttributi a,DizionarioAttributi, DescsFRA
where a.IdMpga=@IdMpga and a.mpgaIdmp=@Idmp and  b.mpgaIdmp=@Idmp and b.mpgaPath like a.mpgaPath+'%' 
and a.mpgaContesto=@mpgaContesto and b.mpgaContesto=@mpgaContesto and b.mpgaIdDzt<>-1 and b.mpgaIdDzt=IdDzt
and (b.mpgaLivello = a.mpgaLivello + 1 or b.mpgaLivello = a.mpgaLivello)
and dztIdDsc=IdDsc  and a.mpgaDeleted=0 and b.mpgaDeleted=0 and dztDeleted=0
order by b.mpgaPath
		end
end
GO
