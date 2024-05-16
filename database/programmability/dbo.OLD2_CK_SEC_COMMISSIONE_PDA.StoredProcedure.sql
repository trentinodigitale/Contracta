USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_COMMISSIONE_PDA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[OLD2_CK_SEC_COMMISSIONE_PDA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	declare @idbando as int
	declare @tipodoc as nvarchar(100)
	declare @Jumpcheck as varchar(100)

	set @Blocco = ''
    
     select @idbando=linkeddoc, @Jumpcheck = JumpCheck from ctl_doc where id=@IdDoc

	
	--print @idbando
	---print @tipodoc
	--SE LA RELAZIONE LO RICHIEDE BLOCCO LA VISIBILITA' DEL FOLDER Richiesta Credenziali
	if @SectionName = ( 'BLOCCO'  ) 
	begin 
		IF EXISTS (select * from CTL_Relations where  [REL_ValueInput]='CK_SEC_COMMISSIONE_PDA' and [REL_Type]='RICHIESTA_CREDENZIALI' and REL_ValueOutput='NO' )
		set @Blocco = 'NON_VISIBILE'		
	end 
	--SE LA GARA NON PREVEDE NEPPURE UN LOTTO CON LA VALUTAZIONE TECNICA BLOCCO LA VISIBILITA' DEL FOLDER Commissione Tecnica
	if @SectionName = ( 'TECNICA'  ) 
	begin
	    ---SE NON CI SONO LOTTI A COSTO FISSO OPPURE OEV  E -NESSUN LOTTO CHE RICHIEDE LA CONFORMITA IL FOLDER HIDE
		IF NOT EXISTS ( 
				--nuovi documenti OEPV / costo fisso / conformità
				select idBando from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando=@idbando and ( CriterioAggiudicazioneGara in (25532,15532) or Conformita  <>'no') and @Jumpcheck<>'55;167'
				union
				--documento genrico OEPV
				select idmsg from tab_messaggi_fields where idmsg=@idbando and @Jumpcheck = '55;167' and CriterioAggiudicazioneGara ='15532'
					   ) 
		BEGIN
			set @Blocco='NON_VISIBILE'
		
		END		
	end  


	select @Blocco as Blocco

end




GO
