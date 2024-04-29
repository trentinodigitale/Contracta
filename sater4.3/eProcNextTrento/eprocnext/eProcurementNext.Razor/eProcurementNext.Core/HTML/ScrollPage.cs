using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;


namespace eProcurementNext.HTML
{
	public class ScrollPage
	{
		public long NumTotRow;          //'-- numero di righe nella tabella da paginare
		public long NumRowForPage;      //'-- numero di righe per pagina
		public long CurRow;             //'-- riga corrente, serve per il calcolo della pagina corrente
		public string URL;              //'-- indirizzo da chiamare per il salto pagina
		public string Target;           //'-- pagina di destinazione

		public string numPagToShow;     //'-- numero di pagine da mostrare come link diretti


		public string Style;
		public string strPath;
		private string strPathJS;

		public string Id;

		//private response As Object//non utilizzato

		public string GotoPageFunc;     //'-- nome della funzione da chiamare per il salto pagina



		//'-- avvalora la collezione con i javascript necessari al corretto
		//'-- funzionamento del controllo
		public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
		{

			strPathJS = Path;

			//'-- questi java script vengono messi staticamente nella pagina per consentire il corretto funzionamento
			if (!JS.ContainsKey("getObj"))
			{
				JS.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");
			}
			if (!JS.ContainsKey("getObj"))
			{
				JS.Add("ScrollPage", $@"<script src=""{Path}jscript/ScrollPage/ScrollPage.js"" ></script>");
			}



		}

		//'-- ritorna il codice html per rappresentare la riga di un gruppo
		public void Html(IEprocResponse objResp)
		{

			string StrUrl;

			//'-- questa operazione viene fatta perch� la barra di paginazione viene disegnata lato client
			//'-- la stringa che contiene l'url sebbene abbia gi� subito una trasformazione sull'apice
			//'-- quando scrive il codice la to client l'apice viene ritrasformato in singolo carattere e crea problemi
			StrUrl = URL;
			//'-- creazione della div che conterr� la barra di paginazione
			objResp.Write($@"<div id=""{HtmlEncodeValue(Id)}"" >");
			objResp.Write($@"</div> ");
			objResp.Write($@"<script type=""text/javascript"" > ");
			objResp.Write($@"   var ap; ");
			objResp.Write($@"   ap = getObj('{HtmlEncodeJSValue(Id)}'); ");
			objResp.Write($@"   SP_id = '{HtmlEncodeJSValue(Id)}';  ");
			objResp.Write($@"   SP_NumTotRow = {NumTotRow}; ");
			objResp.Write($@"   SP_NumRowForPage = {NumRowForPage}; ");

			//'--W3C codificare StrUrl sostituendo & con &amp;
			objResp.Write($@"   SP_URL = '{StrUrl.Replace("&", "&amp;")}'; ");
			objResp.Write($@"   SP_Target = '{HtmlEncodeJSValue(Target)}'; ");
			objResp.Write($@"   SP_numPagToShow = {numPagToShow}; ");
			objResp.Write($@"   SP_Style = '{HtmlEncodeJSValue(Style)}'; ");
			objResp.Write($@"   SP_Type = '{HtmlEncodeJSValue(GetParamURL(URL, "TypeScroll"))}'; ");
			objResp.Write($@"   SP_strPath = '{HtmlEncodeJSValue(strPath)}'; ");
			objResp.Write($@"   SP_strGotoPageFunc = '{HtmlEncodeJSValue(GotoPageFunc)}'; ");
			objResp.Write($@"    ");

			//'-- vengono inserite le nuove variabili e lasciate le precedenti per compatibilit� per il passato
			objResp.Write($@"   SP_NumTotRow_{HtmlEncodeValue(Id)} = {NumTotRow}; ");
			objResp.Write($@"   SP_NumRowForPage_{HtmlEncodeValue(Id)} = {NumRowForPage}; ");
			objResp.Write($@"   SP_URL_{HtmlEncodeValue(Id)} = '{StrUrl.Replace("&", "&amp;")}'; ");
			objResp.Write($@"   SP_Target_{HtmlEncodeValue(Id)} = '{HtmlEncodeJSValue(Target)}'; ");
			objResp.Write($@"   SP_numPagToShow_{HtmlEncodeValue(Id)} = {numPagToShow}; ");
			objResp.Write($@"   SP_Style_{HtmlEncodeValue(Id)} = '{HtmlEncodeJSValue(Style)}'; ");
			objResp.Write($@"   SP_Type_{HtmlEncodeValue(Id)} = '{HtmlEncodeJSValue(GetParamURL(URL, "TypeScroll"))}'; ");
			objResp.Write($@"   SP_strPath_{HtmlEncodeValue(Id)} = '{HtmlEncodeJSValue(strPath)}'; ");
			objResp.Write($@"   SP_strGotoPageFunc_{HtmlEncodeValue(Id)} = '{HtmlEncodeJSValue(GotoPageFunc)}'; ");
			objResp.Write($@"    ");


			objResp.Write($@"   function GoPage(  curPag , Path ) ");
			objResp.Write($@"   {{ ");
			objResp.Write($@"         GotoPage( Path + SP_URL , SP_Target , SP_id , curPag , SP_NumRowForPage   , SP_NumTotRow , SP_numPagToShow  , SP_Style ,SP_strPath ); ");
			objResp.Write($@"   }} ");
			objResp.Write($@"   function GoPage_{HtmlEncodeValue(Id)}(  curPag , Path ) ");
			objResp.Write($@"   {{ ");
			objResp.Write($@"         GotoPage( Path + SP_URL_{HtmlEncodeValue(Id)} , SP_Target_{HtmlEncodeValue(Id)} , '{HtmlEncodeJSValue(Id)}' , curPag , SP_NumRowForPage_{HtmlEncodeValue(Id)}   , SP_NumTotRow_{HtmlEncodeValue(Id)} , SP_numPagToShow_{HtmlEncodeValue(Id)}  , SP_Style_{HtmlEncodeValue(Id)} ,SP_strPath_{HtmlEncodeValue(Id)} ); ");
			objResp.Write($@"   }} ");
			objResp.Write($@"   function SP_Refresh( curPag ) ");
			objResp.Write($@"   {{ ");
			objResp.Write($@"         RefreshSP(  SP_URL , SP_Target , SP_id , curPag , SP_NumRowForPage   , SP_NumTotRow , SP_numPagToShow  , SP_Style ,SP_strPath ); ");
			objResp.Write($@"   }} ");
			objResp.Write($@"   function SP_Refresh_{HtmlEncodeValue(Id)}( curPag ) ");
			objResp.Write($@"   {{ ");
			objResp.Write($@"         RefreshSP(  SP_URL_{HtmlEncodeValue(Id)} , SP_Target_{HtmlEncodeValue(Id)} , '{HtmlEncodeJSValue(Id)}' , curPag , SP_NumRowForPage_{HtmlEncodeValue(Id)}   , SP_NumTotRow_{HtmlEncodeValue(Id)} , SP_numPagToShow_{HtmlEncodeValue(Id)}  , SP_Style_{HtmlEncodeValue(Id)} ,SP_strPath_{HtmlEncodeValue(Id)}); ");
			objResp.Write($@"   }} ");

			//'--W3C codificare StrUrl sostituendo & con &amp;
			objResp.Write($@"   DrawScrollPage( '{Id}' , {NumTotRow}, {NumRowForPage} , {CurRow},'{StrUrl.Replace("&", "&amp;")}','{Target}', {numPagToShow} , '{Style}' , '{strPath}' );");
			objResp.Write($@"</script> ");

		}



		public ScrollPage()
		{

            Style = "SP";
            Id = "ScrollPage";
            numPagToShow = CStr(10);
            NumTotRow = 1;
            CurRow = 1;
            NumRowForPage = 30;
            Target = "";
            URL = "";
            strPath = "../CTL_Library/images/ScrollPage/";
            if(IsMasterPageNew())
            {
                strPath = "../CTL_Library/images/ScrollPageFaseII/";
            }

		}



		public void SetScrollPage(string StrUrl, string strQueryString, long TotRow, string strTarget = "self")
		{

			int numCol;
			int c;

			long mp_NumeroPagina;

			//col = strQueryString;

			NumTotRow = TotRow;
			Target = strTarget;

			int nPag;

			URL = StrUrl + "?" + strQueryString;

			if (GetParamURL(strQueryString, "nPag") != "")
			{
				nPag = CInt(GetParamURL(strQueryString, "nPag"));//col["nPag"];
				URL = MyReplace(URL, $@"&nPag={GetParamURL(strQueryString, "nPag")}", "");
			}
			else
			{
				nPag = 1;
			}
			if (GetParamURL(strQueryString, "numRowForPag") != "")
			{

				var numRowForPage = GetParamURL(strQueryString, "numRowForPag");
				if (IsNumeric(numRowForPage))
				{
					//NumRowForPage = CLng(GetParamURL(strQueryString, "numRowForPag"));
					NumRowForPage = CLng(numRowForPage);
				}
				URL = MyReplace(URL, $@"&numRowForPag={GetParamURL(strQueryString, "numRowForPag")}", "");
			}

			CurRow = (nPag - 1) * NumRowForPage + 1;


		}


	}
}

