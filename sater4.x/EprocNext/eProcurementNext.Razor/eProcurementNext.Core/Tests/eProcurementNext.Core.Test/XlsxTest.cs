using ClosedXML.Excel;
using eProcurementNext.BizDB.Test;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Xlsx.Test
{
    public class XlsxTest : BaseTest
    {
        [Fact]
        public void ClosedXmlTest()
        {
            var curDir = Directory.GetCurrentDirectory();
            var filePath = Path.Combine(curDir, "TestFiles", "testFile.xlsx");
            Assert.True(File.Exists(filePath));

            using var workbook = new XLWorkbook(filePath);
            foreach (IXLWorksheet ws in workbook.Worksheets)
            {
                IXLRow row = ws.Row(1);
                int lastRow = ws.LastRow().RowNumber();
                int lastRowUsed = ws.LastRowUsed().RowNumber();
            }
        }

        [Theory]
        [InlineData("importXlsxTestFile.xlsx", "_importSqlTest_CTL_Import", "Idpfu", "12345")]
        public void import_xlsx_intable_posizionale_Articoli_Test(string fileName, string table, string strNomeLink, string strValueLink)
        {
            var curDir = Directory.GetCurrentDirectory();
            var filePath = Path.Combine(curDir, "TestFiles", fileName);
            Assert.True(File.Exists(filePath));

            var link_xls = new Xls.Aflink_xslx();
            string res = link_xls.import_xlsx_intable_posizionale(filePath, table, strNomeLink, strValueLink, "posizionale", _connectionString);
            Assert.NotEmpty(res);
            Assert.True(res[0] == '1');
        }
    }
}
