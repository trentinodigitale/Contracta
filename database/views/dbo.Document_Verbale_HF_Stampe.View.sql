USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Verbale_HF_Stampe]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Verbale_HF_Stampe] as 

	SELECT 
			idRow , 
			IDHEADER AS idDoc ,
			'header1' as tipo ,
			dbo.GetHtmlTopVerbali() + isnull(cast(Testata as nvarchar(max)),'') + dbo.GetHtmlBottomVerbali() as  htmlValue

		 FROM Document_VerbaleGara with(nolock) 

	union all 

	SELECT 
			idRow , 
			IDHEADER AS idDoc ,
			'headerN' as tipo ,
			dbo.GetHtmlTopVerbali() + isnull(cast(Testata2 as nvarchar(max)),'') + dbo.GetHtmlBottomVerbali() as  htmlValue

		 FROM Document_VerbaleGara with(nolock) 

	 union all 

	 SELECT 
			idRow , 
			IDHEADER AS idDoc ,
			'footer' as tipo ,

			dbo.GetHtmlTopVerbali() + 

			case 
				when cast( PiePagina as nvarchar( max)) = '@@@footer@@@' then '<table width="100%" height="10px" style="vertical-align: bottom; bottom: 0px"><tr><td valign="bottom" align="right" ><br> Pag. &p; / &P;</td></tr></table>'
				else cast( PiePagina as nvarchar( max)) 
				end

			 + dbo.GetHtmlBottomVerbali()  as  htmlValue

		 FROM Document_VerbaleGara with(nolock) 
GO
