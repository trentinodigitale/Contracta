USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_8_Dati_Base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[REPORT_8_Dati_Base] as 
select case when isnull(c.ProtocolloBando, '') <> '' then '  ' + c.ProtocolloBando
            else ' X' + right('00000000' + cast(a.idprogetto as varchar), 8)
       end                                                                  as ProtocolloBando
     , convert(char(10), a.DataOperazione, 121)                             as Periodo
     , datediff (dd, a.DataOperazione, isnull(c.DataOperazione, getdate())) as Durata
  from document_progetti a 
    LEFT OUTER JOIN document_progetti c ON a.linkmodified =  c.linkmodified
 where a.statoprogetto not in ('modified', 'saved')
	and a.deleted=0 and c.deleted=0 
   and a.idprogetto in (select top 1 b.idprogetto from document_progetti b
        where a.linkmodified = b.linkmodified and b.versione = '1.0' order by b.dataoperazione)
   and (c.idprogetto in (select top 1 d.idprogetto from document_progetti d 
   where c.linkmodified = d.linkmodified and d.versione = '1.1' order by d.dataoperazione)
or (c.idprogetto in (select top 1 d.idprogetto from document_progetti d  
   where c.linkmodified = d.linkmodified and d.versione = '2.1' order by d.dataoperazione)
            and c.linkmodified not in (select d.linkmodified from document_progetti d 
   where c.linkmodified = d.linkmodified and d.versione = '2.0' and d.protocollobando <> ''))
        or (c.idprogetto in (select top 1 d.idprogetto from document_progetti d  
   where c.linkmodified = d.linkmodified and d.versione = '2.0' order by d.dataoperazione)
            and c.protocollobando <> '' and c.linkmodified not in (select d.linkmodified from document_progetti d 
   where c.linkmodified = d.linkmodified and d.versione = '1.1' ))
        or (c.idprogetto in (select top 1 d.idprogetto from document_progetti d 
   where c.linkmodified = d.linkmodified and d.versione = '1.0' and d.idprogetto <> a.idprogetto order by d.dataoperazione)
             and c.linkmodified not in (select d.linkmodified from document_progetti d 
   where c.linkmodified = d.linkmodified and d.versione >= '1.1')))









GO
