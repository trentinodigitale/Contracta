USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_DOCUMENTAZIONE_RICHIESTA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_DOCUMENTAZIONE_RICHIESTA_FROM_USER] as

select 
	C.ID,
	P.idpfu as ID_FROM,
	C.Titolo as Descrizione,
	cast(C.Body as nvarchar(4000)) as DescrizioneRichiesta,
	' DescrizioneRichiesta ' as NotEditable,
	C.Titolo as AnagDoc,
	1 as Obbligatorio,
	D.Allegato as AllegatoRichiesto

from CTL_DOC C 
cross join ProfiliUtente P
inner join Document_Anag_documentazione D on C.ID=D.IDHEADER
where C.TipoDoc='ANAG_DOCUMENTAZIONE' and D.Albo=1
and  C.Deleted=0


GO
