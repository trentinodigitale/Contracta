USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CONVENZIONE_LISTA_DOCUMENTI_CONFERMATO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_CONVENZIONE_LISTA_DOCUMENTI_CONFERMATO] as

	SELECT 	 
	   [Id]	   
	  ,[TipoDoc]    
      ,[Titolo]      
      ,[LinkedDoc]      
      ,	case 
			when tipodoc='CONTRATTO_CONVENZIONE' then CDS.F3_SIGN_ATTACH 
			else CLD.[SIGN_ATTACH]   --ALLEGATO DEL LISTINO
		end as SIGN_ATTACH
	   ,TipoDoc as Ordinamento 
	FROM [dbo].[CONVENZIONE_LISTA_DOCUMENTI]  CLD
		left join CTL_DOC_SIGN CDS on CLD.id = CDS.idHeader
	WHERE StatoFunzionale='Confermato' and (tipodoc='Contratto_Convenzione' or tipodoc='LISTINO_CONVENZIONE')

UNION

	select 		   
		   idrow as id	   
		  ,'ALLEGATI_CONVENZIONE' as [TipoDoc]    
		  ,Descrizione as [Titolo]      
		  ,idheader as [LinkedDoc]    
		  ,Allegato as SIGN_ATTACH
		  ,'Z_ALLEGATI_CONVENZIONE'  as Ordinamento
		from 
		CTL_DOC_ALLEGATI
			where ISNULL(EvidenzaPubblica,0)=1

GO
