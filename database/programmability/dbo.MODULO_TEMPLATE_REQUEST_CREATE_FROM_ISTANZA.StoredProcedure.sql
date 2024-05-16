USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_TEMPLATE_REQUEST_CREATE_FROM_ISTANZA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[MODULO_TEMPLATE_REQUEST_CREATE_FROM_ISTANZA] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;


	
	select top 0 
		cast( '' as varchar(250)) as id , 
		cast( '' as varchar(max)) as Errore
		into #Result

	insert into #Result exec MODULO_TEMPLATE_REQUEST_CREATE_FOR @IdDoc , @idUser , 'DGUE'

	select * from #Result




END
GO
