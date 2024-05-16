USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_QF_DOCUMENTAZIONE_RICHIESTA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[BANDO_QF_DOCUMENTAZIONE_RICHIESTA_FROM_USER] as

select 
	C.ID,
	P.idpfu as ID_FROM,
	C.Titolo as Descrizione,
	cast(C.Body as nvarchar(4000)) as DescrizioneRichiesta,
	' DescrizioneRichiesta ' as NotEditable,
	C.Titolo as AnagDoc,
	isnull(Obbligatorio,1) as Obbligatorio,
	--D.Allegato as AllegatoRichiesto,

	'' as AllegatoRichiesto,

	d.areavalutazione,
	c.statodoc,
	c.statofunzionale,
	peso,
	emas,
	TipoValutazione 

from CTL_DOC C 
cross join ProfiliUtente P
inner join Document_Anag_documentazione D on C.ID=D.IDHEADER
where C.TipoDoc='ANAG_DOCUMENTAZIONE' 
			and (D.Albo=1 or D.ContestoUsoDoc like   '%###Albo###%' )
			and  C.Deleted=0
			and c.statofunzionale='Pubblicato'
			and isnull(d.AnagDoc,'') <> 'DEFAULT_ANAGRAFICA_DOCUMENTI'






GO
