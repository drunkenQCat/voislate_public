using AndroidX.DocumentFile.Provider;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// SafService Shared Project

namespace VoiSlaui
{
#if ANDROID

    public partial class SafService
    {
        public partial void ShowUriBrowser();
        public partial void PasteFile(string backupFolder, string fname, Uri destinyUri);
        public partial void CopyAllFromExternalStorage(string desPath);
        public partial void PasteAllToExternalStorage(string desPath);
    }
#endif

}
