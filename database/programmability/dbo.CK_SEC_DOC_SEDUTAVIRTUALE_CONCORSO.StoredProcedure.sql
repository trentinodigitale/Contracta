USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_SEDUTAVIRTUALE_CONCORSO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








--select * from ctl_doc where id  in (474841,474798)

CREATE  proc [dbo].[CK_SEC_DOC_SEDUTAVIRTUALE_CONCORSO] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin

	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	declare @Divisione_lotti as int
	declare @Dati_In_Chiaro nvarchar(max)
	declare @FaseConcorso as varchar(100)


	select 
		@Divisione_lotti = [Divisione_lotti] ,
		@FaseConcorso = isnull(FaseConcorso,'')
		from 
			ctl_doc sv 
				inner join Document_Bando b 
		on sv.LinkedDoc = b.idHeader 
	where id=@IdDoc

	set @Dati_In_Chiaro = '0'

	--RECUPERO SE I DATI SONO IN CHIARO 
	select  @Dati_In_Chiaro = isnull([Value],'0')
		from 
			ctl_doc sed with(nolock) 
				inner join	ctl_doc_value sv  with(nolock) on sv.IdHeader = sed.LinkedDoc and DSE_ID = 'ANONIMATO' and DZT_Name = 'DATI_IN_CHIARO' and Row = 0
				--inner join Document_Bando b on sv.idheader = b.idHeader 
				--inner join ctl_doc bando on bando.id =  sv.idheader
		where sed.id = @IdDoc 

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

		if @FaseConcorso = 'prima'
		begin
			set @Blocco = 'accesso a tali informazioni non previsto, dal momento che le buste amministrative saranno aperte al termine della seconda fase'
		end
		else
		begin

			if @Dati_In_Chiaro <> '1'
			begin
				set @Blocco = 'l’accesso a tali informazioni è condizionato alla chiusura della fase tecnica'
			end
		end
	end

	select @Blocco as Blocco

end













GO
