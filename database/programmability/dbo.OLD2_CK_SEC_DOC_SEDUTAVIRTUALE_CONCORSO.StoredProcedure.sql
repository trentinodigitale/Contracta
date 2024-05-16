USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_DOC_SEDUTAVIRTUALE_CONCORSO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  proc [dbo].[OLD2_CK_SEC_DOC_SEDUTAVIRTUALE_CONCORSO] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin

	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	declare @Divisione_lotti as int
	declare @InfoAnonime nvarchar(max)

	select @Divisione_lotti = [Divisione_lotti] 
		from ctl_doc sv 
		inner join Document_Bando b 
		on sv.LinkedDoc = b.idHeader 
	where id=@IdDoc

	--RECUPERO SE I DATI SONO IN CHIARO 
	select  @InfoAnonime = isnull([Value],'0')
		from 
			ctl_doc sed with(nolock) 
			inner join
			ctl_doc_value sv  with(nolock) 
				on sv.IdHeader = sed.LinkedDoc
			inner join Document_Bando b 
			on sv.idheader = b.idHeader 
			inner join ctl_doc bando on bando.id =  sv.idheader
		where sed.id = @IdDoc 
			and DSE_ID = 'ANONIMATO' 
			and DZT_Name = 'DATI_IN_CHIARO' 
			and Row = 0

	set @Blocco = ''

	if  @SectionName = 'InfoTecLotto' 
	begin
		if @Divisione_lotti > 0 
		begin
			set @Blocco = 'NON_VISIBILE'
		end
	end

	if  @SectionName = 'InfoAmm' 
	begin
		if @InfoAnonime <> '1'
		begin
			set @Blocco = 'l’accesso a tali informazioni è condizionato alla chiusura della fase tecnica'
		end
	end

	select @Blocco as Blocco

end













GO
