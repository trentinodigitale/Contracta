USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_SET_DESCRIZIONE_CLASSEISCRIZIONI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_SET_DESCRIZIONE_CLASSEISCRIZIONI]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @ClasseIscriz as varchar(max)
	
	select @ClasseIscriz=classeiscriz from document_bando where idheader=@idDoc

	delete ctl_doc_value where idheader=@idDoc and dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE' and DZT_Name in ('ClassiMerceologiche','ClassiMerceologicheLiv')

	insert into ctl_doc_value 
	    (IdHeader, DSE_ID, Row, DZT_Name, Value )
	   values
	    ( @idDoc , 'DESCRIZIONE_CLASSI_ISCRIZIONE', 0, 'ClassiMerceologiche', REPLACE(ISNULL(NULLIF(dbo.MDTGetDesrFromClasseIScriz(@ClasseIscriz), ''), 'Tutte le Classi'), ';', ' ') )
                                                                        
	
	insert into ctl_doc_value 
	    (IdHeader, DSE_ID, Row, DZT_Name, Value )
	   values
	    ( @idDoc , 'DESCRIZIONE_CLASSI_ISCRIZIONE', 0, 'ClassiMerceologicheLiv', REPLACE(ISNULL(NULLIF(dbo.MDTGetDesrFromClasseIScrizILiv(@ClasseIscriz), ''), ''), ';', ' ') )

END




GO
