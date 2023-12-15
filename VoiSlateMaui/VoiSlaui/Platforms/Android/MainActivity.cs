using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.OS;
using Android.Runtime;
using Microsoft.Maui.Controls.PlatformConfiguration;
using PortableStorage.Droid;
using Intent = Android.Content.Intent;
using static Microsoft.Maui.ApplicationModel.Platform;

namespace VoiSlaui;

[Activity(Theme = "@style/Maui.SplashTheme", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode | ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize | ConfigChanges.Density)]
public class MainActivity : MauiAppCompatActivity
{
    public const int BROWSE_REQUEST_CODE = 100;
    internal static MainActivity Instance { get; private set; }

    protected override void OnCreate(Bundle savedInstanceState)
    {
        base.OnCreate(savedInstanceState);
        Instance = this;
        PackageManager packageManager = PackageManager;
        var allPermission = Android.Provider.Settings.ActionManageAppAllFilesAccessPermission;
        var _ = packageManager.CheckPermission(allPermission, this.PackageName);
        var isAllAllowed =  _ == Permission.Granted;
        if (!isAllAllowed)
        {
            Intent intent = new Intent();
            intent.SetAction(Android.Provider.Settings.ActionManageAppAllFilesAccessPermission);
            Android.Net.Uri uri = Android.Net.Uri.FromParts("package", this.PackageName, null);
            intent.SetData(uri);
            StartActivity(intent);
        }
    }

    protected override void OnActivityResult(int requestCode, [GeneratedEnum] Result resultCode, Intent data)
    {
        base.OnActivityResult(requestCode, resultCode, data);

        try
        {
            if (requestCode == BROWSE_REQUEST_CODE && resultCode == Result.Ok)
                SafService.StorageUri = SafStorageHelper.ResolveFromActivityResult(this, data);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }

    }

}
