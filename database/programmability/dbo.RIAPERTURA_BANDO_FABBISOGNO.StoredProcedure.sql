USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RIAPERTURA_BANDO_FABBISOGNO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[RIAPERTURA_BANDO_FABBISOGNO]  ( @iddoc as int )
AS
BEGIN
	
	declare @id_bando int
	declare @DataScadenzaBANDO as datetime
	declare @DataScadenzaBANDO_OLD as datetime
	declare @num_gg as int


	select 
		@id_bando=linkeddoc,
	    @DataScadenzaBANDO=cv.Value,
		@DataScadenzaBANDO_OLD=cv2.Value
	from ctl_doc 
		inner join CTL_DOC_Value CV on CV.IdHeader=id and CV.DSE_ID='TESTATA' and CV.DZT_Name='DataPresentazioneRisposte'
		inner join CTL_DOC_Value CV2 on CV2.IdHeader=id and  CV2.DSE_ID='TESTATA' and  CV2.DZT_Name='OLD_DataPresentazioneRisposte'
	where id=@iddoc

	set @num_gg=DATEDIFF(day,@DataScadenzaBANDO_OLD,@DataScadenzaBANDO)

	

	--metto il fabbisogno ad inviato
	update ctl_doc set StatoFunzionale='Inviato' where id=@id_bando
	--Aggiorna la data sul bando
	update Document_Bando set DataPresentazioneRisposte=@DataScadenzaBANDO where idHeader=@id_bando

	--SOLO SE NON ESISTONO LE PRECEDENTI DATE SUL BANDO LE INSERISCO
	IF NOT EXISTS ( select * from ctl_doc_value where idheader = @id_bando and DSE_ID='DATE_OLD')
	BEGIN
		insert into ctl_doc_value (idheader,DSE_ID,DZT_Name,value)
		VALUES(@id_bando,'DATE_OLD','OLD_DataPresentazioneRisposte',@DataScadenzaBANDO_OLD)
	
	END
	
	--rimetto la schedulazione del processo per la chiusura
	update CTL_Schedule_Process 
		set state=0 , 
			DataRequestExec=@DataScadenzaBANDO, 
			DataExecuted=NULL 
	where DPR_DOC_ID='BANDO_FABBISOGNI' and DPR_ID='CHIUSURA_AUTOMATICA' and IdDoc=@id_bando
	
	--RIMETTO I DESTINATARI che erano stati messi ad "Annullato"
	Update CTL_DOC_Destinatari set StatoIscrizione=NULL,IdPfu=NULL
	where idHeader=@id_bando and ISNULL(StatoIscrizione,'') = 'Annullato'
	and IdAzi not in (select Azienda from ctl_doc where TipoDoc='QUESTIONARIO_FABBISOGNI' and LinkedDoc=@id_bando and StatoFunzionale='Annullato')	

	Update CTL_DOC_Destinatari set StatoIscrizione='InLavorazione'	
	where idHeader=@id_bando and ISNULL(StatoIscrizione,'') = 'Annullato'
	and IdAzi in (select Azienda from ctl_doc where TipoDoc='QUESTIONARIO_FABBISOGNI' and LinkedDoc=@id_bando)

	
	--AGGIORNO IL QUESTIONARIO IN FUNZIONE DEI SUB O MENO
	--NON CI SONO SUB ALLORA METTO IN LAVORAZIONE
	update c set StatoFunzionale='InLavorazione' 
	from ctl_doc c 
		left join ctl_doc c1 on c1.LinkedDoc=c.id and c1.TipoDoc='SUB_QUESTIONARIO_FABBISOGNI'
	where c.TipoDoc='QUESTIONARIO_FABBISOGNI' and c.LinkedDoc=@id_bando 
	and c.StatoFunzionale='Annullato' and c1.id is null

	
	-- CI SONO SUB IN FASE DI COMPILAZIONE ALLORA METTO In Attesa Sub-Questionari ED IN QUESTO CASO AUMENTO ANCHE IL TEMPO PER RICEVERE LA RISPOSTA, STESSO NUMERO DI GIORNI CHE 
	-- E' AVANZATA LA SCADENZA
	update c set StatoFunzionale='In Attesa Sub-Questionari' 	
	from ctl_doc c 
		left join ( select linkeddoc from ctl_doc where TipoDoc='SUB_QUESTIONARIO_FABBISOGNI' and StatoFunzionale='InLavorazione' group by LinkedDoc) c1 on c1.LinkedDoc=c.id 
	where c.TipoDoc='QUESTIONARIO_FABBISOGNI' and c.LinkedDoc=@id_bando  
	and c.StatoFunzionale='Annullato' and c1.LinkedDoc is not null

	update c set c.DataScadenza=DATEADD(day,@num_gg,c.DataScadenza)
	from ctl_doc c
		inner join ctl_doc c2 on c2.id=c.LinkedDoc and c2.TipoDoc='QUESTIONARIO_FABBISOGNI' and c2.LinkedDoc=@id_bando  
	where c.TipoDoc='SUB_QUESTIONARIO_FABBISOGNI'  and c.StatoFunzionale='InLavorazione' 

	-- CI SONO SUB NON SONO IN FASE DI COMPILAZIONE ALLORA METTO Sub-Questionari Completati
	update c set StatoFunzionale='Sub-Questionari Completati' 	
	from ctl_doc c 
		left join ( select linkeddoc from ctl_doc where TipoDoc='SUB_QUESTIONARIO_FABBISOGNI' and StatoFunzionale <> 'InLavorazione' group by LinkedDoc) c1 on c1.LinkedDoc=c.id 
	where c.TipoDoc='QUESTIONARIO_FABBISOGNI' and c.LinkedDoc=@id_bando 
	and c.StatoFunzionale='Annullato' and c1.LinkedDoc is not null
	
	--AGGIORNA LA DATA SULLA TESTATA DEL QUESTIONARIO FABBISONGI
	update ctl_doc set datascadenza = @DataScadenzaBANDO from ctl_doc where linkeddoc = @id_bando and tipodoc = 'QUESTIONARIO_FABBISOGNI'


END


GO
