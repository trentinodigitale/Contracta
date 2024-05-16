USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_COPY_FROM_ISTANZA_SDA_IC]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[ISTANZA_COPY_FROM_ISTANZA_SDA_IC]( @idDoc as int , @oldIdDoc as int, @idpfu as int ) 
as
--@idDoc nuovo id
--@oldIdDoc id istanza precedente
--@idpfu -20 fisso per adesso
--riceve l'id della nuova istanza creata, il linkeddoc è il bando, prevdoc istanza precedente



--escludo il modello messo per mantenere la storia prima di una modifica sulla sezione
delete from CTL_DOC_SECTION_MODEL 
	where IdHeader = @idDoc and DSE_ID in 
	( select DSE_ID from LIB_DocumentSections where DSE_DOC_ID like 'ISTANZA_SDA%' and  DSE_Param like '%DYNAMIC_MODEL=yes%' )
















GO
