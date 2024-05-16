USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_DRILL_MICROLOTTO_OFFERTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PDA_DRILL_MICROLOTTO_OFFERTA_TESTATA_VIEW] as

select 
		o.*
		, ModelloOfferta_Drill
	from Document_PDA_OFFERTE o with(nolock) 
		inner join Document_PDA_TESTATA t with(nolock) on t.idheader = o.idheader
		inner join Document_Modelli_MicroLotti m with(nolock) on m.Codice = t.ListaModelliMicrolotti
GO
