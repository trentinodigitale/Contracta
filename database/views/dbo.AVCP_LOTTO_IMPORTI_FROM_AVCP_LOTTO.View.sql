USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_LOTTO_IMPORTI_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[AVCP_LOTTO_IMPORTI_FROM_AVCP_LOTTO] as
select *,
idheader as ID_FROM
from document_AVCP_Importi




GO
