USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MAKE_ASTA_FROM_LOTTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[MAKE_ASTA_FROM_LOTTO] ( @idLotto as int ) as
begin

	set nocount on
	declare @idDoc int
	set @idDoc = @idLotto

	declare @maxV float
	declare @minV float


	select  @maxV = max(d.ValoreEconomico ) ,@minV = min(d.ValoreEconomico ) 
	from  Document_MicroLotti_Dettagli d
		inner join Document_PDA_OFFERTE o on o.idrow = d.idheader
		inner join Document_MicroLotti_Dettagli l on l.idheader = o.idheader and l.TipoDoc = 'PDA_MICROLOTTI' and l.NumeroLotto = d.NumeroLotto and l.voce = '0'
		inner join PDA_MICROLOTTI_VIEW_TESTATA t on t.id = o.idheader
	where d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga <> 'escluso' and d.Voce = 0
		and l.id = @idDoc
	group by l.id


	select 

		Fascicolo as ProtocolBG
		, ProtocolloBando  
		, case TipoAppaltoGara when 1 then 15495 when 2 then 15496 when 3 then 15494 end  as tipoappalto
		, p.CriterioFormulazioneOfferte
		, case p.CriterioFormulazioneOfferte when 15536 then '2' else '1' end as TipoAsta
		, d.CIG
		, '1' as MultipleAuction
		, p.CUP
		, ltrim(str( case when   p.criterioformulazioneofferte = '15537' -- percentuale : '15536' -- prezzo : 
			then @maxV -- percentuale
			else @minV -- prezzo 
		end ,21,5)) 
		as ImportoBaseAsta
		, 'Asta per il lotto N°' + d.NumeroLotto as Titolo
		, d.NumeroLotto

		from Document_MicroLotti_Dettagli d
			inner join PDA_MICROLOTTI_VIEW_TESTATA p on p.id = d.idheader
			inner join document_Bando b on p.LinkedDoc = b.idheader

		where d.id = @idDoc


	set nocount off

end
GO
