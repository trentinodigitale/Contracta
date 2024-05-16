USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREGARA_TipologiaAtti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[PREGARA_TipologiaAtti] as

select 
	C.ID,
	C.id as indrow,
	C.Titolo as Descrizione,	
	C.Titolo as DescrAttach,
	cast(C.Body as nvarchar(4000)) as DescrizioneRichiesta,
	' DescrizioneRichiesta , Descrizione F3_DESC ' as NotEditable,
	C.Titolo as AnagDoc,
	1 as Interno ,
	Allegato,
	Allegato as AllegatoRichiesto,
	ContestoUsoDoc,
	C.Titolo as F3_DESC,
	Allegato as F3_SIGN_ATTACH,
	1 as F4_SIGN_LOCK
from CTL_DOC  C
left join [Document_Anag_documentazione] on C.ID=IDHEader
  where C.TipoDoc='ANAG_DOCUMENTAZIONE' and C.Deleted=0 and c.statofunzionale='Pubblicato'
GO
