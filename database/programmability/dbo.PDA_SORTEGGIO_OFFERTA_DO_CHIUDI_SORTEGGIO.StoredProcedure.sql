USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_SORTEGGIO_OFFERTA_DO_CHIUDI_SORTEGGIO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PDA_SORTEGGIO_OFFERTA_DO_CHIUDI_SORTEGGIO]( @idDoc int ) 
as
begin

	declare @id int
	declare @idRow int
	declare @idPda int
	declare @NewDoc int
	declare @NumeroLotto  varchar(200)

	select @idPda = c.LinkedDoc
		from CTL_DOC d 
			inner join CTL_DOC c on d.LinkedDoc = c.id
		where d.id = @idDoc
	
	set @NewDoc = @idDoc

	select top 1 @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where idheader = @NewDoc and TipoDoc = 'PDA_SORTEGGIO_OFFERTA'


	-- azzero un eventuale sorteggio presente sulle righe della PDA
	update m set m.Sorteggio = 0
	from Document_MicroLotti_Dettagli  m
			inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE'
		where   m.NumeroLotto =   @NumeroLotto 
				and o.IdHeader = @idPda 



	-- ricopio i dati sulle righe della PDA
	update m set m.Sorteggio = d.Sorteggio , m.Exequo = 0
	from Document_MicroLotti_Dettagli  m
			inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE'
			inner join Document_MicroLotti_Dettagli d on d.NumeroLotto = m.NumeroLotto 
															and d.Aggiudicata = m.Aggiudicata 
															and d.idheader = @NewDoc 
															and d.TipoDoc = 'PDA_SORTEGGIO_OFFERTA'
		where   m.NumeroLotto =   @NumeroLotto 
				and m.Exequo = 1
				and o.IdHeader = @idPda 

	-- effetuo il calcolo della graduatoria
	exec PDA_GRADUATORIA_LOTTO @idPDA , @NumeroLotto 

	update CTL_DOC set StatoDoc = 'Sended' , datainvio = getdate() , StatoFunzionale = 'CONCLUSA' where id = @idDoc

end
GO
