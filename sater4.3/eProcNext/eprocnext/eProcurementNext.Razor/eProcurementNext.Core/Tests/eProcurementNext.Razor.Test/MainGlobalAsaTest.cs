using eProcurementNext.Application;
using eProcurementNext.Session;
using Microsoft.Extensions.Configuration;
using MongoDB.Bson;
using MongoDB.Driver;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Razor.Test
{
    public class MainGlobalAsaTest
    {
        private MongoClient _client;
        private IMongoDatabase _database;
        private IMongoCollection<BsonDocument> _collection;

        private string GetConfigPath()
        {
            string configPath = "";

            var t = Path.GetFullPath(@"..\..\", Directory.GetCurrentDirectory());
            if (Path.GetDirectoryName(t).EndsWith("x64"))
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }
            else
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }

            return configPath;
        }

        public MainGlobalAsaTest()
        {
            var configPath = GetConfigPath();

            if (SessionCommon.Configuration == null)
            {
                SessionCommon.Configuration = new ConfigurationBuilder()
                    .SetBasePath(configPath)
                    .AddJsonFile("appsettings.json", false, false)
                    //.AddEnvironmentVariables()
                    .Build();
                //SessionCommon.Configuration = _configuration;

            }

            _client = new MongoClient();
            _database = _client.GetDatabase("local");

            _collection = _database.GetCollection<BsonDocument>(SessionCommon.CollectionName);
            //_collection = _database.GetCollection<BsonDocument>("AFLink_MaeTest");
        }


        private void GetDeleteTestReady(long idPfu, ref List<string> files, ref List<string> directories)
        {
            var curDir = Directory.GetCurrentDirectory();
            var FolderPrintDownloadDir = Path.Combine(curDir, "FolderPrintDownload");
            var PathFolderAllegatiDir = Path.Combine(curDir, "PathFolderAllegati");

            ApplicationCommon.Application["FolderPrintDownload"] = FolderPrintDownloadDir;
            ApplicationCommon.Application["PathFolderAllegati"] = PathFolderAllegatiDir;

            //var files = new List<string>();
            //var directories = new List<string>();

            var f1 = Path.Combine(FolderPrintDownloadDir, $"f1_{idPfu}");
            var f2 = Path.Combine(FolderPrintDownloadDir, $"f2");
            var f3 = Path.Combine(PathFolderAllegatiDir, $"f3_{idPfu}");
            var f4 = Path.Combine(PathFolderAllegatiDir, $"f4");
            var f5 = Path.Combine(PathFolderAllegatiDir, $"f5");
            var d1 = Path.Combine(PathFolderAllegatiDir, $"d1_{idPfu}");
            var d1f1 = Path.Combine(d1, "a");
            var d2 = Path.Combine(PathFolderAllegatiDir, $"d2");
            var d3 = Path.Combine(PathFolderAllegatiDir, $"d3");
            files.Add(f1);
            files.Add(f2);
            files.Add(f3);
            files.Add(f4);
            files.Add(f5);
            files.Add(d1f1);
            directories.Add(d1);
            directories.Add(d2);
            directories.Add(d3);

            Directory.CreateDirectory(FolderPrintDownloadDir);
            Directory.CreateDirectory(PathFolderAllegatiDir);

            File.WriteAllText(f1, "test");
            File.WriteAllText(f2, "test");
            File.WriteAllText(f3, "test");
            File.WriteAllText(f4, "test");
            File.SetCreationTime(f4, DateTime.Now.Subtract(new TimeSpan(1, 1, 0, 0)));
            File.WriteAllText(f5, "test");
            Directory.CreateDirectory(d1);
            File.WriteAllText(d1f1, "test");
            Directory.CreateDirectory(d2);
            Directory.SetCreationTime(d2, DateTime.Now.Subtract(new TimeSpan(1, 1, 0, 0)));
            Directory.CreateDirectory(d3);

            foreach (string path in files)
            {
                Assert.True(File.Exists(path));
            }
            foreach (string path in directories)
            {
                Assert.True(Directory.Exists(path));
            }
        }

        private void DeleteTestCheck(List<string> files, List<string> directories)
        {
            Assert.True(!File.Exists(files[0]));
            Assert.True(File.Exists(files[1]));
            Assert.True(!File.Exists(files[2]));
            Assert.True(!File.Exists(files[3]));
            Assert.True(File.Exists(files[4]));

            Assert.True(!Directory.Exists(directories[0]));
            Assert.True(!Directory.Exists(directories[1]));
            Assert.True(Directory.Exists(directories[2]));
        }

        private void DeleteTestCleaning(List<string> files, List<string> directories)
        {
            foreach (string path in files)
            {
                if (File.Exists(path))
                {
                    File.Delete(path);
                }
            }
            foreach (string path in directories)
            {
                if (Directory.Exists(path))
                {
                    Directory.Delete(path);
                }
            }
        }

        [Fact]
        public void Session_onEndTest()
        {
            var session = new eProcurementNext.Session.Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            var idPfu = -1;

            List<string> files = new List<string>();
            List<string> directories = new List<string>();

            GetDeleteTestReady(idPfu, ref files, ref directories);

            try
            {
                session.Init(id);
                session[SessionProperty.IdPfu] = idPfu;

                //MainGlobalAsa.Session_onEnd(session);
                DeleteTestCheck(files, directories);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);

                DeleteTestCleaning(files, directories);
            }
        }


        [Fact]
        public void DeleteFilePrintTest()
        {
            var session = new eProcurementNext.Session.Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            int idPfu = -1;

            var curDir = Directory.GetCurrentDirectory();
            var FolderPrintDownloadDir = Path.Combine(curDir, "FolderPrintDownload");
            var PathFolderAllegatiDir = Path.Combine(curDir, "PathFolderAllegati");

            ApplicationCommon.Application["FolderPrintDownload"] = FolderPrintDownloadDir;
            ApplicationCommon.Application["PathFolderAllegati"] = PathFolderAllegatiDir;

            var files = new List<string>();
            var directories = new List<string>();

            var f1 = Path.Combine(FolderPrintDownloadDir, $"f1_{idPfu}");
            var f2 = Path.Combine(FolderPrintDownloadDir, $"f2");
            var f3 = Path.Combine(PathFolderAllegatiDir, $"f3_{idPfu}");
            var f4 = Path.Combine(PathFolderAllegatiDir, $"f4");
            var f5 = Path.Combine(PathFolderAllegatiDir, $"f5");
            var d1 = Path.Combine(PathFolderAllegatiDir, $"d1_{idPfu}");
            var d1f1 = Path.Combine(d1, "a");
            var d2 = Path.Combine(PathFolderAllegatiDir, $"d2");
            var d3 = Path.Combine(PathFolderAllegatiDir, $"d3");
            files.Add(f1);
            files.Add(f2);
            files.Add(f3);
            files.Add(f4);
            files.Add(f5);
            files.Add(d1f1);
            directories.Add(d1);
            directories.Add(d2);
            directories.Add(d3);

            try
            {
                session.Init(id);
                session["idPfu"] = idPfu;

                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var doc = this._collection
                    .Find(filter)
                    .FirstOrDefault();
                Assert.NotNull(doc);


                Directory.CreateDirectory(FolderPrintDownloadDir);
                Directory.CreateDirectory(PathFolderAllegatiDir);

                File.WriteAllText(f1, "test");
                File.WriteAllText(f2, "test");
                File.WriteAllText(f3, "test");
                File.WriteAllText(f4, "test");
                File.SetCreationTime(f4, DateTime.Now.Subtract(new TimeSpan(1, 1, 0, 0)));
                File.WriteAllText(f5, "test");
                Directory.CreateDirectory(d1);
                File.WriteAllText(d1f1, "test");
                Directory.CreateDirectory(d2);
                Directory.SetCreationTime(d2, DateTime.Now.Subtract(new TimeSpan(1, 1, 0, 0)));
                Directory.CreateDirectory(d3);

                foreach (string path in files)
                {
                    Assert.True(File.Exists(path));
                }
                foreach (string path in directories)
                {
                    Assert.True(Directory.Exists(path));
                }

                // chiama metodo da testare
                //MainGlobalAsa.DeleteFilePrint(session);

                // verifica
                Assert.True(!File.Exists(f1));
                Assert.True(File.Exists(f2));
                Assert.True(!File.Exists(f3));
                Assert.True(!File.Exists(f4));
                Assert.True(File.Exists(f5));

                Assert.True(!Directory.Exists(d1));
                Assert.True(!Directory.Exists(d2));
                Assert.True(Directory.Exists(d3));

            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);

                foreach (string path in files)
                {
                    if (File.Exists(path))
                    {
                        File.Delete(path);
                    }
                }
                foreach (string path in directories)
                {
                    if (Directory.Exists(path))
                    {
                        Directory.Delete(path);
                    }
                }
            }
        }

    }
}