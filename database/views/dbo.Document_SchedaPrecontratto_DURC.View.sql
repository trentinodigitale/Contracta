USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SchedaPrecontratto_DURC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_SchedaPrecontratto_DURC] as
select idMsg,
idAziControllata as DURC_Fornitore ,
TipoComunicazione as DURC_TipoComunicazione,
DataRilascio as DURC_DataRilascio,
Esito as DURC_Esito ,
NoteComunicazione as DURC_NoteComunicazione,
DURC_DataControllo,
DURC_DataScadenza,
idSchedaPrecontratto
from Document_Aziende_Comunicazioni

GO
