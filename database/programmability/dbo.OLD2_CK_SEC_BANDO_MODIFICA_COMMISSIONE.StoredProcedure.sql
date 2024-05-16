USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_BANDO_MODIFICA_COMMISSIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD2_CK_SEC_BANDO_MODIFICA_COMMISSIONE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	declare @tipodoc varchar(200)
	declare @TipoProceduraCaratteristica varchar(200)
	declare @tb varchar(50)
	declare @pg varchar(50)

	set @Blocco = ''
	set @TipoProceduraCaratteristica = ''

	select  @tipodoc = b.tipodoc,
			@TipoProceduraCaratteristica = c.TipoProceduraCaratteristica ,
			@pg = ProceduraGara,
			@tb = TipoBandoGara 
		from ctl_doc a with(nolock)
				inner join ctl_doc b with(nolock) ON a.LinkedDoc = b.id and b.deleted=0
				inner join document_bando c with(nolock) ON c.idHeader = b.id
		where a.id = @iddoc
	
	--print @tipodoc
	--print @TipoProceduraCaratteristica

    IF @SectionName = 'COMMISSIONE' and @tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')  -- Bando - Ristretta
    BEGIN
		set @Blocco = 'NON_VISIBILE'
    END
    
	if @SectionName = 'TECH_INFO' and (  (@TipoProceduraCaratteristica = 'RDO' or @tipodoc not in ('BANDO_GARA','BANDO_SEMPLIFICATO') ) or ( @tb = '1' and @pg = '15478' /*Avviso - Negoziata*/ ) )
    begin
		set @Blocco = 'NON_VISIBILE'		
    end


	IF @SectionName = 'PLANT'  -- VISIBILE SOLO BANDO_SDA E ACCORDOQUADRO
    BEGIN
		set @Blocco = 'NON_VISIBILE'
		if ( @tipodoc = 'BANDO_SDA' ) or  ( @tipodoc ='BANDO_GARA' and @TipoProceduraCaratteristica = 'ACCORDOQUADRO')
		BEGIN	
			set @Blocco = ''	
		END
    END
	
	select @Blocco as Blocco

end


GO
