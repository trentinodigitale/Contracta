USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_TESTATA_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[BANDO_TESTATA_view] as
select d.* , DataPresentazioneRisposte ,NumeroBUR , DataBUR , TipoBando  ,TipoAppalto ,RichiestaQuesito ,StatoBando    from 
ctl_doc d inner join dbo.Document_Bando on id = idheader

GO
