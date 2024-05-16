USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetFigliPfuDaConAziende_Lng2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFigliPfuDaConAziende_Lng2](@Codice as varchar (50), @IdMp as integer, @IdPfu as integer, 
                                           @dztNomeB as varchar (50), @dztNomeS as varchar (50)) AS
declare @Livello as  int
declare @IdTid as integer
declare @Tipo  as varchar(50)
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
               f.Conta             as Conta
          from DominiGerarchici a1, DescsLng2 b, ConCSP f
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgCodiceInterno = f.concspcode
           and a1.dgLivello = 0
           and a1.dgDeleted = 0
           and f.conIdMp = @IdMp
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
               f.Conta             as Conta
          from DominiGerarchici a1, DescsLng2 b, ConCSP f
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgCodiceInterno = f.concspcode
           and (a1.dgLivello = 1 or a1.dgLivello = 0)
           and a1.IdDg in (select b1.IdDg 
                             from DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                            where b.IdDg = c.mpdgIdDg
                              and b.dgPath like b1.dgPath + '%'
                              and b.dgPath like b1.dgPath + '%'
                              and b.dgTIpoGerarchia = @IDTid
                              and c.mpdgDeleted = 0
                              and c.mpdgIdMp = @IdMp)
           and a1.dgDeleted = 0
           and f.conIdMp = @IdMp
        order by a1.dgPath
        goto ExitStored
   end
select a1.dgCodiceInterno  as CodiceInterno,
       a1.dgCodiceEsterno  as CodiceEsterno,
       b.dscTesto          as Descrizione,
       a1.dgLivello        as Livello,
       f.Conta             as Conta
  from DominiGerarchici a, DominiGerarchici a1, DescsLng2 b, ConCSP f
 where a1.dgIdDsc = b.IdDsc
   and a.IdDg in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   where b.IdDg = c.mpdgIdDg
                     and b1.dgPath like b.dgPath + '%'
                     and c.mpdgDeleted = 0
                     and c.mpdgIdMp = @IdMp)
   and a1.dgCodiceInterno = f.concspcode
   and a.dgTipoGerarchia = @IdTid
   and a1.dgTipoGerarchia = @IdTid
   and a.dgCodiceInterno = @Codice
   and a1.dgPath like a.dgPath + '%'
   and (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   and a1.dgDeleted = 0
   and f.conIdMp = @IdMp
order by a1.dgPath
goto ExitStored
L_Filter:
if  @Codice = '-1'
   begin
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               f.Conta             as Conta
          from DominiGerarchici a1, DescsLng2 b, ConCSP f
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgCodiceInterno = f.concspcode
           and a1.dgLivello = 0
           and a1.dgDeleted = 0
           and f.conIdMp = @IdMp
        goto ExitStored
   end
if  @Codice = '0'
   begin
        select @Livello = min (dgLivello)
          from DominiGerarchici
         where dgTipoGerarchia = @IDTid 
           and IdDg in (select mpdgIdDg from MPDominiGerarchici where mpdgIdMp = @IdMp and mpdgDeleted = 0)
        select v.CodiceInterno, v.CodiceEsterno, v.Descrizione, v.Livello, v.Conta
          from (
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               f.Conta             as Conta,
               a1.dgPath
          from DominiGerarchici a1, DescsLng2 b, ConCSP f
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgCodiceInterno = f.concspcode
           and (a1.IdDg in (select c.vIdDg 
                              from v_DFPfu c
                             where c.vTIpo = @TIpo
                               and c.vIdPfu = @IdPfu))
           and a1.dgDeleted = 0
           and f.conIdMp = @IdMp
        union all
        select a1.dgCodiceInterno  as CodiceInterno,
               a1.dgCodiceEsterno  as CodiceEsterno,
               b.dscTesto          as Descrizione,
               a1.dgLivello        as Livello,
               f.Conta             as Conta,
               a1.dgPath
          from DominiGerarchici a1, DescsLng2 b, ConCSP f
         where a1.dgIdDsc = b.IdDsc
           and a1.dgTipoGerarchia = @IdTid
           and a1.dgCodiceInterno = f.concspcode
           and f.conIdMp = @IdMp
           and (a1.dgCodiceInterno = '0')) v
        order by v.dgPath
        goto ExitStored
   end
select a1.dgCodiceInterno  as CodiceInterno,
       a1.dgCodiceEsterno  as CodiceEsterno,
       b.dscTesto          as Descrizione,
       a1.dgLivello        as Livello,
       f.Conta             as Conta
  from DominiGerarchici a, DominiGerarchici a1, DescsLng2 b, ConCSP f
 where a1.dgIdDsc = b.IdDsc
   and a.IdDg in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, v_DFPfu c
                   where b.IdDg = c.vIdDg
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgTIpoGerarchia = @IDTid
                     and b1.dgTIpoGerarchia = @IdTid
                     and c.vTIpo = @TIpo
                     and c.vIdPfu = @IdPfu)
   and a1.dgCodiceInterno = f.concspcode
   and a.dgTipoGerarchia = @IdTid
   and a1.dgTipoGerarchia = @IdTid
   and a.dgCodiceInterno = @Codice
   and a1.dgPath like a.dgPath + '%'
   and (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   and a1.dgDeleted = 0
   and f.conIdMp = @IdMp
order by a1.dgPath
goto ExitStored
ExitStored:
GO
