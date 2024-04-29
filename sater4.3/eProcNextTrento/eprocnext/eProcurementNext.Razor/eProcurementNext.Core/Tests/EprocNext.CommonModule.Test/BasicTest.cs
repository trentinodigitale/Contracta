using Xunit;
using static eProcurementNext.CommonModule.Basic;
using Assert = Xunit.Assert;

namespace eProcurementNext.CommonModule.Test
{
    public class BasicTest
    {
        [Theory]
        [InlineData("http://www.example.com/and%26here.html", true)]
        [InlineData("http://www.example.com/and&here.html", true)]
        [InlineData("http://www.example.com/and here.html", false)]
        [InlineData("http://www.example.com/and<here.html", false)]
        [InlineData("http://", false)]
        [InlineData("http://no", true)]
        [InlineData("http:///no", false)]
        [InlineData("ab", false)]
        [InlineData("//", false)]
        public static void IsValidUrlTest(string url, bool valid)
        {
            var isValid = IsUrlValid(url);
            Assert.Equal(valid, isValid);
        }

        //[Fact]
        //public static void DeleteFileTest()
        //{
        //    string curDir = Directory.GetCurrentDirectory();
        //    string filePath = Path.Combine(curDir, "TestFiles", "fileToDelete.txt");

        //    Assert.True(File.Exists(filePath));

        //    File.SetAttributes(filePath, FileAttributes.ReadOnly);

        //    try
        //    {
        //        DeleteFile(filePath, true);
        //    }
        //    finally
        //    {
        //        if (File.Exists(filePath))
        //        {
        //            File.SetAttributes(filePath, FileAttributes.Normal);
        //            File.Delete(filePath);
        //        }
        //    }

        //    //try
        //    //{
        //    //    File.Delete(filePath);
        //    //}
        //    //catch (Exception ex) {
        //    //    //File.Move(filePath, filePath + "_del");

        //    //    File.SetAttributes(filePath, FileAttributes.Normal);
        //    //    File.Delete(filePath);
        //    //}


        //}



    }
}
