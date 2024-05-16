USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_VERBALEGARA_dettagli]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_VIEW_VERBALEGARA_dettagli]
as

select  
	IdRow, IdHeader, Pos, SelRow, TitoloSezione, DescrizioneEstesa, isnull(Edit,'1') as Edit,
	isnull(CanEdit,'1') as CanEdit,
	case isnull(CanEdit,'1') 
		when '0' then  ' Edit , DescrizioneEstesa '
		else 
			case isnull(Edit,'1') when '0' 
				then ' DescrizioneEstesa '	
				else ' ' end
		end as NonEditabili
		

	from Document_VerbaleGara_Dettagli  with (nolock)
		
GO
