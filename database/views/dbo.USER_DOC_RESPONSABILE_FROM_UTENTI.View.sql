USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_RESPONSABILE_FROM_UTENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[USER_DOC_RESPONSABILE_FROM_UTENTI] as 
select 
    
    a.attValue as pfuResponsabileUtente
    ,a.idpfu  AS ID_FROM
    
    from profiliutenteattrib a
     where a.dztnome='pfuResponsabileUtente'
    
GO
