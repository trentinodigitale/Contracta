USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_SEDUTAVIRTUALE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[CK_SEC_DOC_SEDUTAVIRTUALE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin

	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	declare @Divisione_lotti as int

	select @Divisione_lotti = [Divisione_lotti] 
		from ctl_doc sv 
		inner join Document_Bando b 
		on sv.LinkedDoc = b.idHeader 
	where id=@IdDoc

	set @Blocco = ''

	if  @SectionName = 'InfoTecLotto' 
	begin
		if @Divisione_lotti > 0 
		begin
			set @Blocco = 'NON_VISIBILE'
		end
	end

	if  @SectionName = 'InfoTecLotti' 
	begin
		if @Divisione_lotti < 1 
		begin
			set @Blocco = 'NON_VISIBILE'
		end
	end

	select @Blocco as Blocco

end














GO
