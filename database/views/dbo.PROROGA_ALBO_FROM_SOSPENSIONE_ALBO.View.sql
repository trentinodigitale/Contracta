USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROROGA_ALBO_FROM_SOSPENSIONE_ALBO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PROROGA_ALBO_FROM_SOSPENSIONE_ALBO] as
select 
id as ID_FROM,
Azienda

from 
CTL_DOC where TipoDoc='SOSPENSIONE_ALBO'
GO
