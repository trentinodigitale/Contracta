USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DATI_QUALIFICA_FROM_BANDO_QF]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DATI_QUALIFICA_FROM_BANDO_QF] as

select 
	a.idrow as id,
	a.idrow as linkeddoc,
	--a.idheader as ID_FROM,
	a.idrow as ID_FROM,
	DataScadenzaAbilitazione,
	StatoAbilitazione,
	body,
	idazi as idazi2,
	merceologia,
	idazi as IdAzienda

from Document_Questionario_Fornitore_Punteggi a
inner join ctl_doc b on b.ID=a.IDHEADER
inner join Document_bando c on c.IDHEADER=a.IDHEADER
where b.Deleted=0










GO
