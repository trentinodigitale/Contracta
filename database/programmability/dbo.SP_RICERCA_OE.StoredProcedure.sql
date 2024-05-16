USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_RICERCA_OE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[SP_RICERCA_OE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	--ripulisco prima di eseguire la nuova ricerca
	delete CTL_DOC_Destinatari where IdHeader=@idDoc 

	--inserisce i destinatari
	insert into CTL_DOC_Destinatari (idheader,NumRiga,aziRagioneSociale,aziPartitaIVA,aziE_Mail,aziLocalitaLeg,aziIndirizzoLeg,aziStatoLeg )
	 select    
			@idDoc,
			'1,2',
			'aziRagioneSociale',
			'aziPartitaIVA',
			'Email',
			'aziLocalitaLeg', 
			'Indirizzo', 
			'StatoLeg'
	
	 from
		CTL_DOC_VALUE V1
		
   where 
   V1.idheader=@idDoc and V1.DSE_ID='CRITERI' and V1.dzt_name='aziRagioneSociale'


	
END
GO
