USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_GARA_QUESITI_HF_Stampe]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[OLD_GARA_QUESITI_HF_Stampe]
AS
	select 
		id as idRow , 
		ID AS idDoc ,
		'header1' as tipo ,
		'<html>
			<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       
				html, body  {   width:100%;    background-color:#red;     }        
				table     {margin:5 auto;  width:95%;              }    
				table td  {border-collapse:collapse; width:100%; font-size:12px; font-family:"Lucida Sans Unicode", "Lucida Grande", sans-serif; }
			</style>   
		    </head> 
			<body>
			<table align="top" border=0 margin=0 >' +
			+ '<tr  ><td  align="center" valign="top"  >'				 
			+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') + '"/>"' end
			+ '</td></tr>
			   <tr>
				<td align="center" valign="top" >
					<!--div><center>' + dbo.CNV('nome_portale','I') + '</center></div-->
					<div><center><b>' + aziRagioneSociale + '</b></center></div>
				</td>
			   </tr>
			   <tr>
				   <td align="left" valign="top"  >
					<div><b>Oggetto:</b>' + cast(body as nvarchar(max)) + '</div>
					<div><b>CIG:</b>' + CIG + '</div>
			      </td>
			  </tr>
			 </table>
			 </body>
			 </html>' 
		as  htmlValue

		from 
			ctl_doc with(nolock) 
				inner join Aziende with(nolock) on IdAzi=Azienda
				inner join document_bando with(nolock) on idheader = id 
		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0
		
		UNION ALL
	
	select 
		id as idRow , 
		ID AS idDoc ,
		'headerN' as tipo ,
		'<html>
			<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       
				html, body  {   width:100%;    background-color:#red;     }        
				table     {margin:5 auto;  width:95%;              }    
				table td  {border-collapse:collapse; width:100%; font-size:12px; font-family:"Lucida Sans Unicode", "Lucida Grande", sans-serif; }
			</style>   
		    </head> 
			<body>
			<table align="top" border=0 margin=0 >' +
			+ '<tr  ><td  align="center" valign="top"  >'				 
			+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') + '"/>"' end
			+ '</td></tr>
			   <tr>
				<td align="center" valign="top" >
					<!--div><center>' + dbo.CNV('nome_portale','I') + '</center></div-->
					<div><center><b>' + aziRagioneSociale + '</b></center></div>
				</td>
			   </tr>
			   <tr>
				   <td align="left" valign="top"  >
					<div><b>Oggetto:</b>' + cast(body as nvarchar(max)) + '</div>
					<div><b>CIG:</b>' + CIG + '</div>
			      </td>
			  </tr>
			 </table>
			 </body>
			 </html>' 
		as  htmlValue

		from 
			ctl_doc with(nolock) 
				inner join Aziende with(nolock) on IdAzi=Azienda
				inner join document_bando with(nolock) on idheader = id 
		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0
		
		
--union
	
--	select 
--		id as idRow , 
--		ID AS idDoc ,
--		'headerN' as tipo ,
--		'<html>
--			<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
--			<style>       
--				html, body  {   width:100%;    background-color:#red;     }        
--				table     {margin:3 auto;  width:100%;              }    
--				table td  {border-collapse:collapse; width:100%; font-size:12px; font-family:arial; }
--			</style>   
--		    </head> 
--			<body>
--			<table align="top" border=0 margin=0 >' +
--			+ '<tr  ><td  align="center" valign="top"  >'				 
--			+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') + '"/>"' end
--			+ '</td></tr>
--			   <tr>
--				<td align="center" valign="top" >
--					<!--div><center>' + dbo.CNV('nome_portale','I') + '</center></div-->
--					<div><center><b>' + aziRagioneSociale + '</b></center></div>
--				</td>
--			   </tr>
--			   <tr>
--				   <td align="left" valign="top"  >
--					<div><b>Oggetto:</b>' + cast(body as nvarchar(max)) + '</div>
--					<div><b>CIG:</b>' + CIG + '</div>
--			      </td>
--			  </tr>
--			 </table>
--			 </body>
--			 </html>' 
			
--		as  htmlValue

--		from 
--			ctl_doc with(nolock)
--				inner join Aziende with(nolock) on IdAzi=Azienda
--				inner join document_bando with(nolock) on idheader = id 
--		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0

UNION ALL

	select 
		id as idRow , 
		ID AS idDoc ,
		'footer' as tipo ,
		'
		<html>
		<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       
				html, body  {   width:100%;   background-color:#gray;  }        
				table     {margin:5 auto;  width:95%;   margin-bottom:0px;           }    
				table td  {border-collapse:collapse; width:100%; font-size:12px; }
			</style>   
		    </head> 
		<body>
			<table  border=0 margin=0 >     
			<tr>
				<td colspan=2 >Chiarimenti Pubblicati<hr></td>
			</tr>
			<tr>
				<td valign="bottom" >' +  convert(varchar(10), getdate(),103) + ' ' +  convert(varchar(10), getdate(),108) + '</td>
				<td valign="bottom" align="right" nowrap ><br> Pag. &p; / &P;</td>
			</tr>
			</table>
		</body>
		</html>
			' as  htmlValue

		from 
			ctl_doc with(nolock)
		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0

	
UNION ALL

	select 
		id as idRow , 
		ID AS idDoc ,
		'FOOTERHEIGHT' as tipo ,
		'50' as  htmlValue
		from 
			ctl_doc with(nolock)
		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0
UNION ALL

	select 
		id as idRow , 
		ID AS idDoc ,
		'HEADERHEIGHT' as tipo ,
		'100' as  htmlValue

		from 
			ctl_doc with(nolock)
		where Tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO' ) and deleted=0

GO
