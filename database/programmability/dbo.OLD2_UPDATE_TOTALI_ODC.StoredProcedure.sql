USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_UPDATE_TOTALI_ODC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_UPDATE_TOTALI_ODC] 
	( @IdOrdinativo int  )
AS
BEGIN
	
	declare @IdConvenzione as int
	declare @IdModello as int
	declare @CodiceModelloConvenzione as varchar(200)
	declare @DztNameQT as varchar(200)
	declare @DztNamePRZ as varchar(200)
	declare @DztNameVALACC as varchar(200)
	declare @TipoImporto as varchar(100)

	select @IdConvenzione=Id_Convenzione from document_odc where rda_id=@IdOrdinativo

	select @CodiceModelloConvenzione=value 
		from ctl_doc_value 
		where 
			idheader=@IdConvenzione and dse_id='TESTATA_PRODOTTI' and dzt_name='Tipo_Modello_Convenzione'

	
	select @TipoImporto=TipoImporto from Document_Convenzione where id=@IdConvenzione

	--recupero doc di tipo MODELLO con titolo questocodice
	set @IdModello=-1
	select @IdModello=id from ctl_doc where 
		 tipodoc='CONFIG_MODELLI' and deleted=0 
		 and linkeddoc=@IdConvenzione
		 --and statofunzionale='Pubblicato'
		 --and titolo=@CodiceModelloConvenzione
	--se modello non trovato (per le convezioni generate da trasferimento lotti) lo recupero dalla ctl_doc_value della convenzione
	if @IdModello = -1
	begin
		select 
			@IdModello=value 
			from 
				CTL_DOC_Value with (nolock)
			where IdHeader=@IdConvenzione and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'
	end

   

	--recupero nome attributo quantità
	set @DztNameQT=''
	select @DztNameQT=value from ctl_doc_value 
		where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_QTY'

	--recupero nome attributo quantità
	set @DztNamePRZ=''
	select @DztNamePRZ=value from ctl_doc_value 
		where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_PRZ'

	--recupero nome attributo quantità
	set @DztNameVALACC=''
	select @DztNameVALACC=value from ctl_doc_value 
		where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_VALACC'
		
	--print @DztNameQT + '-----' + @DztNameQT + '------' + @DztNamePRZ +  '-------' + @DztNameVALACC

	declare @strSQL as varchar(max)

	
	IF @DztNameVALACC <> ''
	BEGIN

		set @strSQL='

		declare @TotalIva as float
		declare @TotaleValoreAccessorio as float
		declare @Total as float
		declare @TotaleEroso as float
		declare @TotalIvaEroso as float
	

		select @Total=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		select @TotalIva=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') + ' + @DztNameVALACC + ')* aliquotaiva /100)),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
	
		select @TotaleEroso=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' ) and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		select @TotalIvaEroso=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') + ' + @DztNameVALACC + ')* aliquotaiva /100)),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' ) and idheader=' + cast(@IdOrdinativo as varchar(100)) + '

		select @TotaleValoreAccessorio = isnull( sum( cast( ' + @DztNameVALACC+ ' as float )), 0 ) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		'
		
		if @TipoImporto='ivainclusa'
		begin
		set @strSQL= @strSQL + '

			set @TotalIva=@Total
			set @Total=0
			select @Total=isnull(sum((' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + ') / ( 1.00 + aliquotaiva/100) ),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  idheader=' + cast(@IdOrdinativo as varchar(100)) + '
			set @Total = round(@Total,2)
			set @TotalIvaEroso = @TotaleEroso

			'
		end

		set @strSQL = @strSQL + '

			update document_odc
				set TotalIva	=@TotalIva,TotaleValoreAccessorio=@TotaleValoreAccessorio,rda_total=@Total , TotaleEroso= @TotaleEroso,TotalIvaEroso=@TotalIvaEroso
			where rda_id=' + cast(@IdOrdinativo as varchar(100)) 

	END
	ELSE
	BEGIN

		set @strSQL='

		declare @TotalIva as float
		declare @TotaleValoreAccessorio as float
		declare @Total as float
		declare @TotaleEroso as float
		declare @TotalIvaEroso as float
	

		select @Total=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		select @TotalIva=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') )* aliquotaiva /100)),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
	
		select @TotaleEroso=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and ( isnull(erosione,''si'')=''si'' or erosione='''' ) and idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		select @TotalIvaEroso=isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') )* aliquotaiva /100)),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' ) and idheader=' + cast(@IdOrdinativo as varchar(100)) + '

		set @TotaleValoreAccessorio=0 

		'
		
		if @TipoImporto='ivainclusa'
		begin
		set @strSQL= @strSQL + '

			set @TotalIva=@Total
			set @Total=0
			select @Total=isnull(sum((' + @DztNameQT + '*' + @DztNamePRZ + ') / ( 1.00 + aliquotaiva/100) ),0) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  idheader=' + cast(@IdOrdinativo as varchar(100)) + '
			set @Total = round(@Total,2)
			set @TotalIvaEroso = @TotaleEroso

			'
		end

		set @strSQL = @strSQL + '


		update document_odc
			set TotalIva	=@TotalIva,TotaleValoreAccessorio=@TotaleValoreAccessorio,rda_total=@Total , TotaleEroso= @TotaleEroso,TotalIvaEroso=@TotalIvaEroso
		where rda_id=' + cast(@IdOrdinativo as varchar(100)) 

	END


	--print @strSQL
	exec (@strSQL)

	--MEMORIZZO SULLA CTL_DOC_VALUE con DSE_ID='IMPORTI_LOTTI' per ODC
	delete from CTL_DOC_Value where IdHeader=@IdOrdinativo and DSE_ID='IMPORTI_LOTTI_ODC'
	set @strSQL = ''
	IF @DztNameVALACC <> ''
	BEGIN
		
		if @TipoImporto='ivainclusa'
		begin
			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIva'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''Total'', numerolotto  , + str(round(isnull(sum((' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + ') / ( 1.00 + aliquotaiva/100) ),0),2),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIvaEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)			
			
		end
		else
		begin
			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''Total'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIvaEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') + ' + @DztNameVALACC + ')* aliquotaiva /100)),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIva'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') + ' + @DztNameVALACC + ')* aliquotaiva /100)),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			
		end

		set @strSQL='
		insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
			select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotaleEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '+' + @DztNameVALACC + '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
		exec (@strSQL)

		set @strSQL='
		insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
			select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotaleValoreAccessorio'', numerolotto  , + str(isnull( sum( cast( ' + @DztNameVALACC+ ' as float )), 0 ),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
		exec (@strSQL)

		

		
	END	
	ELSE
	BEGIN
		if @TipoImporto='ivainclusa'
		begin
			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIva'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ +  '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''Total'', numerolotto  , + str(round(isnull(sum((' + @DztNameQT + '*' + @DztNamePRZ +  ') / ( 1.00 + aliquotaiva/100) ),0),2),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIvaEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ +  '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)			
			
		end
		else
		begin
			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''Total'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ +  '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIvaEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ +  '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') )* aliquotaiva /100)),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			set @strSQL='
			insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
				select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotalIva'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ +  '+( ((' + @DztNameQT + '*' + @DztNamePRZ +') )* aliquotaiva /100)),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
			exec (@strSQL)

			
		end

		set @strSQL='
		insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
			select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotaleEroso'', numerolotto  , + str(isnull(sum(' + @DztNameQT + '*' + @DztNamePRZ + '),0),20,2) from document_microlotti_dettagli where Tipodoc = ''ODC'' and  ( isnull(erosione,''si'')=''si'' or erosione='''' )  and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
		exec (@strSQL)

		set @strSQL='
		insert into ctl_doc_value (idheader,dse_id,dzt_name,row,value)
			select ' + cast(@IdOrdinativo as varchar(50))  + ',''IMPORTI_LOTTI_ODC'',''TotaleValoreAccessorio'', numerolotto  , 0 from document_microlotti_dettagli where Tipodoc = ''ODC'' and idheader=' + cast(@IdOrdinativo as varchar(100)) + ' group by numerolotto '
		exec (@strSQL)
	END

END


GO
