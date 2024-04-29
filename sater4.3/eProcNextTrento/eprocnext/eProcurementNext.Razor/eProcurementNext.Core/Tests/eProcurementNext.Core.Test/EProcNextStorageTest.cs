using eProcurementNext.Core.Storage;
using System.Security.Cryptography;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Core.Test
{
    public class EProcNextStorageTest
    {
        [Fact]
        public void ListTest()
        {
            var curDir = Directory.GetCurrentDirectory();
            var dirPath = Path.Combine(curDir, "ListTestFiles");
            if (!Directory.Exists(dirPath))
            {
                Directory.CreateDirectory(dirPath);
            }
            var f1 = Path.Combine(dirPath, "TestFile.txt");
            var d1 = Path.Combine(dirPath, "dir");
            File.WriteAllText(f1, "test");
            Directory.CreateDirectory(d1);
            try
            {
                IList<string> objects = CommonStorage.ListObjects(dirPath);
                IList<string> directories = CommonStorage.ListObjects(dirPath);
                Assert.NotEmpty(objects);
                Assert.NotEmpty(directories);
            }
            finally
            {
                Directory.Delete(dirPath, true);
            }
        }

        [Fact]
        public void GetTest()
        {
            var curDir = Directory.GetCurrentDirectory();
            var path = Path.Combine(curDir, "TestFiles", "TestFile.txt");
            var gotPath = Path.Combine(curDir, "TestFiles", "got.txt");
            Assert.True(File.Exists(path));
            Assert.True(!File.Exists(gotPath));

            try
            {
                using (Stream stream = CommonStorage.Get(path),
                    fs = File.OpenWrite(gotPath))
                {
                    stream.CopyTo(fs);
                }

                // verifica
                Assert.True(File.Exists(gotPath));
                using (FileStream fs = File.OpenRead(path),
                     fs2 = File.OpenRead(gotPath))
                {
                    byte[] hash = SHA256.Create().ComputeHash(fs);
                    byte[] hash2 = SHA256.Create().ComputeHash(fs2);
                    Assert.Equal(hash, hash2);
                }
            }
            finally
            {
                if (File.Exists(gotPath))
                {
                    File.Delete(gotPath);
                }
            }
        }

        [Fact]
        public void SaveTest()
        {
            var curDir = Directory.GetCurrentDirectory();
            var path = Path.Combine(curDir, "TestFiles", "TestFile.txt");
            var savePath = Path.Combine(curDir, "TestFiles", "saved.txt");
            Assert.True(File.Exists(path));
            Assert.True(!File.Exists(savePath));

            try
            {
                using (Stream src = File.Open(path, FileMode.Open, FileAccess.Read))
                {
                    CommonStorage.Save(savePath, src);
                }

                // verifica
                Assert.True(File.Exists(savePath));
                using FileStream fs = File.OpenRead(path),
                     fs2 = File.OpenRead(savePath);
                byte[] hash = SHA256.Create().ComputeHash(fs);
                byte[] hash2 = SHA256.Create().ComputeHash(fs2);
                Assert.Equal(hash, hash2);
            }
            finally
            {
                if (File.Exists(savePath))
                {
                    File.Delete(savePath);
                }
            }
        }

        [Fact]
        public static void DeleteObjectTest()
        {
            string curDir = Directory.GetCurrentDirectory();
            string filePath = Path.Combine(curDir, "TestFiles", "fileToDelete.txt");

            Assert.True(File.Exists(filePath));

            File.SetAttributes(filePath, FileAttributes.ReadOnly);

            try
            {
                CommonStorage.DeleteObject(filePath, true);
            }
            finally
            {
                if (File.Exists(filePath))
                {
                    File.SetAttributes(filePath, FileAttributes.Normal);
                    File.Delete(filePath);
                }
            }

            //try
            //{
            //    File.Delete(filePath);
            //}
            //catch (Exception ex) {
            //    //File.Move(filePath, filePath + "_del");

            //    File.SetAttributes(filePath, FileAttributes.Normal);
            //    File.Delete(filePath);
            //}


        }

    }
}