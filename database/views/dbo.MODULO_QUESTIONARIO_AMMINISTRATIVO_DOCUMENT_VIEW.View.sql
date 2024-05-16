USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MODULO_QUESTIONARIO_AMMINISTRATIVO_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MODULO_QUESTIONARIO_AMMINISTRATIVO_DOCUMENT_VIEW]
AS
SELECT C.*
      --,case when isnull(C1.StatoFunzionale,'') <> 'InLavorazione'  or  ISNULL(c1.SIGN_HASH,'')<>'' or ISNULL(c1.SIGN_LOCK,'')<>''  then 'no'
      ,CASE 
        WHEN isnull(C1.StatoFunzionale, '') <> 'InLavorazione'
          THEN 'no'
        ELSE 'si'
        END AS colonnatecnica
      ,A.aziVenditore

FROM ctl_doc C WITH (NOLOCK)
      LEFT JOIN ctl_doc C1 WITH (NOLOCK) ON C1.id = C.LinkedDoc
      INNER JOIN ProfiliUtente P WITH (NOLOCK) ON P.IdPfu = C.IdPfu
      INNER JOIN Aziende A WITH (NOLOCK) ON A.IdAzi = P.pfuIdAzi
WHERE c.TipoDoc = 'MODULO_QUESTIONARIO_AMMINISTRATIVO'

GO
