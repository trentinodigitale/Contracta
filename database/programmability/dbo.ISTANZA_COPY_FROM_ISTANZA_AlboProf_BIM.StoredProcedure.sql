USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboProf_BIM]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboProf_BIM]( @idDoc as int , @oldIdDoc as int, @idpfu as int ) 
as
--@idDoc nuovo id
--@oldIdDoc id istanza precedente
--@idpfu -20 fisso per adesso
--riceve l'id della nuova istanza creata, il linkeddoc è il bando, prevdoc istanza precedente

--valorizzo la tabella nella ctl_doc_Value "POSIZIONI_FATTURARO_INCARICHI" a partire dal campo ATTIVITAPROFESSIONALEISTANZA
exec ISTANZA_AlboProf_POSIZIONI_FATTURARO_INCARICHI_2 @idDoc














GO
