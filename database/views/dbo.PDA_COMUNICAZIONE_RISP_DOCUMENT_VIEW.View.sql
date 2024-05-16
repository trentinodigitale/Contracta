USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_COMUNICAZIONE_RISP_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[PDA_COMUNICAZIONE_RISP_DOCUMENT_VIEW]
as

	select 
		R.*
		,case
			
			when 
				--per queste due abbiamo specializzato il campo titolo 
				--per far uscire "risposta a " il titolo della cominicazione di partenza
				--quindi mettiamo come caption quello che prima mettevamo nel titolo
				isnull(C.jumpcheck,'') in ('1-GENERICA','1-GARA_COMUNICAZIONE_GENERICA') then 
									dbo.CNV( 'Risposta ' + substring(C.JumpCheck,3,len(C.JumpCheck)-2)	  , 'I')
			
			when isnull(C.jumpcheck,'')='' then 'Risposta Verifica Amministrativa'
			
			else
				--per le altre il titolo che non abbiamo toccato
				R.titolo 

		end as CaptionDoc

		from 
			CTL_DOC R with (nolock)
				
				left join ctl_doc C with (nolock) on C.id = R.linkeddoc

		where 
			
				R.TipoDoc='PDA_COMUNICAZIONE_RISP'



GO
