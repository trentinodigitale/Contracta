USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MAKE_ASTA_FROM_LOTTO_AZI_DEST]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[MAKE_ASTA_FROM_LOTTO_AZI_DEST]( @idDoc as int ) as
begin 
	select  o.idAziPartecipante as idAzi
	from  Document_MicroLotti_Dettagli d
		inner join Document_PDA_OFFERTE o on o.idrow = d.idheader
		inner join Document_MicroLotti_Dettagli l on l.idheader = o.idheader and l.TipoDoc = 'PDA_MICROLOTTI' and l.NumeroLotto = d.NumeroLotto and l.voce = '0'
	where d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga <> 'escluso' and d.Voce = 0
		and l.id = @idDoc

end

GO
