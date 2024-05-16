USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



---------------------------------------------------------------
--[OK]Vista usata per il from sul doc user_doc
---------------------------------------------------------------

CREATE VIEW [dbo].[USER_DOC_FROM_AZIENDA] 
AS

SELECT 
    IdAzi
  , IdAzi AS ID_FROM
  ,profiliutente.idpfu as ID_DOC
  ,IdAzi as Azienda
  , pfuProfili
  ,aziProfili  
  , case 
			when dbo.PARAMETRI('ANAG_DOCUMENTAZIONE_DOCUMENT','AreaValutazione','HIDE','',-1)='0' then 1
			when dbo.PARAMETRI('ANAG_DOCUMENTAZIONE_DOCUMENT','AreaValutazione','HIDE','',-1)<>'0' then 0   
			when p1.IdPfu is null then 0 else 1 end as ProfiloAlbo
  FROM AZIENDE with (nolock)
  inner join profiliutente with (nolock) on idazi=pfuidazi
  left outer join profiliutenteattrib p1 with (nolock) on p1.idpfu=profiliutente.idpfu  and p1.dztNome = 'Profilo' and p1.attValue in (  'ALBO_VALUTATORE'  )


GO
