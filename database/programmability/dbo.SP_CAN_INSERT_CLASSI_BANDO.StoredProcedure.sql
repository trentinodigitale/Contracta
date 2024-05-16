USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAN_INSERT_CLASSI_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select ClasseIscriz from Document_Bando where idheader=83582inner join ctl_doc on id=idheader and TipoDoc='BANDO' and ISNULL(JumpCheck,'')='' and Deleted=0 and StatoFunzionale not in ('InLavorazione','Revocato','Chiuso')
--Declare @blocco int; Exec SP_CAN_INSERT_CLASSI_BANDO 83582 , '###1###2###' , @blocco  output,1;
--Declare @blocco int; Exec SP_CAN_INSERT_CLASSI_BANDO 83582 , '###1936###'  , @blocco  output, 1;

CREATE proc [dbo].[SP_CAN_INSERT_CLASSI_BANDO] ( @IdDoc INT  , @classi nvarchar(MAX) ,  @out as INT output , @asp INT = 0)
AS
BEGIN 
 	set nocount on
	set @out=0
	declare @classi_usate as nvarchar(MAX)
	declare @classi_BLOCK_PATH as nvarchar(MAX)
	declare @path_classi_usate as nvarchar(MAX)
	declare @path_classi as nvarchar(MAX)
	set @classi_usate=''
	declare @esito as nvarchar(MAX)
	set @esito=''
	set @classi_BLOCK_PATH='###'
	declare @tipodoc as nvarchar(250)
	declare @idbando as INT

	select @tipodoc=tipodoc from ctl_doc where id=@IdDoc
	IF @tipodoc <> 'BANDO' 
	BEGIN
		SELECT @idbando=linkeddoc from ctl_doc where id=@IdDoc
	END
	ELSE
	BEGIN
		set @idbando=@IdDoc
	END

	----RECUPERO TUTTE LE CLASSI USATE SUI ME VALIDI
	select 	
			@classi_usate=@classi_usate + ISNULL(value,ClasseIscriz) 			

		from ctl_doc 
			inner join Document_Bando DB  on id=DB.idHeader and ISNULL(DB.ClasseIscriz,'') <> ''
			left join CTL_DOC_Value CV on CV.idHeader=id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz_MENO_Revocate'
			where TipoDoc='BANDO' and ISNULL(JumpCheck,'')='' 
					and Deleted=0 and StatoFunzionale not in ('InLavorazione','Revocato','Chiuso')
					and id<>@idbando	
	--print @classi_usate

	--FACCIO 2 CURSORI A CASCATA PER VERIFICARE SE LE CLASSI INSERITE SUL BANDO VANNO BENE
	declare CurProg Cursor Static for 

		select DMV_Father as path_classi
		from dbo.split(@classi,'###')
			inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0
			

	open CurProg

	FETCH NEXT FROM CurProg INTO @path_classi
		WHILE @@FETCH_STATUS = 0 --and @out=0
			BEGIN	
				--print 'NUOVA' + @path_classi
					
				declare CurProg2 Cursor Static for 
					select DMV_Father as path_classi_usate
						from dbo.split(@classi_usate,'###')
							inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0

				open CurProg2

				FETCH NEXT FROM CurProg2 INTO @path_classi_usate
					WHILE @@FETCH_STATUS = 0
						BEGIN
							if ( LEFT(@path_classi,len(@path_classi_usate) ) = @path_classi_usate or LEFT(@path_classi_usate,LEN(@path_classi))=@path_classi )
							BEGIN
							--	print '@path_classi' + @path_classi
								IF @tipodoc <> 'BANDO' or @asp=1
								BEGIN
									set @classi_BLOCK_PATH=@classi_BLOCK_PATH + @path_classi_usate + '###'  
								END

								set @out=1
								--break  NON ESCO PER DARE L'INFO DI TUTTE LE CLASSI CHE NON MI VANNO BENE
							END
				
				FETCH NEXT FROM CurProg2 INTO @path_classi_usate
						END

						CLOSE CurProg2
						DEALLOCATE CurProg2

	FETCH NEXT FROM CurProg  INTO @path_classi
			 END 

	CLOSE CurProg
	DEALLOCATE CurProg		
	
	---print @classi_BLOCK_PATH

	if @tipodoc <>  'BANDO' or @asp=1
	BEGIN
		select @esito=@esito + '<br/>Classe selezionata: ' + ISNULL(DMV_DescML,'') + ' - '+ dbo.CNV('Protocollo','I') + ' Bando dove è stata selezionata:' + ISNULL(Protocollo,'')	+ '<br/>'	
					from dbo.split(@classi_BLOCK_PATH,'###')
						inner join ClasseIscriz on DMV_Father=items
						inner join ctl_doc on TipoDoc='BANDO' and StatoFunzionale not in ('InLavorazione','Revocato','Chiuso') and Deleted=0 and ISNULL(JumpCheck,'')=''
						inner join document_bando on id=idHeader
						left join CTL_DOC_Value CV on CV.idHeader=id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz_MENO_Revocate' and value <> '###'
					where id <> @idbando and  ISNULL(value,ClasseIscriz )like '%###' + DMV_Cod + '###%'
	END	
	--print 'a' + @esito		
	IF @tipodoc <> 'BANDO' or @asp=1
	BEGIN
		delete from CTL_DOC_Value where DSE_ID='CLASSI' and DZT_Name='NoteScheda' and IdHeader=@IdDoc
		if @out=1
		BEGIN
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value) 
				VALUES (@IdDoc,'CLASSI',0,'NoteScheda' , 'Operazione non consentita, non si possono selezionare classi in uso su altri Bandi <br/> ' + @esito	)
		END
	END


	if @asp=1 and @out=1
		select 'Operazione non consentita, non si possono selezionare classi in uso su altri Bandi <br/> ' + @esito as esito
	else
		return @out
END


GO
