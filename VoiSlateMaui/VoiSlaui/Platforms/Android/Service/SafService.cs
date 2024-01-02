using Android.OS;
using PortableStorage.Droid;
using File = System.IO.File;
using Debug = System.Diagnostics.Debug;
using AndroidX.DocumentFile.Provider;
using PortableStorage;
using Android.Content;
using Android.OS.Storage;
using Microsoft.Maui.Controls.PlatformConfiguration;
using Java.IO;

// SafService.cs Android Platform

namespace VoiSlaui
{
    public partial class SafService
    {

        public static Uri StorageUri
        {
            get
            {
                var Value = Preferences.Get("StorageUri", null);
                return Value != null ? new Uri(Value) : null;
            }
            set => Preferences.Set("StorageUri", value.ToString());
        }
        private static string RootUri => StorageUri.AbsoluteUri.Split("%3A").First();
        private static string FolderUri => StorageUri.AbsoluteUri.Split("%3A").Last();
        public static string SdUUID => RootUri.Split("/").Last();
        private static string MidUri(string folderUri) => $"{folderUri}/document/{SdUUID}";
        private static Uri GenerateNewUri(string folderUri) => new($"{RootUri}%3A{MidUri(folderUri)}%3A{folderUri}");
        private static Uri GenerateParentUri() => new($"{RootUri}%3A{MidUri(ParentFolderUri)}%3A{ParentFolderUri}");

        public static string SelectedFolderPath
        {
            get
            {
                return FolderUri;
            }
        }

        public static string ExtFolderName
        {
            get
            {
                var folderName = FolderUri.Split("%2F").Last();
                return folderName;
            }
        }
        public static string FolderNameMeta => $"{ExtFolderName}_Meta";
        private static string ParentFolderUri
        {
            get
            {
                var folderParts = FolderUri.Split("%2F").ToList();
                if (folderParts.Count == 1) { return ""; }
                else
                {
                    folderParts.RemoveAt(folderParts.Count - 1);
                    return string.Join("%2F", folderParts);
                }
            }
        }

        public Uri SiblingFolderUri(string FolderName)
        {
            var newFolderUri = GenerateNewUri($"{ParentFolderUri}%2F{FolderName}");
            return newFolderUri;
        }

        public partial void ShowUriBrowser()
        {
            try
            {
                if (Build.VERSION.SdkInt >= BuildVersionCodes.N)
                    SafStorageHelper.BrowserFolder(MainActivity.Instance, MainActivity.BROWSE_REQUEST_CODE); // >= API Level 24
            }
            catch (Exception e)
            {
                Debug.WriteLine(e);
            }
        }


        public partial void PasteFile(string backupFolder, string fname, Uri destinyUri)
        {
            if (Build.VERSION.SdkInt >= BuildVersionCodes.N) // >= API Level 24
            {
                try
                {
                    var sourcepath = Path.Combine(backupFolder, fname);

                    var docSource = androidGetDirectoryDocumentFile(sourcepath);
                    var docDestiny = androidGetDirectoryDocumentFile(destinyUri);
                    if (docSource.Exists())
                    {
                        var stream = File.Open(sourcepath, FileMode.Open);
                        var sr = new BinaryReader(stream);
                        var allBytes = sr.ReadBytes((int)stream.Length);
                        var externalStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, destinyUri);
                        externalStorage.WriteAllBytes(fname, allBytes);
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }
        }

        public partial void CopyAllFromExternalStorage(string desPath)
        {
            if (Build.VERSION.SdkInt >= BuildVersionCodes.N) // >= API Level 24
            {
                try
                {
                    if (StorageUri == null) SafStorageHelper.BrowserFolder(MainActivity.Instance, MainActivity.BROWSE_REQUEST_CODE);
                    var externalStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, StorageUri);
                    var extPath = androidGetDirectoryDocumentFile();
                    var destinyPath = Path.Combine(desPath, $"{FolderNameMeta}");
                    if (!Directory.Exists(destinyPath))
                    {
                        Directory.CreateDirectory(destinyPath);
                    }
                    foreach (var file in extPath.ListFiles())
                    {
                        if (file.Name.Contains("39"))
                        {
                            Debug.WriteLine("Ready");
                        }
                        if (file.IsFile) {
                            try
                            {
                                BackupFiles(externalStorage, file, destinyPath); 
                            }
                            catch (Exception e)
                            {
                                Debug.WriteLine(e);
                                continue;
                            }
                        }
                        else if (file.IsDirectory)
                        {
                            var newFolderPath = Path.Combine(destinyPath, file.Name);
                            Directory.CreateDirectory(newFolderPath);
                            var newFolderStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, file.Uri);
                            foreach (var realFile in file.ListFiles())
                            {
                                if (realFile.IsFile) BackupFiles(newFolderStorage, realFile, newFolderPath);
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }
        }
        public partial void PasteAllToExternalStorage(string desPath)
        {
            if (Build.VERSION.SdkInt >= BuildVersionCodes.N) // >= API Level 24
            {
                try
                {
                    var parentUri = GenerateParentUri();
                    var externalStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, parentUri);
                    var originalStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, StorageUri);

                    var backupPath = Path.Combine(desPath, $"{FolderNameMeta}");
                    string[] files = Directory.GetFiles(backupPath);
                    string[] directories = Directory.GetDirectories(backupPath);
                    var sibUri = SiblingFolderUri($"{FolderNameMeta}");

                    foreach (var file in files)
                    {
                        PasteFile(backupPath, file, sibUri);
                    }
                    foreach (var d in directories)
                    {
                        var recordPath = Path.Combine(backupPath, d);
                        string[] records = Directory.GetFiles(recordPath);
                        var storage = SafStorgeProvider.CreateStorage(MainActivity.Instance, sibUri);
                        Uri srcUri = SiblingFolderUri($"{FolderNameMeta}%2F{d}");
                        if (!storage.StorageExists(d)) storage.CreateStorage(d);
                        foreach (var f in Directory.GetFiles(recordPath))
                        {
                            PasteFile(recordPath, f, srcUri);
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }
        }

        private void BackupFiles(StorageRoot externalStorage, DocumentFile file, string destiny)
        {
            int bufferSize = 1048576;
            var recordStream = externalStorage.OpenStreamRead(file.Name);
            destiny = Path.Combine(destiny, file.Name);
            using BinaryReader binaryReader = new BinaryReader(recordStream);
            using var newRecordStream = File.Open(destiny, FileMode.Create);
            using var recordWriter = new BinaryWriter(newRecordStream);
            byte[] buffer = new byte[bufferSize];
            int bytesRead = 0;
            while ((bytesRead = binaryReader.Read(buffer, 0, buffer.Length)) > 0)
            {
                recordWriter.Write(buffer, 0, bytesRead);
            }
        }

        public DocumentFile androidGetDirectoryDocumentFile()
        {
            var androidUri = Android.Net.Uri.Parse(StorageUri.AbsoluteUri);
            return DocumentFile.FromTreeUri(MainActivity.Instance, androidUri);
        }
        public DocumentFile androidGetDirectoryDocumentFile(string path)
        {
            Java.IO.File k = new(path);
            var androidUri = Android.Net.Uri.FromFile(k);
            return DocumentFile.FromTreeUri(MainActivity.Instance, androidUri);
        }
        public DocumentFile androidGetDirectoryDocumentFile(Uri inputUri)
        {
            var androidUri = Android.Net.Uri.Parse(inputUri.AbsoluteUri);
            return DocumentFile.FromTreeUri(MainActivity.Instance, androidUri);
        }
    }
}
