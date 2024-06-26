USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PCP_RECUPERO_UTENTE_RUP_SERVIZI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[OLD_PCP_RECUPERO_UTENTE_RUP_SERVIZI] 	(@idDoc int,  @IdUser int)
as
begin

	declare @Delegato_PCP		int
	declare @EnteDelegato_PCP	int
	declare @CDCDelegato_PCP	varchar( 100 )
	declare @Tipo_Rup as varchar(100)
	declare @TipoDoc_Innesco as varchar(200)

	select @TipoDoc_Innesco = TipoDoc from CTL_DOC with (nolock) where Id = @idDoc 

	set @Delegato_PCP = 0
	set @CDCDelegato_PCP =''

	select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

	-- prendo l'utente per fare le chiamate alla PCP in funzione del parametro: Espletante oppure proponente
	if @Tipo_Rup='UserRUP'  -- ESPLETANTE / APPALTANTE
	begin

		--PER INNESCO DA ODC CAMBIA IL RECUPERO DEL RUP
		if @TipoDoc_Innesco ='ODC'
		begin
			select @Delegato_PCP = UserRUP from Document_ODC with(nolock) where RDA_ID=@idDoc
		end
		else
		begin
			select @Delegato_PCP = Value 
				from ctl_doc_value  with(nolock) 
				where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
		end

		
		select 
				@EnteDelegato_PCP = azienda ,
				@CDCDelegato_PCP = ap.pcp_CodiceCentroDiCosto
			from CTL_DOC b with(nolock) 
				left join Document_PCP_Appalto ap  with (nolock) on b.id = ap.idHeader
			where id = @idDoc

	end
	else
	begin  -- PROPONENTE / RICHIEDENTE
				
		select 
				@Delegato_PCP = RupProponente , 
				@EnteDelegato_PCP = dbo.GetPos ( EnteProponente , '#' , 1 ) ,
				@CDCDelegato_PCP = pcp_CodiceCentroDiCostoProponente
			from document_bando  with(nolock) where idheader = @idDoc 

		--PER INNESCO DA ODC NON LO SO SE DEVE ESSERE PREVISTO

	end


	
	-- memorizzo sulla procedura l'utente trovato per riutilizzarlo sulle chiamate successive
	if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'Delegato_PCP'  )
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
			select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'Delegato_PCP' as [DZT_Name], @Delegato_PCP as [Value] 
	else
		update ctl_doc_value  set value =  @Delegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'Delegato_PCP'  



	if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'EnteDelegato_PCP'  )
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
			select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'EnteDelegato_PCP' as [DZT_Name], @EnteDelegato_PCP as [Value] 
	else
		update ctl_doc_value  set value =  @EnteDelegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'EnteDelegato_PCP'  



	if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'CDCDelegato_PCP'  )
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
			select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'CDCDelegato_PCP' as [DZT_Name], @CDCDelegato_PCP as [Value] 
	else
		update ctl_doc_value  set value =  @CDCDelegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'CDCDelegato_PCP'  




END





GO
