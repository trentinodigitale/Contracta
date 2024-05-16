USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_MODIFICA_TESTATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[CK_SEC_BANDO_MODIFICA_TESTATA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	declare @tipodoc varchar(200)
	declare @TipoProceduraCaratteristica varchar(200)
	declare @tb varchar(50)
	declare @pg varchar(50)
	declare @moduliResult as char(1)

	set @Blocco = ''
	set @TipoProceduraCaratteristica = ''

      SELECT @moduliResult = substring([DZT_ValueDef], 240, 1) FROM [dbo].[LIB_Dictionary]  where DZT_NAME='SYS_MODULI_RESULT'	
	  SELECT  @tipodoc = b.tipodoc,
			@TipoProceduraCaratteristica = c.TipoProceduraCaratteristica ,
			@pg = ProceduraGara,
			@tb = TipoBandoGara 
		from ctl_doc a with(nolock)
				inner join ctl_doc b with(nolock) ON a.LinkedDoc = b.id and b.deleted=0
				inner join document_bando c with(nolock) ON c.idHeader = b.id
		where a.id = @iddoc
	
	--print @tipodoc
	--print @TipoProceduraCaratteristica

    IF @SectionName = 'TESTATA' and @tipodoc not in ('BANDO_GARA','BANDO_SEMPLIFICATO')  -- Bando - Ristretta
    BEGIN
		set @Blocco = 'NON_VISIBILE'
	
    END
    
    IF @SectionName = 'TESTATA' and (@moduliResult ='0' or @tipodoc in ('BANDO_SDA','BANDO')) 
    BEGIN
		set @Blocco = ''
	
    END
	
	
	select @Blocco as Blocco

end


GO
