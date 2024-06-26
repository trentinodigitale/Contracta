USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_FigliPfu_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Get_FigliPfu_I](@Codice as varchar (50), @IdMp as integer, @IdPfu as integer, 
                                    @dztNomeB as varchar (50), @dztNomeS as varchar (50)) AS
declare @IdTid as integer
declare @Tipo  as varchar(50)
declare @Livello as int
if @dztNomeB not in ('AreaGeograficaOperativaUtenteBuyer', 'ArtClasMerceologicaUtenteBuyer', '')
   begin
          raiserror ('Tipo [%s] non valido', 16, 1, @dztNomeB) 
          return  99
         
   end
if @dztNomeS not in ('AreaGeograficaOperativaUtenteSeller', 'ArtClasMerceologicaUtenteSeller', '')
   begin
          raiserror ('Tipo [%s] non valido', 16, 1, @dztNomeS) 
          return  99
         
   end
if @dztNomeS <> '' and @dztNomeB <> ''
   begin
         if  @dztNomeS like 'AreaGeografica%'
                   set @Tipo = 'ALLGPH'
         else
                   set @Tipo = 'ALLCSP'
         select @IdTid = dztIdTid 
           from DizionarioAttributi 
          where dztNome = @dztNomeS
   end
else
if @dztNomeS <> '' 
   begin
         set @Tipo = @dztNomeS
         select @IdTid = dztIdTid 
           from DizionarioAttributi 
          where dztNome = @dztNomeS
   end
else
   begin
         set @Tipo = @dztNomeB
         select @IdTid = dztIdTid 
           from DizionarioAttributi 
          where dztNome = @dztNomeB
   end
if exists (select * from v_DFPfu where vIdPfu = @IdPfu and vTipo = @Tipo)
   begin
           goto l_Filter
   end
if not exists (select * from MPDominiGerarchici where mpdgTipo = @IdTid and mpdgIdMp = @IdMp)
   begin
          set @IdMp = 0
          select @IdMp = IdMp from MarketPlace where substring (mpOpzioni, 1, 1) = '1'
          if @IdMp = 0
             begin
                    raiserror ('MetaMarketplace non trovato', 16, 1) 
                    return  99
             end
   end
if  @Codice = '-1'
   begin
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               a1.dgfoglia         as foglia
          from DominiGerarchici a1, DescsI b
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgLivello = 0
           and a1.dgDeleted = 0
        goto ExitStored
   end
if  @Codice = '0'
    begin
        select @Livello = min (dgLivello)
          from DominiGerarchici
         where dgTipoGerarchia = @IDTid 
           and IdDg in (select mpdgIdDg from MPDominiGerarchici where mpdgIdMp = @IdMp and mpdgDeleted = 0)
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               a1.dgfoglia         as foglia
          from DominiGerarchici a1, DescsI b
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and (a1.dgLivello = @Livello or a1.dgLivello = 0)
           and a1.IdDg in (select b1.IdDg 
                             from DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                            where b.IdDg = c.mpdgIdDg
                              and b.dgPath like b1.dgPath + '%'
                              and b.dgTIpoGerarchia = @IDTid
                              and b1.dgTIpoGerarchia = @IDTid
                              and c.mpdgDeleted = 0
                              and c.mpdgIdMp = @IdMp)
           and a1.dgDeleted = 0
       order by a1.dgPath
       goto ExitStored
   end
select a1.dgCodiceInterno  as CodiceInterno,
       a1.dgCodiceEsterno  as CodiceEsterno,
       b.dscTesto          as Descrizione,
       a1.dgLivello        as Livello,
       a1.dgfoglia         as foglia
  from DominiGerarchici a, DominiGerarchici a1, DescsI b
 where a1.dgIdDsc = b.IdDsc
   and a.IdDg in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   where b.IdDg = c.mpdgIdDg
                     and b1.dgPath like b.dgPath + '%'
                     and c.mpdgDeleted = 0
                     and c.mpdgIdMp = @IdMp)
   and a.dgTipoGerarchia = @IdTid
   and a1.dgTipoGerarchia = @IdTid
   and a.dgCodiceInterno = @Codice
   and a1.dgPath like a.dgPath + '%'
   and (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   and a1.dgDeleted = 0
order by a1.dgPath
 goto ExitStored
l_Filter:
if  @Codice = '-1'
   begin
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               a1.dgfoglia         as foglia
          from DominiGerarchici a1, DescsI b
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgLivello = 0
           and a1.dgDeleted = 0
        goto ExitStored
   end
if  @Codice = '0'
    begin
/*
        select @Livello = min (dgLivello)
          from DominiGerarchici
         where dgTipoGerarchia = @IDTid 
           and IdDg in (select vIdDg from v_DfPfu where vIdPfu = @IdPfu and vTipo = @Tipo)
*/
         select v.CodiceInterno, v.CodiceEsterno, v.Descrizione, v.Livello, v.Foglia
           from (
         select a1.dgCodiceInterno  as CodiceInterno,
                a1.dgCodiceEsterno  as CodiceEsterno,
                b.dscTesto          as Descrizione,
                a1.dgLivello        as Livello,
                a1.dgPath,
                a1.dgfoglia         as foglia
           from DominiGerarchici a1, DescsI b
          where a1.dgIdDsc = b.IdDsc
            and a1.dgTipoGerarchia = @IdTid
            and (a1.IdDg in (select c.vIdDg 
                              from v_DFPfu c
                             where c.vTIpo = @TIpo
                               and c.vIdPfu = @IdPfu))
            and a1.dgDeleted = 0
         union all
         select a1.dgCodiceInterno  as CodiceInterno,
                a1.dgCodiceEsterno  as CodiceEsterno,
                b.dscTesto          as Descrizione,
                a1.dgLivello        as Livello,
                a1.dgPath,
                a1.dgfoglia         as foglia
           from DominiGerarchici a1, DescsI b
          where a1.dgIdDsc = b.IdDsc
            and a1.dgTipoGerarchia = @IdTid
            and (a1.dgCodiceInterno = '0')
            and a1.dgDeleted = 0) v
         order by v.dgPath
         goto ExitStored
   end
select a1.dgCodiceInterno  as CodiceInterno,
       a1.dgCodiceEsterno  as CodiceEsterno,
       b.dscTesto          as Descrizione,
       a1.dgLivello        as Livello,
       a1.dgfoglia         as foglia
  from DominiGerarchici a, DominiGerarchici a1, DescsI b
 where a1.dgIdDsc = b.IdDsc
   and a.IdDg in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, v_DFPfu c
                   where b.IdDg = c.vIdDg
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgTIpoGerarchia = @IDTid
                     and b1.dgTIpoGerarchia = @IdTid
                     and c.vTIpo = @TIpo
                     and c.vIdPfu = @IdPfu)
   and a.dgTipoGerarchia = @IdTid
   and a1.dgTipoGerarchia = @IdTid
   and a.dgCodiceInterno = @Codice
   and a1.dgPath like a.dgPath + '%'
   and (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   and a1.dgDeleted = 0
order by a1.dgPath
 goto ExitStored
ExitStored:

GO
