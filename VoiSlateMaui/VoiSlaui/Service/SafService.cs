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
        public partial void CopyToExternalStorage(string intPath, string fname);
        public partial void CopyAllFromExternalStorage(string desPath);
        public partial DocumentFile GetDirectoryPath();
    }
#endif

}
