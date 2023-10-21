using Android.OS;
using PortableStorage.Droid;
using File = System.IO.File;
using Debug = System.Diagnostics.Debug;
using AndroidX.DocumentFile.Provider;
using PortableStorage;

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
        public static string FolderName
        {
            get
            {
                var folderName = StorageUri.AbsolutePath.Split("%3A").Last();
                return folderName;
            }
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

        public partial void CopyToExternalStorage(string intPath, string fname)
        {
            if (Build.VERSION.SdkInt >= BuildVersionCodes.N) // >= API Level 24
            {
                try
                {
                    // Falls es noch keine Uri gibt                
                    if (StorageUri == null) SafStorageHelper.BrowserFolder(MainActivity.Instance, MainActivity.BROWSE_REQUEST_CODE);

                    var sourcepath = Path.Combine(intPath, fname);

                    if (File.Exists(sourcepath))
                    {
                        var stream = File.Open(sourcepath, FileMode.Open);
                        var sr = new BinaryReader(stream);
                        var allBytes = sr.ReadBytes((int)stream.Length);

                        var externalStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, StorageUri);
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
                    var extPath = GetDirectoryPath();
                    var destinyPath = Path.Combine(desPath, FolderName);
                    if (!Directory.Exists(destinyPath))
                    {
                        Directory.CreateDirectory(destinyPath);
                    }
                    foreach (var file in extPath.ListFiles())
                    {
                        if (file.IsFile) PasteFile(externalStorage, file, destinyPath);
                        else if (file.IsDirectory)
                        {
                            var newFolderPath = Path.Combine(destinyPath, file.Name);
                            Directory.CreateDirectory(newFolderPath);
                            var newFolderStorage = SafStorgeProvider.CreateStorage(MainActivity.Instance, file.Uri);
                            foreach (var realFile in file.ListFiles()) { 
                                if (realFile.IsFile) PasteFile(newFolderStorage, realFile, newFolderPath); }
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }
        }

        private void PasteFile(StorageRoot externalStorage, DocumentFile file, string destiny)
        {
            byte[] allBytes;
            allBytes = externalStorage.ReadAllBytes(file.Name);

            destiny = Path.Combine(destiny, file.Name);
            using var stream = File.Open(destiny, FileMode.Create);
            using var sr = new BinaryWriter(stream);
            sr.Write(allBytes);


        }

        public partial DocumentFile GetDirectoryPath()
        {
            var androidUri = Android.Net.Uri.Parse(StorageUri.AbsoluteUri);
            return DocumentFile.FromTreeUri(MainActivity.Instance, androidUri);
        }
    }
}
