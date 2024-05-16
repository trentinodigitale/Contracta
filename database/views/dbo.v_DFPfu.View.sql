USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_DFPfu]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create view [dbo].[v_DFPfu] as
select IdPfu as vIdPfu, IdDg as vIdDg, 'ArtClasMerceologicaUtenteBuyer' as vTipo
  from dfbpfucsp, DominiGerarchici, DizionarioAttributi
 where cast(cspValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'ArtClasMerceologicaUtenteBuyer'
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'ArtClasMerceologicaUtenteBuyer' as vTipo
  from dfspfucsp, DominiGerarchici, DizionarioAttributi
 where cast(cspValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'ArtClasMerceologicaUtenteBuyer'
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'ALLCSP' as vTipo
  from dfbpfucsp, DominiGerarchici, DizionarioAttributi
 where cast(cspValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'ArtClasMerceologicaUtenteBuyer'
   and IdDg not in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, dfspfucsp, dizionarioattributi
                   where b.dgCodiceInterno = cast(cspValue as varchar(20))
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgPath not like b1.dgPath 
                     and b.dgTIpoGerarchia = dztIdTid
                     and b1.dgTIpoGerarchia = dztIdTid
                     and dztNome = 'ArtClasMerceologicaUtenteSeller'
                     and dfspfucsp.IdPfu = dfbpfucsp.IdPfu)
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'ALLCSP' as vTipo
  from dfspfucsp, DominiGerarchici, DizionarioAttributi
 where cast(cspValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'ArtClasMerceologicaUtenteSeller'
   and IdDg not in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, dfbpfucsp, dizionarioattributi
                   where b.dgCodiceInterno = cast(cspValue as varchar(20))
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgPath not like b1.dgPath 
                     and b.dgTIpoGerarchia = dztIdTid
                     and b1.dgTIpoGerarchia = dztIdTid
                     and dztNome = 'ArtClasMerceologicaUtenteBuyer'
                     and dfspfucsp.IdPfu = dfbpfucsp.IdPfu)
union
select IdPfu as vIdPfu, IdDg as vIdDg, 'AreaGeograficaOperativaUtenteBuyer' as vTipo
  from dfbpfugph, DominiGerarchici, DizionarioAttributi
 where cast(gphValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'AreaGeograficaOperativaUtenteBuyer'
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'AreaGeograficaOperativaUtenteSeller' as vTipo
  from dfspfugph, DominiGerarchici, DizionarioAttributi
 where cast(gphValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'AreaGeograficaOperativaUtenteSeller'
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'ALLGPH' as vTipo
  from dfbpfugph, DominiGerarchici, DizionarioAttributi
 where cast(gphValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'AreaGeograficaOperativaUtenteBuyer'
   and IdDg not in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, dfspfugph, dizionarioattributi
                   where b.dgCodiceInterno = cast(gphValue as varchar(20))
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgPath not like b1.dgPath 
                     and b.dgTIpoGerarchia = dztIdTid
                     and b1.dgTIpoGerarchia = dztIdTid
                     and dztNome = 'AreaGeograficaOperativaUtenteSeller'
                     and dfspfugph.IdPfu = dfbpfugph.IdPfu)
union 
select IdPfu as vIdPfu, IdDg as vIdDg, 'ALLGPH' as vTipo
  from dfspfugph, DominiGerarchici, DizionarioAttributi
 where cast(gphValue as varchar(20)) = dgCodiceInterno
   and dgTipoGerarchia = dztIdTid
   and dgDeleted = 0
   and dztNome = 'AreaGeograficaOperativaUtenteSeller'
   and IdDg not in (select b1.IdDg 
                    from DominiGerarchici b, DominiGerarchici b1, dfbpfugph, dizionarioattributi
                   where b.dgCodiceInterno = cast(gphValue as varchar(20))
                     and b1.dgPath like b.dgPath + '%'
                     and b.dgPath not like b1.dgPath 
                     and b.dgTIpoGerarchia = dztIdTid
                     and b1.dgTIpoGerarchia = dztIdTid
                     and dztNome = 'AreaGeograficaOperativaUtenteBuyer'
                     and dfspfugph.IdPfu = dfbpfugph.IdPfu)
GO
