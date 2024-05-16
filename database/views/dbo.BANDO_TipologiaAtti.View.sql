USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_TipologiaAtti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE View [dbo].[BANDO_TipologiaAtti] as
--select 
--	id,
--	id as indrow, 
--	DMV_DescML as  Descrizione ,
--	DMV_DescML as  DescrizioneRichiesta,
--	' DescrizioneRichiesta , Descrizione ' as NotEditable,
--	'' as AnagDoc,
--	1 as Interno
--from LIB_DomainValues
--where DMV_DM_ID = 'TipologiaAtti'

--union

select 
	C.ID,
	C.id as indrow,
	C.Titolo as Descrizione,
	C.Titolo as DescrAttach,
	cast(C.Body as nvarchar(4000)) as DescrizioneRichiesta,
	' DescrizioneRichiesta , Descrizione ' as NotEditable,
	C.Titolo as AnagDoc,
	1 as Interno ,
	Allegato,
	Allegato as AllegatoRichiesto,
	ContestoUsoDoc

from CTL_DOC  C
left join [Document_Anag_documentazione] on C.ID=IDHEader
  where C.TipoDoc='ANAG_DOCUMENTAZIONE' and C.Deleted=0 and c.statofunzionale='Pubblicato'


GO
